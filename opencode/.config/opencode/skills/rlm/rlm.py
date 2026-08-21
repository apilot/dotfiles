import os
import glob
import json
import math
from pathlib import Path
from typing import List, Dict, Any

class RLMContext:
    def __init__(self, root_dir: str = "."):
        self.root = Path(root_dir)
        self.index: Dict[str, str] = {}
        self.chunk_size = 5000

    def load_context(self, pattern: str = "**/*", recursive: bool = True):
        files = glob.glob(str(self.root / pattern), recursive=recursive)
        loaded_count = 0
        for f in files:
            path = Path(f)
            if path.is_file() and not any(p in str(path) for p in ['.git', '__pycache__', 'node_modules']):
                try:
                    self.index[str(path)] = path.read_text(errors='ignore')
                    loaded_count += 1
                except Exception:
                    pass
        return f"RLM: Loaded {loaded_count} files into hidden context. Total size: {sum(len(c) for c in self.index.values())} chars."

    def peek(self, query: str, context_window: int = 200) -> List[str]:
        results = []
        for path, content in self.index.items():
            if query in content:
                start = 0
                while True:
                    idx = content.find(query, start)
                    if idx == -1: break
                    snippet_start = max(0, idx - context_window)
                    snippet_end = min(len(content), idx + len(query) + context_window)
                    snippet = content[snippet_start:snippet_end]
                    results.append(f"[{path}]: ...{snippet}...")
                    start = idx + 1
        return results[:20]

    def get_chunks(self, file_pattern: str = None) -> List[Dict[str, Any]]:
        chunks = []
        targets = [f for f in self.index.keys() if (not file_pattern or file_pattern in f)]
        for path in targets:
            content = self.index[path]
            total_chunks = math.ceil(len(content) / self.chunk_size)
            for i in range(total_chunks):
                start = i * self.chunk_size
                end = min((i + 1) * self.chunk_size, len(content))
                chunks.append({"source": path, "chunk_id": i, "content": content[start:end]})
        return chunks

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="RLM Engine")
    subparsers = parser.add_subparsers(dest="command")
    load_parser = subparsers.add_parser("scan")
    load_parser.add_argument("--path", default=".")
    peek_parser = subparsers.add_parser("peek")
    peek_parser.add_argument("query")
    chunk_parser = subparsers.add_parser("chunk")
    chunk_parser.add_argument("--pattern", default=None)
    args = parser.parse_args()
    # Resolve root: honor `scan --path`; default to cwd for peek/chunk.
    scan_path = args.path if (args.command == "scan" and getattr(args, "path", None)) else "."
    ctx = RLMContext(scan_path)
    ctx.load_context()
    if args.command == "scan":
        print(ctx.load_context())
    elif args.command == "peek":
        print(json.dumps(ctx.peek(args.query), indent=2))
    elif args.command == "chunk":
        print(json.dumps(ctx.get_chunks(args.pattern)))
    else:
        parser.print_help()
