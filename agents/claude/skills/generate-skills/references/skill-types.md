# Skill Types by Domain

> 9 domain categories for classifying skills by purpose. Use alongside patterns.md (structural axis) to identify both **what** a skill does and **how** it should be structured.

> Source: [Lessons from Building Claude Code: How We Use Skills](https://x.com/trq212/article/2033949937936085378) — Thariq (@trq212), 2026-03-18

---

## Quick Reference

| # | Type | Core Purpose |
|---|------|-------------|
| 1 | Library & API Reference | Teach correct usage of libraries, CLIs, SDKs |
| 2 | Product Verification | Test and verify code behavior end-to-end |
| 3 | Data Fetching & Analysis | Connect to data/monitoring stacks |
| 4 | Business Process & Team Automation | Automate repetitive team workflows |
| 5 | Code Scaffolding & Templates | Generate framework boilerplate |
| 6 | Code Quality & Review | Enforce code quality and review standards |
| 7 | CI/CD & Deployment | Fetch, push, deploy code |
| 8 | Runbooks | Investigate symptoms, produce structured reports |
| 9 | Infrastructure Operations | Routine maintenance with guardrails |

---

## 1. Library & API Reference

Explain how to correctly use a library, CLI, or SDK — especially internal ones or common ones Claude struggles with. Typically includes reference code snippets and a gotchas list.

**Examples:** billing-lib (edge cases, footguns), internal-platform-cli (subcommands with examples), frontend-design (design system guidance)

## 2. Product Verification

Describe how to test or verify code is working. Often paired with tools like Playwright, tmux, etc. Include scripts for programmatic assertions at each step. Consider having Claude record output video.

**Examples:** signup-flow-driver (headless browser verification), checkout-verifier (Stripe test cards), tmux-cli-driver (interactive CLI testing)

## 3. Data Fetching & Analysis

Connect to data and monitoring stacks. Include credentials helpers, dashboard IDs, and common query workflows.

**Examples:** funnel-query (event joins + canonical user_id), cohort-compare (retention/conversion comparison), grafana (datasource UIDs, problem → dashboard lookup)

## 4. Business Process & Team Automation

Automate repetitive workflows into one command. Usually simple instructions but may depend on other skills or MCPs. Saving results in log files helps consistency across runs.

**Examples:** standup-post (aggregates tracker + GitHub + Slack), create-ticket (enforces schema + post-creation workflow), weekly-recap (merged PRs + closed tickets + deploys)

## 5. Code Scaffolding & Templates

Generate framework boilerplate for codebase functions. Combine with composable scripts. Especially useful when scaffolding has natural language requirements beyond pure code.

**Examples:** new-\<framework\>-workflow (service/handler scaffolding), new-migration (template + gotchas), create-app (auth + logging + deploy pre-wired)

## 6. Code Quality & Review

Enforce org code quality and review standards. Can include deterministic scripts for robustness. Consider running automatically via hooks or GitHub Actions.

**Examples:** adversarial-review (subagent critique loop), code-style (styles Claude defaults poorly on), testing-practices (what and how to test)

## 7. CI/CD & Deployment

Help fetch, push, and deploy code. May reference other skills to collect data.

**Examples:** babysit-pr (monitor → retry flaky CI → resolve conflicts → auto-merge), deploy-\<service\> (build → smoke → gradual rollout → auto-rollback), cherry-pick-prod (worktree → cherry-pick → PR)

## 8. Runbooks

Take a symptom (Slack thread, alert, error signature), walk through multi-tool investigation, produce a structured report.

**Examples:** \<service\>-debugging (symptoms → tools → query patterns), oncall-runner (alert → investigation → finding), log-correlator (request ID → cross-system log pull)

## 9. Infrastructure Operations

Routine maintenance and operational procedures — some involving destructive actions that benefit from guardrails.

**Examples:** \<resource\>-orphans (find → notify → soak → confirm → cleanup), dependency-management (org approval workflow), cost-investigation (bill spike analysis with specific query patterns)

---

## Choosing a Type

The best skills fit cleanly into one category. Skills that straddle several tend to be confusing — consider splitting them. Use this list to identify gaps in your org's skill coverage.
