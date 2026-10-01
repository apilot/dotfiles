---
name: rlm
description: Process large codebases (>100 files) without context rot using RLM (Recursive Language Model) decomposition. Use when asked to "analyze codebase", "scan all files", "find usage of X", audit the whole repo, or reason over many files at once. Lets the agent act as a root node that filters with grep/find and fans out PARALLEL cheap sub-agents (map) then synthesizes (reduce), instead of reading everything into context.
---

# RLM — Recursive Language Model for opencode

## Core Philosophy

**Context is an external resource, not a local variable.**

You are the **root node**. You do NOT read files into your own context. You treat the filesystem as external storage and reach into it surgically via two engines. Only distilled summaries ever enter your context window. This is how you reason over a 10,000-file repo without context rot.

## The Two Engines

### Engine 1 — Native Mode (default)
Use built-in traversal + zero-shot filtering. Best for structure, locating definitions, counting, grepping.

- `find . -type f -name "*.ext"` — list candidates
- `rg "pattern"` / `grep -rl "pattern" .` — zero-shot filter (which files match?)
- `rg -l "@RestController|@Controller"` — narrow to relevant files
- `wc -l`, `ls`, `git ls-files` — cheap metadata

Native Mode is preferred whenever the question is "which files" or "where". It keeps your context at ~0 tokens until the Map phase.

### Engine 2 — Strict Mode
Use the local Python engine for **dense data** (logs, CSVs, minified bundles, one giant file) that grep handles poorly.

- `python3 ~/.config/opencode/skills/rlm/rlm.py scan --path ./src` — index a tree into hidden context (off-context)
- `python3 ~/.config/opencode/skills/rlm/rlm.py peek "<query>"` — return contextual snippets around every hit (JSON)
- `python3 ~/.config/opencode/skills/rlm/rlm.py chunk --pattern "<subpath>"` — split into 5000-char chunks (JSON) for sequential fan-out

The script's state lives in a short-lived process; it never pollutes your window. `peek`/`chunk` emit JSON you can parse or hand to a sub-agent.

## The RLM Loop (4 phases)

```
        ┌─────────────────────────────────────────────────────┐
ROOT ──▶│ 1. INDEX   2. FILTER   3. MAP (parallel)   4. REDUCE │
(you)   └─────────────────────────────────────────────────────┘
              grep/find      task(explore) xN     synthesize
```

1. **Index** — Native: `git ls-files` or `find . -type f`. Strict: `rlm.py scan`. Goal: a cheap list of candidate paths. Do NOT open them.
2. **Filter** — Zero-shot narrow with `rg -l "<marker>"`. Optionally `rlm.py peek "<sig>"` to confirm relevance. Goal: a *small* set (≤ a few dozen) of files worth deep-reading.
3. **Map** — Fan out map workers (MAX 2 parallel — see global rate-limit policy in `AGENTS.md`). Each worker reads a **BATCH of 3–5 files/chunks** (not one file) and returns a tiny structured summary.
4. **Reduce** — You collect the summaries, dedupe, cross-reference, and produce the answer. **You never read the raw files.**

## CRITICAL — Map workers MUST be opencode `task()` tools

opencode's parallel sub-agent primitive is the **`task` tool**. Spawn map workers using the cheap fast model — **one worker per BATCH of 3–5 files**, not one per file:

```
task(
  subagent_type="explore",
  description="Extract API endpoints + auth decorators from src/auth/controller.py",
  prompt="Read the single file src/auth/controller.py. Return ONLY a JSON array; each item: {file, endpoint, http_method, auth_decorators:[], handler_line}. No prose."
)
```

- `explore` is a cheap, fast agent — the ideal map worker.
- **Replace ALL references to Claude Code's `background_task` / Task tool with opencode's `task(subagent_type="explore", ...)`.** Do not invent `background_task`; it does not exist here.
- Launch **MAX 2 in parallel** per tool block (z.ai coding plan rate limit — see `AGENTS.md`). For >6 files, batch them into 3–5-file workers instead of adding more parallel calls.
- Make every worker return **structured output** (JSON / a strict schema) so the Reduce phase is mechanical.

## Hard Rules

- **Never read >3-5 files into main context at once.** If you must read, it goes to a map worker, not to you.
- **Always use `task()` when the file count > 1.** The root node reads paths, not contents.
- **Launch MAX 2 parallel map workers** per tool block (z.ai rate limit — see `AGENTS.md`). Batch >6 files into 3–5-file workers; do NOT exceed 2 concurrent sub-agents.
- Keep each map worker's prompt surgical: ONE schema, NO prose (but a worker may iterate over its 3–5-file batch internally).
- The Reduce phase is where you actually think. Everything before it is plumbing.

## Recovery Mode (if `task()` is unavailable OR rate-limited)

**Trigger this mode immediately** when ANY sub-agent reports `Rate limit reached`, `temporarily overloaded`, or `Retrying (attempt ≥ 3)`. It makes **zero model calls**, so it never hits rate limits.

Fall back to **iterative Python scripting**: write a throwaway script that loops over filtered paths, opens each, runs a regex/AST check, and prints a one-line summary to stdout. Read only the stdout. This keeps dense content out of your window:

```python
import re, pathlib, sys
sig = re.compile(r"@(Get|Post|Put|Delete)Mapping|def .+\(.*request")
for p in pathlib.Path("src").rglob("*.py"):
    hits = [ln for ln in p.read_text(errors="ignore").splitlines() if sig.search(ln)]
    if hits: print(f"{p}\t" + " | ".join(hits[:3]))
```

## Worked Example — "Find all API endpoints and check for auth"

**1. Index + Filter (Native Mode, you run):**
```bash
rg -l "@Controller|@RestController|@app\.(get|post|route)" . --type py --type java --type ts
```
→ Suppose this returns `auth_ctrl.py`, `user_ctrl.py`, `billing_ctrl.py`, `admin_ctrl.py`.

**2. Map (launch MAX 2 parallel `task()` workers — each a BATCH of 2 files):**
```
task(subagent_type="explore",
     description="Endpoints+auth in {auth,user}_ctrl.py",
     prompt="Read auth_ctrl.py AND user_ctrl.py. Return JSON array of {file,route,method,has_auth:bool,decorators} for BOTH files. Only JSON.")
task(subagent_type="explore",
     description="Endpoints+auth in {billing,admin}_ctrl.py",
     prompt="Read billing_ctrl.py AND admin_ctrl.py. Return JSON array of {file,route,method,has_auth:bool,decorators} for BOTH files. Only JSON.")
```

**3. Reduce (you synthesize):**
Collect the 2 batched JSON arrays (covering all 4 files) → compile one table of all routes → flag every row where `has_auth == false`. Report: "Found 27 endpoints; 3 in `billing_ctrl.py` are missing auth: `POST /charge`, `GET /invoices`, `DELETE /card`." You never read a single source file.

## When to use which engine

| Question | Engine |
|---|---|
| Which files contain / define X? | Native (`rg -l`) |
| Count / list / structure | Native (`find`, `git ls-files`) |
| One giant file / logs / CSV / minified | Strict (`rlm.py chunk`) |
| "Show me context around every hit" | Strict (`rlm.py peek`) |
| Deep reasoning over many files | Native filter → `task(explore)` map → reduce |
