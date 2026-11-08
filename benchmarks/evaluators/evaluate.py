#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCENARIOS = ROOT / "benchmarks" / "scenarios"


def load_scenario(scenario_id: str) -> dict:
    path = SCENARIOS / f"{scenario_id}.yaml"
    return json.loads(path.read_text(encoding="utf-8"))


def read_repo(repo: Path, glob: str) -> str:
    chunks = []
    # Explicit memory checks are allowed; implementation scans never consume
    # skill snapshots, tests, caches, or advisory project memory as code evidence.
    memory_target = glob == ".dual-brain/MEMORY.md"
    excluded = {".git", ".benchmark-skill", ".dual-brain", "tests", "test", "__pycache__", "node_modules", ".pytest_cache"}
    for path in sorted(repo.glob(glob)):
        relative = path.relative_to(repo)
        if not memory_target and (any(part in excluded for part in relative.parts)
                                  or any(part.startswith(".") for part in relative.parts)
                                  or path.name.startswith("test_") or path.name.endswith("_test.py")):
            continue
        # Do not let a workspace symlink import unrelated evidence.
        if path.is_symlink() or not path.resolve().is_relative_to(repo.resolve()):
            continue
        if path.is_file():
            chunks.append(f"\n--- {path.relative_to(repo)} ---\n")
            chunks.append(path.read_text(encoding="utf-8", errors="ignore"))
    return "".join(chunks)


def check_patterns(repo: Path, transcript: str, config: dict) -> tuple[bool, list[str]]:
    # Regex source checks are structural smoke checks, not execution evidence.
    # Transcript wording is diagnostic only and cannot decide correctness.
    messages: list[str] = []
    passed = True
    for item in config.get("required_patterns", []):
        haystack = transcript if item.get("target") == "transcript" else read_repo(repo, item.get("glob", "**/*"))
        if not re.search(item["pattern"], haystack, re.MULTILINE | re.IGNORECASE):
            if item.get("target") != "transcript":
                passed = False
            messages.append(f"missing required pattern: {item['pattern']}")
        else:
            messages.append(f"found required pattern: {item['pattern']}")
    for item in config.get("forbidden_patterns", []):
        haystack = transcript if item.get("target") == "transcript" else read_repo(repo, item.get("glob", "**/*"))
        if re.search(item["pattern"], haystack, re.MULTILINE | re.IGNORECASE):
            if item.get("target") != "transcript":
                passed = False
            messages.append(f"found forbidden pattern: {item['pattern']}")
        else:
            messages.append(f"forbidden pattern absent: {item['pattern']}")
    if any(item.get("target") == "transcript" for key in ("required_patterns", "forbidden_patterns") for item in config.get(key, [])):
        messages.append("Transcript patterns are diagnostic only; source patterns are structural checks, not behavioral proof.")
    return passed, messages


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--scenario", required=True)
    parser.add_argument("--mode", required=True, choices=["main", "trap", "memory"])
    parser.add_argument("--repo", required=True)
    parser.add_argument("--transcript", required=True)
    args = parser.parse_args()

    scenario = load_scenario(args.scenario)
    repo = Path(args.repo)
    transcript = Path(args.transcript).read_text(encoding="utf-8", errors="ignore")
    config = scenario.get("evaluation", {}).get(args.mode, {})
    passed, messages = check_patterns(repo, transcript, config)
    print(json.dumps({"passed": passed, "messages": messages}, indent=2))


if __name__ == "__main__":
    main()
