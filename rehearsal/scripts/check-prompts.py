#!/usr/bin/env python3
"""Check that every <!-- prompt: stepNN --> block in storybook.md equals rehearsal/prompts/stepNN.md."""
import pathlib
import re
import sys

root = pathlib.Path(__file__).resolve().parents[2]
book = (root / "storybook.md").read_text()
ok = True
for m in re.finditer(r"<!-- prompt: (\S+) -->\n```text\n(.*?)\n```", book, re.S):
    name, text = m.group(1), m.group(2)
    f = root / "rehearsal" / "prompts" / f"{name}.md"
    if not f.exists() or f.read_text().rstrip("\n") != text:
        print(f"MISMATCH {name}")
        ok = False
    else:
        print(f"ok {name}")
sys.exit(0 if ok else 1)
