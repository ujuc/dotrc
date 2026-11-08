#!/usr/bin/env python3
"""Export the maintained Dual-Brain instructions as one portable prompt."""

import argparse
from pathlib import Path
import posixpath
import re
import sys
from urllib.parse import urlsplit


SOURCES = (
    ("SKILL.md", "dual-brain-workflow"),
    ("references/runtime.md", "dual-brain-runtime"),
    ("references/memory.md", "dual-brain-memory"),
)
PREAMBLE = """# Dual-Brain portable prompt

Paste or attach this document alongside your task request. Apply its workflow to that request within your host's available capabilities and governing instructions. This document does not install a skill, enable tools or agents, or grant additional permissions.

Generated from `SKILL.md`, `references/runtime.md`, and `references/memory.md` with `python3 scripts/export_portable.py`. Edit those source files and regenerate to keep this prompt in sync.
"""
LINK_TARGET = re.compile(r"(?<=\]\()[^\s)]+(?=\s|\))")


def skill_body(text):
    """Remove only a leading YAML frontmatter block, if present."""
    lines = text.splitlines(keepends=True)
    if not lines or lines[0].strip() != "---":
        return text
    for index, line in enumerate(lines[1:], 1):
        if line.strip() in ("---", "..."):
            return "".join(lines[index + 1:])
    raise ValueError("SKILL.md has unterminated YAML frontmatter")


def local_links_to_anchors(text, source):
    """Point links to included documents at their locations in the export."""
    anchors = dict(SOURCES)

    def replace(match):
        target = match.group()
        parsed = urlsplit(target)
        if parsed.scheme or parsed.netloc or not parsed.path or parsed.query:
            return target
        path = posixpath.normpath(posixpath.join(posixpath.dirname(source), parsed.path))
        if path not in anchors:
            return target
        # Subheading links still refer to the unchanged Markdown headings.
        return "#" + (parsed.fragment or anchors[path])

    return LINK_TARGET.sub(replace, text)


def build_portable(root):
    """Build deterministic output from the three complete source documents."""
    sections = [PREAMBLE.strip()]
    for source, anchor in SOURCES:
        text = (Path(root) / source).read_text(encoding="utf-8")
        if source == "SKILL.md":
            text = skill_body(text)
        text = local_links_to_anchors(text, source)
        sections.append(f'<a id="{anchor}"></a>\n\n{text.strip()}')
    return "\n\n---\n\n".join(sections) + "\n"


def main(argv=None):
    root = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=root / "PORTABLE.md",
                        help="output file (default: repository-root PORTABLE.md)")
    parser.add_argument("--check", action="store_true",
                        help="verify the output is current without writing it")
    args = parser.parse_args(argv)
    try:
        expected = build_portable(root).encode("utf-8")
        if args.check:
            if not args.output.is_file() or args.output.read_bytes() != expected:
                print(f"Portable prompt is missing or stale: {args.output}", file=sys.stderr)
                return 1
            print(f"Portable prompt is current: {args.output}")
        else:
            args.output.write_bytes(expected)
            print(f"Wrote portable prompt: {args.output}")
    except (OSError, ValueError) as error:
        print(f"Cannot export portable prompt: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
