#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
CORE="$ROOT/agents/hooks/workflow-hooks.sh"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

assert_jq() {
    local input=$1 filter=$2 label=$3
    jq -e "$filter" <<<"$input" >/dev/null || fail "$label"
}

[ -x "$CORE" ] || fail "missing executable core: $CORE"

home="$TMP/home"
mkdir -p "$home/.claude/skills/one" "$home/.claude/skills/two"
touch "$home/.claude/skills/one/SKILL.md" "$home/.claude/skills/two/SKILL.md"
result=$(printf '{}' | HOME="$home" "$CORE" cadence)
assert_jq "$result" '.message | contains("2개 스킬")' "cadence reports skill count"
date -u +%Y-%m-%d > "$home/.claude/.last_skill_improver_run"
result=$(printf '{}' | HOME="$home" "$CORE" cadence)
assert_jq "$result" 'has("message") | not' "fresh cadence stamp is silent"

result=$(printf '%s' '{"prompt":"문서를 업데이트해줘"}' | "$CORE" clarify)
assert_jq "$result" '.message | contains("업데이트/변경사항")' "clarify detects update wording"
result=$(printf '%s' '{"prompt":"문서를 읽어줘"}' | "$CORE" clarify)
assert_jq "$result" 'has("message") | not' "clarify ignores unrelated wording"

result=$(jq -n --argjson files '["/tmp/project/.research/research-demo.md"]' '{files:$files}' | "$CORE" annotation)
assert_jq "$result" '.message | contains("review")' "annotation detects research files"
result=$(jq -n --argjson files '["/tmp/project/src/main.rs"]' '{files:$files}' | "$CORE" annotation)
assert_jq "$result" 'has("message") | not' "annotation ignores source files"

context_fixture="$TMP/context"
mkdir -p "$context_fixture/.research" "$context_fixture/.plans"
printf '# Research Demo\n' > "$context_fixture/.research/research-demo.md"
printf '# Plan: demo\n' > "$context_fixture/.plans/plan-demo.md"
result=$(jq -n --arg cwd "$context_fixture" '{cwd:$cwd}' | "$CORE" context)
assert_jq "$result" '.message | contains("Research Demo") and contains("Plan: demo")' "context lists active artifacts"

result=$(jq -n --arg cwd "$context_fixture" --argjson files '["src/main.rs"]' '{cwd:$cwd,files:$files}' | "$CORE" typecheck)
assert_jq "$result" 'has("block") | not' "typecheck is inactive without implementation flag"

typecheck_fixture="$TMP/typecheck"
mkdir -p "$typecheck_fixture/.plans" "$typecheck_fixture/src" "$typecheck_fixture/bin"
touch "$typecheck_fixture/.plans/.implementing" "$typecheck_fixture/src/bad.py"
cat > "$typecheck_fixture/bin/mypy" <<'EOF'
#!/usr/bin/env bash
echo 'bad.py:1: error: fixture failure'
exit 1
EOF
chmod +x "$typecheck_fixture/bin/mypy"
result=$(jq -n --arg cwd "$typecheck_fixture" --argjson files '["src/bad.py"]' '{cwd:$cwd,files:$files}' |
    PATH="$typecheck_fixture/bin:$PATH" "$CORE" typecheck)
assert_jq "$result" '.block and (.message | contains("fixture failure"))' "active typecheck returns blocking diagnostics"

declared="$TMP/declared"
mkdir -p "$declared/.research" "$declared/.plans"
printf '# Research Demo\n' > "$declared/.research/research-demo.md"
cat > "$declared/.plans/plan-demo.md" <<'EOF'
# Plan: demo

## Research Sources
- `.research/research-demo.md`
EOF
touch \
    "$declared/.plans/.implementing" \
    "$declared/.plans/.plan-demo.md.prev" \
    "$declared/.plans/.plan-demo.cycle" \
    "$declared/.plans/.verify-final-demo.md" \
    "$declared/.plans/.verify-1-build.md" \
    "$declared/.plans/.debug-1-build.md" \
    "$declared/.plans/.blocker-1-build.md"
result=$(jq -n \
    --arg cwd "$declared" \
    --arg plan '.plans/plan-demo.md' \
    --argjson item_slugs '["1-build"]' \
    '{cwd:$cwd,plan:$plan,item_slugs:$item_slugs}' | "$CORE" archive)
assert_jq "$result" '.moved | length == 2' "archive reports moved plan and research"
test -f "$declared/docs/research/research-demo.md" || fail "declared research was not archived"
test -f "$declared/docs/plans/plan-demo.md" || fail "declared plan was not archived"
test ! -e "$declared/.plans/.verify-1-build.md" || fail "item verifier was not cleaned"
test ! -e "$declared/.plans/.implementing" || fail "implementation flag was not cleaned"

legacy="$TMP/legacy"
mkdir -p "$legacy/.research" "$legacy/.plans"
printf '# Legacy Research\n' > "$legacy/.research/research-legacy.md"
printf '# Plan: legacy\n' > "$legacy/.plans/plan-legacy.md"
result=$(jq -n --arg cwd "$legacy" --arg plan '.plans/plan-legacy.md' '{cwd:$cwd,plan:$plan}' | "$CORE" archive)
assert_jq "$result" '.moved | length == 2' "legacy archive uses same-feature research"
test -f "$legacy/docs/research/research-legacy.md" || fail "legacy research was not archived"

no_research="$TMP/no-research"
mkdir -p "$no_research/.plans"
cat > "$no_research/.plans/plan-empty.md" <<'EOF'
# Plan: empty

## Research Sources
None
EOF
result=$(jq -n --arg cwd "$no_research" --arg plan '.plans/plan-empty.md' '{cwd:$cwd,plan:$plan}' | "$CORE" archive)
assert_jq "$result" '.moved == ["docs/plans/plan-empty.md"]' "archive accepts explicit no-research plans"

missing="$TMP/missing"
mkdir -p "$missing/.plans"
cat > "$missing/.plans/plan-missing.md" <<'EOF'
# Plan: missing

## Research Sources
- `.research/research-absent.md`
EOF
if jq -n --arg cwd "$missing" --arg plan '.plans/plan-missing.md' '{cwd:$cwd,plan:$plan}' | "$CORE" archive >/dev/null 2>&1; then
    fail "archive accepted a missing declared source"
fi
test -f "$missing/.plans/plan-missing.md" || fail "failed archive moved the plan"

invalid_slug="$TMP/invalid-slug"
mkdir -p "$invalid_slug/.research" "$invalid_slug/.plans"
printf '# Research Invalid Slug\n' > "$invalid_slug/.research/research-invalid-slug.md"
printf '# Plan: invalid-slug\n' > "$invalid_slug/.plans/plan-invalid-slug.md"
if jq -n \
    --arg cwd "$invalid_slug" \
    --arg plan '.plans/plan-invalid-slug.md' \
    --argjson item_slugs '["bad/slug"]' \
    '{cwd:$cwd,plan:$plan,item_slugs:$item_slugs}' | "$CORE" archive >/dev/null 2>&1; then
    fail "archive accepted an invalid item slug"
fi
test -f "$invalid_slug/.plans/plan-invalid-slug.md" || fail "invalid slug moved the plan"
test -f "$invalid_slug/.research/research-invalid-slug.md" || fail "invalid slug moved legacy research"

collision="$TMP/collision"
mkdir -p "$collision/.research" "$collision/.plans" "$collision/docs/plans"
printf '# Research Collision\n' > "$collision/.research/research-collision.md"
printf '# Existing\n' > "$collision/docs/plans/plan-collision.md"
printf '# Plan: collision\n' > "$collision/.plans/plan-collision.md"
if jq -n --arg cwd "$collision" --arg plan '.plans/plan-collision.md' '{cwd:$cwd,plan:$plan}' | "$CORE" archive >/dev/null 2>&1; then
    fail "archive overwrote a destination collision"
fi
test -f "$collision/.plans/plan-collision.md" || fail "collision moved the plan"
test -f "$collision/.research/research-collision.md" || fail "collision moved legacy research"

printf 'workflow hook tests: PASS\n'
