//! Constants and allowed-value tables mirroring the skill frontmatter spec.
//!
//! Source: `agents/claude/skills/generate-skills/references/frontmatter-spec.md`.

use regex::Regex;
use std::sync::OnceLock;

pub fn is_kebab_case(s: &str) -> bool {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| Regex::new(r"^[a-z0-9]+(-[a-z0-9]+)*$").unwrap())
        .is_match(s)
}

pub const ALLOWED_KEYS: &[&str] = &[
    "name",
    "description",
    "when_to_use",
    "model",
    "disable-model-invocation",
    "allowed-tools",
    "disallowed-tools",
    "argument-hint",
    "arguments",
    "user-invocable",
    "effort",
    "context",
    "agent",
    "background",
    "hooks",
    "paths",
    "shell",
    // Agent Skills spec fields (agentskills.io); Claude Code accepts them but
    // does not act on their contents.
    "metadata",
    "license",
    "compatibility",
    "group",
];

/// Upstream accepts any `/model` value or `inherit`; this list mirrors the
/// local model-assignment convention (skills/CLAUDE.md) plus `inherit`.
pub const ALLOWED_MODELS: &[&str] = &["opus", "sonnet", "haiku", "inherit"];

/// Local extension: every SKILL.md must declare exactly one of these slugs
/// in its `group` field. The catalog table in `skills/README.md` mirrors it.
/// See `frontmatter-spec.md` "group" section.
pub const ALLOWED_GROUPS: &[&str] = &[
    "planning",
    "analysis",
    "build",
    "verify",
    "docs",
    "writing",
    "llm",
    "meta",
];

pub const ALLOWED_EFFORTS: &[&str] = &["low", "medium", "high", "xhigh", "max"];

pub const ALLOWED_CONTEXTS: &[&str] = &["fork"];

pub const ALLOWED_SHELLS: &[&str] = &["bash", "powershell"];

pub const RESERVED_NAME_PREFIXES: &[&str] = &["claude", "anthropic"];

pub const NAME_MAX_LEN: usize = 64;

/// Combined `description` + `when_to_use` character cap.
pub const DESCRIPTION_COMBINED_MAX: usize = 1536;

pub const BODY_LINE_WARN_THRESHOLD: usize = 500;
