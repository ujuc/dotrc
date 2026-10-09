#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
BIN=${WORKFLOW_HOOKS_BIN:-"$ROOT/agents/tools/workflow-hooks/target/debug/workflow-hooks"}
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

[ -x "$BIN" ] || fail "missing executable: $BIN"

result=$("$BIN" contract)
assert_jq "$result" '.artifacts.spec.path == "spec.md"' "contract is embedded"
assert_jq "$result" '.superpowers | has("adapted_from") | not' "Superpowers versions are not pinned"

home="$TMP/home"
mkdir -p "$home/.claude/skills/one" "$home/.claude/skills/two"
touch "$home/.claude/skills/one/SKILL.md" "$home/.claude/skills/two/SKILL.md"
result=$(printf '{}' | HOME="$home" "$BIN" cadence)
assert_jq "$result" '.message | contains("2개 스킬")' "cadence reports skill count"
date -u +%Y-%m-%d > "$home/.claude/.last_skill_improver_run"
result=$(printf '{}' | HOME="$home" "$BIN" cadence)
assert_jq "$result" 'has("message") | not' "fresh cadence stamp is silent"

result=$(printf '%s' '{"prompt":"문서를 업데이트해줘"}' | "$BIN" clarify)
assert_jq "$result" '.message | contains("업데이트/변경사항")' "clarify detects update wording"
result=$(printf '%s' '{"prompt":"문서를 읽어줘"}' | "$BIN" clarify)
assert_jq "$result" 'has("message") | not' "clarify ignores unrelated wording"

result=$(jq -n --argjson files '["/tmp/project/.research/research-demo.md"]' '{files:$files}' | "$BIN" annotation)
assert_jq "$result" '.message | contains("review")' "annotation detects research files"
result=$(jq -n --arg cwd '/tmp/project' --argjson files '["/tmp/project/spec.md"]' '{cwd:$cwd,files:$files}' | "$BIN" annotation)
assert_jq "$result" '.message | contains("review")' "annotation detects absolute canonical spec paths"
result=$(jq -n --argjson files '["/tmp/project/src/main.rs"]' '{files:$files}' | "$BIN" annotation)
assert_jq "$result" 'has("message") | not' "annotation ignores source files"

context_fixture="$TMP/context"
mkdir -p "$context_fixture/.research" "$context_fixture/.plans" "$context_fixture/.harness"
printf '# Product Demo\n' > "$context_fixture/spec.md"
printf '# Research Demo\n' > "$context_fixture/.research/research-demo.md"
printf '# Plan: demo\n' > "$context_fixture/.plans/plan-demo.md"
printf '# Legacy State\n' > "$context_fixture/.harness/legacy.md"
touch "$context_fixture/.plans/.implementing"
result=$(jq -n --arg cwd "$context_fixture" '{cwd:$cwd}' | "$BIN" context)
assert_jq "$result" '.message | contains("Product Demo") and contains("Research Demo") and contains("Plan: demo") and contains("implementation is active")' "context lists the complete active workflow"
assert_jq "$result" '.message | contains("Legacy .harness workflow state detected") and contains("never migrate it automatically")' "context warns about legacy workflow state"

result=$(jq -n --arg cwd "$context_fixture" --argjson files '["src/main.rs"]' '{cwd:$cwd,files:$files}' | "$BIN" typecheck)
assert_jq "$result" 'has("block") | not' "typecheck is inactive without implementation flag"
result=$(jq -n --arg cwd "$TMP/absent" '{cwd:$cwd}' | "$BIN" context)
assert_jq "$result" 'has("message") | not' "context ignores a missing workspace"

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
    PATH="$typecheck_fixture/bin:$PATH" "$BIN" typecheck)
assert_jq "$result" '.block and (.message | contains("fixture failure"))' "active typecheck returns blocking diagnostics"
if jq -n \
    --arg cwd "$typecheck_fixture" \
    '{hook_event_name:"PostToolUse",cwd:$cwd,tool_name:"Edit",tool_input:{file_path:"src/bad.py"}}' |
    PATH="$typecheck_fixture/bin:$PATH" "$BIN" hook >"$TMP/native-typecheck.out" 2>"$TMP/native-typecheck.err"; then
    fail "native hook accepted failing typecheck"
else
    status=$?
fi
[ "$status" -eq 2 ] || fail "native hook used the wrong blocking exit code"
grep -q 'fixture failure' "$TMP/native-typecheck.err" || fail "native hook omitted typecheck diagnostics"

result=$(jq -n \
    --arg cwd "$context_fixture" \
    '{hook_event_name:"SessionStart",source:"compact",cwd:$cwd}' | "$BIN" hook)
assert_jq "$result" '.hookSpecificOutput.hookEventName == "SessionStart" and (.hookSpecificOutput.additionalContext | contains("Research Demo"))' "native hook restores compacted context"
result=$(printf '%s' '{"hook_event_name":"UserPromptSubmit","prompt":"문서를 업데이트해줘"}' | "$BIN" hook)
assert_jq "$result" '.hookSpecificOutput.hookEventName == "UserPromptSubmit" and (.hookSpecificOutput.additionalContext | contains("업데이트/변경사항"))' "native hook clarifies prompts"
result=$(jq -n \
    --arg cwd "$context_fixture" \
    --arg command $'*** Begin Patch\n*** Update File: .plans/plan-demo.md\n@@\n-old\n+new\n*** End Patch' \
    '{hook_event_name:"PostToolUse",cwd:$cwd,tool_name:"apply_patch",tool_input:{command:$command}}' | "$BIN" hook)
assert_jq "$result" '.hookSpecificOutput.hookEventName == "PostToolUse" and (.hookSpecificOutput.additionalContext | contains("review"))' "native hook parses apply_patch paths"

declared="$TMP/declared"
mkdir -p "$declared/.research" "$declared/.plans"
printf '# Product Demo\n' > "$declared/spec.md"
printf '# Research Demo\n' > "$declared/.research/research-demo.md"
cat > "$declared/.plans/plan-demo.md" <<'EOF'
# Plan: demo

## Workflow Sources
- Product Spec: `spec.md`
- Research:
  - `.research/research-demo.md`
EOF
touch \
    "$declared/.plans/.implementing" \
    "$declared/.plans/.plan-demo.md.prev" \
    "$declared/.plans/.plan-demo.cycle" \
    "$declared/.plans/.verify-final-demo.md" \
    "$declared/.plans/.verify-1-build.md" \
    "$declared/.plans/.debug-1-build.md" \
    "$declared/.plans/.blocker-1-build.md" \
    "$declared/.plans/.verify-final-sibling.md"
result=$(jq -n \
    --arg cwd "$declared" \
    --arg plan '.plans/plan-demo.md' \
    --argjson item_slugs '["1-build"]' \
    '{cwd:$cwd,plan:$plan,item_slugs:$item_slugs}' | "$BIN" archive)
assert_jq "$result" '.moved == ["docs/specs/spec-demo.md","docs/research/research-demo.md","docs/plans/plan-demo.md"]' "archive reports the complete durable workflow"
test -f "$declared/docs/specs/spec-demo.md" || fail "product spec was not archived"
test -f "$declared/docs/research/research-demo.md" || fail "declared research was not archived"
test -f "$declared/docs/plans/plan-demo.md" || fail "declared plan was not archived"
test ! -e "$declared/.plans/.verify-1-build.md" || fail "item verifier was not cleaned"
test ! -e "$declared/.plans/.implementing" || fail "implementation flag was not cleaned"
test ! -e "$declared/.plans/.verify-final-demo.md" || fail "final verifier was not cleaned"
test -e "$declared/.plans/.verify-final-sibling.md" || fail "sibling feature verifier was removed"

legacy="$TMP/legacy"
mkdir -p "$legacy/.research" "$legacy/.plans"
printf '# Legacy Research\n' > "$legacy/.research/research-legacy.md"
printf '# Plan: legacy\n' > "$legacy/.plans/plan-legacy.md"
result=$(jq -n --arg cwd "$legacy" --arg plan '.plans/plan-legacy.md' '{cwd:$cwd,plan:$plan}' | "$BIN" archive)
assert_jq "$result" '.moved | length == 2' "legacy archive uses same-feature research"
test -f "$legacy/docs/research/research-legacy.md" || fail "legacy research was not archived"

no_research="$TMP/no-research"
mkdir -p "$no_research/.plans"
cat > "$no_research/.plans/plan-empty.md" <<'EOF'
# Plan: empty

## Workflow Sources
- Product Spec: None
- Research: None
EOF
result=$(jq -n --arg cwd "$no_research" --arg plan '.plans/plan-empty.md' '{cwd:$cwd,plan:$plan}' | "$BIN" archive)
assert_jq "$result" '.moved == ["docs/plans/plan-empty.md"]' "archive accepts explicit no-research plans"

make_full_archive_fixture() {
    local root=$1 feature=$2
    mkdir -p "$root/.research" "$root/.plans"
    printf '# Product %s\n' "$feature" > "$root/spec.md"
    printf '# Research %s\n' "$feature" > "$root/.research/research-$feature.md"
    cat > "$root/.plans/plan-$feature.md" <<EOF
# Plan: $feature

## Workflow Sources
- Product Spec: \`spec.md\`
- Research:
  - \`.research/research-$feature.md\`
EOF
}

for missing_kind in spec research; do
    missing_full="$TMP/missing-$missing_kind"
    feature="missing-$missing_kind"
    make_full_archive_fixture "$missing_full" "$feature"
    case "$missing_kind" in
        spec) rm "$missing_full/spec.md" ;;
        research) rm "$missing_full/.research/research-$feature.md" ;;
    esac
    if jq -n \
        --arg cwd "$missing_full" \
        --arg plan ".plans/plan-$feature.md" \
        '{cwd:$cwd,plan:$plan}' | "$BIN" archive >/dev/null 2>&1; then
        fail "archive accepted a missing $missing_kind source"
    fi
    test -f "$missing_full/.plans/plan-$feature.md" || fail "missing $missing_kind moved the plan"
    test ! -d "$missing_full/docs" || fail "missing $missing_kind created archive output"
done

invalid_source="$TMP/invalid-source"
mkdir -p "$invalid_source/.research" "$invalid_source/.plans"
printf '# Wrong Source\n' > "$invalid_source/.research/research-wrong.md"
cat > "$invalid_source/.plans/plan-invalid-source.md" <<'EOF'
# Plan: invalid-source

## Workflow Sources
- Product Spec: `.research/research-wrong.md`
- Research: None
EOF
if jq -n --arg cwd "$invalid_source" --arg plan '.plans/plan-invalid-source.md' '{cwd:$cwd,plan:$plan}' | "$BIN" archive >/dev/null 2>&1; then
    fail "archive accepted a source outside its canonical artifact path"
fi
test -f "$invalid_source/.plans/plan-invalid-source.md" || fail "invalid source moved the plan"

malformed="$TMP/malformed"
mkdir -p "$malformed/.plans"
cat > "$malformed/.plans/plan-malformed.md" <<'EOF'
# Plan: malformed

## Workflow Sources
- Research: None
- Product Spec: None
EOF
if jq -n --arg cwd "$malformed" --arg plan '.plans/plan-malformed.md' '{cwd:$cwd,plan:$plan}' | "$BIN" archive >/dev/null 2>"$TMP/malformed.err"; then
    fail "archive accepted malformed Workflow Sources"
fi
grep -q 'Workflow Sources must use exactly' "$TMP/malformed.err" || fail "malformed archive omitted syntax guidance"
test -f "$malformed/.plans/plan-malformed.md" || fail "malformed workflow sources moved the plan"

missing="$TMP/missing"
mkdir -p "$missing/.plans"
cat > "$missing/.plans/plan-missing.md" <<'EOF'
# Plan: missing

## Research Sources
- `.research/research-absent.md`
EOF
if jq -n --arg cwd "$missing" --arg plan '.plans/plan-missing.md' '{cwd:$cwd,plan:$plan}' | "$BIN" archive >/dev/null 2>&1; then
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
    '{cwd:$cwd,plan:$plan,item_slugs:$item_slugs}' | "$BIN" archive >/dev/null 2>&1; then
    fail "archive accepted an invalid item slug"
fi
test -f "$invalid_slug/.plans/plan-invalid-slug.md" || fail "invalid slug moved the plan"
test -f "$invalid_slug/.research/research-invalid-slug.md" || fail "invalid slug moved legacy research"

collision="$TMP/collision"
mkdir -p "$collision/.research" "$collision/.plans" "$collision/docs/plans"
printf '# Research Collision\n' > "$collision/.research/research-collision.md"
printf '# Existing\n' > "$collision/docs/plans/plan-collision.md"
printf '# Plan: collision\n' > "$collision/.plans/plan-collision.md"
if jq -n --arg cwd "$collision" --arg plan '.plans/plan-collision.md' '{cwd:$cwd,plan:$plan}' | "$BIN" archive >/dev/null 2>&1; then
    fail "archive overwrote a destination collision"
fi
test -f "$collision/.plans/plan-collision.md" || fail "collision moved the plan"
test -f "$collision/.research/research-collision.md" || fail "collision moved legacy research"

for collision_kind in specs research plans; do
    collision_full="$TMP/collision-$collision_kind"
    feature="collision-$collision_kind"
    make_full_archive_fixture "$collision_full" "$feature"
    case "$collision_kind" in
        specs) destination="docs/specs/spec-$feature.md" ;;
        research) destination="docs/research/research-$feature.md" ;;
        plans) destination="docs/plans/plan-$feature.md" ;;
    esac
    mkdir -p "$collision_full/$(dirname "$destination")"
    printf '# Existing\n' > "$collision_full/$destination"
    if jq -n \
        --arg cwd "$collision_full" \
        --arg plan ".plans/plan-$feature.md" \
        '{cwd:$cwd,plan:$plan}' | "$BIN" archive >/dev/null 2>&1; then
        fail "archive overwrote a $collision_kind destination collision"
    fi
    test -f "$collision_full/spec.md" || fail "$collision_kind collision moved the spec"
    test -f "$collision_full/.research/research-$feature.md" || fail "$collision_kind collision moved research"
    test -f "$collision_full/.plans/plan-$feature.md" || fail "$collision_kind collision moved the plan"
done

printf 'workflow hook tests: PASS\n'
