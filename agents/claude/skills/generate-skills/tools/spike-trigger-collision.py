#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["pyyaml"]
# ///
"""Spike: does TypeSafe (Jev) judge Korean skill triggers well enough to detect collisions?

One request per utterance, one Noul per skill. Two or more skills above the
threshold is a collision; a result differing from `expected` is a mismatch.

    TYPESAFE_API_KEY=... ./spike-trigger-collision.py [--threshold 0.6]
    ./spike-trigger-collision.py --dry-run   # no network: parse skills, print first payload
"""

import argparse
import json
import os
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

import yaml

SKILLS_DIR = Path(__file__).resolve().parents[2]
API_URL = "https://api.typesafe.ai/v1/systemone"

# (utterance, skills that SHOULD trigger). Probes marked "collision probe" are
# the pairs that past trigger-tuning commits had to disambiguate.
CASES: list[tuple[str, set[str]]] = [
    ("커밋해줘", {"commit"}),
    ("CLAUDE.md 업데이트해줘", {"generate-agent-docs"}),
    ("커밋하면서 CLAUDE.md도 같이 갱신해줘", {"commit"}),  # collision probe
    ("플랜 만들어줘", {"annotate-plan"}),
    ("기획서 만들어줘", {"spec-planner"}),  # collision probe vs annotate-plan
    ("플랜대로 구현해", {"implement-plan"}),
    ("기획부터 구현까지 해줘", {"multi-agent-orchestrator"}),
    ("done 기준 먼저 정하자", {"sprint-contract-negotiator"}),
    ("스킬 평가해줘", {"waza"}),
    ("스킬 개선해줘", {"skill-improver"}),
    ("스킬 테스트해줘", {"waza"}),  # collision probe vs skill-improver
    ("디자인 검수해줘", {"frontend-design-evaluator"}),
    ("실행 중인 앱 QA해줘", {"qa-evaluator"}),
    ("이 글 AI 티 제거해줘", {"humanizer"}),
    ("이 프롬프트 리뷰해줘", {"prompting-assist"}),
    ("gemma로 번역해", {"gemma"}),
    ("코드베이스 조사해줘", {"deep-read"}),
    ("이 함수 뭐하는지 설명해줘", set()),  # deep-read explicitly excludes this
    ("오늘 날씨 어때?", set()),
]


def load_skills() -> dict[str, str]:
    skills = {}
    for path in sorted(SKILLS_DIR.glob("*/SKILL.md")):
        _, frontmatter, _ = path.read_text(encoding="utf-8").split("---", 2)
        meta = yaml.safe_load(frontmatter)
        text = f"{meta['description']} {meta.get('when_to_use', '')}".strip()
        skills[meta.get("name", path.parent.name)] = text
    return skills


def build_payload(utterance: str, skills: dict[str, str]) -> dict:
    return {
        "model": "jev-latest",
        "state": {"user_message": utterance},
        "questions": {
            name: {
                "type": "noul",
                "instructions": (
                    "A coding assistant has a skill with the description below. "
                    "Should the assistant invoke this skill to handle `user_message`?\n\n"
                    f"Skill description: {desc}"
                ),
            }
            for name, desc in skills.items()
        },
    }


def ask(payload: dict, api_key: str) -> dict[str, float]:
    req = urllib.request.Request(
        API_URL,
        data=json.dumps(payload).encode(),
        headers={"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"},
    )
    for attempt in range(4):
        try:
            with urllib.request.urlopen(req, timeout=30) as res:
                answers = json.load(res)["answers"]
                return {name: a["noul"] for name, a in answers.items()}
        except urllib.error.HTTPError as e:
            if e.code in (429, 529) and attempt < 3:
                time.sleep(2**attempt)
                continue
            sys.exit(f"HTTP {e.code}: {e.read().decode(errors='replace')}")
    raise AssertionError("unreachable")


def verdict(probs: dict[str, float], expected: set[str], threshold: float) -> tuple[str, set[str]]:
    hits = {name for name, p in probs.items() if p >= threshold}
    if hits == expected:
        return "OK", hits
    return ("COLLISION" if len(hits) > 1 else "MISS"), hits


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--threshold", type=float, default=0.6)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    skills = load_skills()
    unknown = set().union(*(e for _, e in CASES)) - skills.keys()
    assert not unknown, f"CASES reference missing skills: {unknown}"
    assert verdict({"a": 0.9, "b": 0.8}, {"a"}, 0.5)[0] == "COLLISION"
    assert verdict({"a": 0.9, "b": 0.1}, {"a"}, 0.5)[0] == "OK"
    assert verdict({"a": 0.2}, {"a"}, 0.5)[0] == "MISS"

    if args.dry_run:
        print(f"{len(skills)} skills: {', '.join(skills)}")
        print(json.dumps(build_payload(CASES[0][0], skills), ensure_ascii=False, indent=2)[:1200])
        return

    api_key = os.environ.get("TYPESAFE_API_KEY") or sys.exit("TYPESAFE_API_KEY is not set")
    bad = 0
    for utterance, expected in CASES:
        started = time.monotonic()
        probs = ask(build_payload(utterance, skills), api_key)
        ms = (time.monotonic() - started) * 1000
        status, _ = verdict(probs, expected, args.threshold)
        bad += status != "OK"
        top = sorted(probs.items(), key=lambda kv: -kv[1])[:3]
        shown = "  ".join(f"{n}={p:.2f}" for n, p in top)
        print(f"[{status:9}] {utterance}  (expect {sorted(expected) or '-'}, {ms:.0f}ms)\n            {shown}")
    print(f"\n{len(CASES) - bad}/{len(CASES)} OK at threshold {args.threshold}")
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
