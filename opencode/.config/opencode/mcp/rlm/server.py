"""MCP stdio server exposing rlms (github.com/alexzhang13/rlm) backed by Z.AI GLM.

Tools:
  rlm_completion(prompt, model="glm-4.6") -> str
  rlm_analyze(path, query, model="glm-4.6") -> str

The Recursive Language Model (RLM) runs an agentic loop: the root model emits
Python snippets that are executed in an in-process sandboxed REPL, and a
cheaper model handles depth-1 sub-queries. Configure via environment:

  Z_AI_API_KEY        (required) Z.AI API key
  Z_AI_BASE_URL       (default https://api.z.ai/api/coding/paas/v4)
  RLM_ROOT_MODEL      (default glm-4.6)        root/agentic model
  RLM_SUB_MODEL       (default glm-4.7-flashx) depth-1 plain-LM sub-call model
  RLM_MAX_TIMEOUT     (default 300) per-call wall-clock cap in seconds
  RLM_MAX_ITERATIONS  (default 30)  root-loop iteration cap
  RLM_ANALYZE_MAX_CHARS (default 200000) content cap fed into rlm_analyze
  RLM_MAX_CONCURRENT_SUBCALLS (default 3) max parallel sub-model calls; keep at
                       or below the sub-model's per-model concurrency limit on
                       z.ai (e.g. glm-4.7-flashx = 3). z.ai limits by concurrency
                       per model, not RPM/quota.
"""

from __future__ import annotations

import glob
import os
from typing import Any

from mcp.server.fastmcp import FastMCP

from rlm import RLM
from rlm.core.lm_handler import LMHandler

Z_AI_BASE_URL = os.getenv("Z_AI_BASE_URL", "https://api.z.ai/api/coding/paas/v4")
DEFAULT_ROOT_MODEL = os.getenv("RLM_ROOT_MODEL", "glm-4.6")
DEFAULT_SUB_MODEL = os.getenv("RLM_SUB_MODEL", "glm-4.7-flashx")
DEFAULT_MAX_TIMEOUT = float(os.getenv("RLM_MAX_TIMEOUT", "300"))
DEFAULT_MAX_ITERATIONS = int(os.getenv("RLM_MAX_ITERATIONS", "30"))
ANALYZE_MAX_CHARS = int(os.getenv("RLM_ANALYZE_MAX_CHARS", "200000"))
# Cap parallel sub-model calls so we stay under the per-model concurrency limit
# on the z.ai coding plan (e.g. glm-4.7-flashx = 3 concurrent). z.ai limits by
# concurrency-per-model, not RPM/quota, so exceeding this raises "rate limit
# reached" even when the quota panel shows plenty of headroom.
DEFAULT_MAX_CONCURRENT_SUBCALLS = int(os.getenv("RLM_MAX_CONCURRENT_SUBCALLS", "3"))

mcp = FastMCP("rlm")


# RLM constructs LMHandler internally (see rlm/core/rlm.py) WITHOUT passing
# batch_max_concurrent, so it defaults to 16 inside lm_handler.py. That would
# let batched llm() calls fan out to 16 parallel sub-model requests and blow
# past low-concurrency sub-models. Patch the constructor so the batched path
# honors the same cap; an explicit batch_max_concurrent is still respected.
_orig_lmhandler_init = LMHandler.__init__


def _capped_lmhandler_init(self, client, *args, batch_max_concurrent=None, **kwargs):
    if batch_max_concurrent is None:
        batch_max_concurrent = DEFAULT_MAX_CONCURRENT_SUBCALLS
    _orig_lmhandler_init(
        self, client, *args, batch_max_concurrent=batch_max_concurrent, **kwargs
    )


LMHandler.__init__ = _capped_lmhandler_init


def _require_api_key() -> str:
    key = os.getenv("Z_AI_API_KEY")
    if not key:
        raise RuntimeError(
            "Z_AI_API_KEY is not set; cannot reach the Z.AI GLM backend."
        )
    return key


def _build_rlm(root_model: str) -> RLM:
    """Construct an RLM rooted at ``root_model`` with a cheaper sub-call model.

    base_url/api_key are passed via backend_kwargs straight into
    ``OpenAIClient`` -> ``openai.OpenAI(base_url=..., api_key=...)``.
    ``other_backends`` routes depth-1 sub-calls to the cheap model.
    """
    api_key = _require_api_key()
    root_kwargs: dict[str, Any] = {
        "base_url": Z_AI_BASE_URL,
        "api_key": api_key,
        "model_name": root_model,
    }
    sub_kwargs: dict[str, Any] = {
        "base_url": Z_AI_BASE_URL,
        "api_key": api_key,
        "model_name": DEFAULT_SUB_MODEL,
    }
    return RLM(
        backend="openai",
        backend_kwargs=root_kwargs,
        other_backends=["openai"],
        other_backend_kwargs=[sub_kwargs],
        max_iterations=DEFAULT_MAX_ITERATIONS,
        max_timeout=DEFAULT_MAX_TIMEOUT,
        max_concurrent_subcalls=DEFAULT_MAX_CONCURRENT_SUBCALLS,
    )


@mcp.tool()
def rlm_completion(prompt: str, model: str = DEFAULT_ROOT_MODEL) -> str:
    """Run an RLM (recursive language model) completion backed by Z.AI GLM.

    Args:
        prompt: The user prompt or question.
        model: Root model name (default glm-4.6). Must be a Z.AI model that
            supports tool/reasoning use for the agentic loop (e.g. glm-4.6).

    Returns:
        The model's final answer as a string.
    """
    rlm = _build_rlm(model)
    return rlm.completion(prompt).response


def _gather_content(path: str) -> str:
    """Read a file or the text files under a directory/glob into one string.

    Binary files are skipped. Output is capped at ANALYZE_MAX_CHARS.
    """
    candidates: list[str] = []
    if any(ch in path for ch in "*?["):
        candidates.extend(sorted(glob.glob(path, recursive=True)))
    elif os.path.isdir(path):
        for root, _dirs, files in os.walk(path):
            for name in sorted(files):
                candidates.append(os.path.join(root, name))
    elif os.path.isfile(path):
        candidates.append(path)
    else:
        raise FileNotFoundError(f"No file or directory matched: {path}")

    chunks: list[str] = []
    total = 0
    per_file_cap = max(ANALYZE_MAX_CHARS // max(len(candidates), 1), 8192)
    for fp in candidates:
        if os.path.islink(fp) or not os.path.isfile(fp):
            continue
        try:
            with open(fp, "rb") as fh:
                raw = fh.read(per_file_cap + 1)
        except OSError:
            continue
        try:
            text = raw.decode("utf-8")
        except UnicodeDecodeError:
            continue
        if len(raw) > per_file_cap:
            text = text[:per_file_cap] + "\n...[truncated]\n"
        header = f"\n===== FILE: {fp} =====\n"
        chunks.append(header + text)
        total += len(header) + len(text)
        if total >= ANALYZE_MAX_CHARS:
            chunks.append("\n...[total content cap reached, further files omitted]\n")
            break
    if not chunks:
        raise RuntimeError(f"No readable text content found under: {path}")
    return "".join(chunks)


@mcp.tool()
def rlm_analyze(path: str, query: str, model: str = DEFAULT_ROOT_MODEL) -> str:
    """Answer ``query`` over the contents of a file, directory, or glob pattern.

    Loads the target's text content into the prompt, then runs the RLM. Use this
    for dense-data tasks: log triage, CSV/JSON summarization, large-file Q&A.

    Args:
        path: File path, directory, or glob pattern (e.g. "logs/*.log").
        query: The question to answer over the loaded content.
        model: Root model name (default glm-4.6).

    Returns:
        The model's answer as a string.
    """
    content = _gather_content(path)
    prompt = (
        "You are analyzing file content provided below. Use it (and any tools "
        "available in your REPL) to answer the user's question precisely.\n\n"
        f"USER QUESTION:\n{query}\n\n"
        f"FILE CONTENT (may be truncated):\n{content}"
    )
    rlm = _build_rlm(model)
    return rlm.completion(prompt).response


if __name__ == "__main__":
    mcp.run()
