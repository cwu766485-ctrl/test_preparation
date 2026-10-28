#!/usr/bin/env python3
"""Add portable VCD capture to exercise testbenches that have no dump task."""

from __future__ import annotations

import os
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
HDL_SUFFIXES = {".v", ".sv"}
MODULE_RE = re.compile(r"\bmodule\s+(\w+)", re.IGNORECASE)
TB_NAME_RE = re.compile(r"(^tb\w*|\w*tb\w*|\w*testbench\w*)", re.IGNORECASE)
ENDMODULE_RE = re.compile(r"(?m)^[ \t]*endmodule(?:[ \t]*:[ \t]*\w+)?[ \t]*$")
SKIP_DIRS = {".git", "build", "csrc", "simv.daidir", "DVEfiles", "AN.DB", "work"}
DUMP_RE = re.compile(r"\$(?:dumpfile|dumpvars|vcdplusfile|vcdpluson|fsdbDumpfile|fsdbDumpvars)", re.IGNORECASE)


def ignored(_error: OSError) -> None:
    return None


def is_tb(path: Path, data: str) -> bool:
    if TB_NAME_RE.search(path.stem):
        return True
    return any(TB_NAME_RE.search(name) for name in MODULE_RE.findall(data))


def main() -> None:
    added = skipped_existing = skipped_unparsed = 0
    for current, dirs, files in os.walk(ROOT, onerror=ignored):
        folder = Path(current)
        dirs[:] = [name for name in dirs if name not in SKIP_DIRS]
        if folder.name == "Library":
            dirs[:] = []
        for filename in files:
            path = folder / filename
            if path.suffix.lower() not in HDL_SUFFIXES:
                continue
            try:
                data = path.read_text(encoding="utf-8-sig")
            except (OSError, UnicodeError):
                skipped_unparsed += 1
                continue
            if not is_tb(path, data):
                continue
            if DUMP_RE.search(data):
                skipped_existing += 1
                continue
            names = MODULE_RE.findall(data)
            top = next((name for name in names if TB_NAME_RE.search(name)), names[0] if names else None)
            ends = list(ENDMODULE_RE.finditer(data))
            if not top or not ends:
                skipped_unparsed += 1
                continue
            dump_name = f"{folder.name}_{top}.vcd".replace(" ", "_")
            block = (
                "    initial begin\n"
                f'        $dumpfile("{dump_name}");\n'
                f"        $dumpvars(0, {top});\n"
                "    end\n\n"
            )
            end = ends[0]
            data = data[:end.start()] + block + data[end.start():]
            path.write_text(data, encoding="utf-8", newline="\n")
            added += 1
    print(f"Added VCD capture to {added} testbenches; already had capture: {skipped_existing}; skipped/unparsed: {skipped_unparsed}.")


if __name__ == "__main__":
    main()
