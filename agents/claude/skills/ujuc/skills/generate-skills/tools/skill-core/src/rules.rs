//! Constants and allowed-value tables mirroring the skill frontmatter spec.
//!
//! Source: `agents/claude/skills/ujuc/skills/generate-skills/references/frontmatter-spec.md`.

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
];

/// Local extension: skills vendored with `git subtree` keep upstream files verbatim,
/// so their README.md is allowed (see `skills/CLAUDE.md`).
pub const SUBTREE_SKILLS: &[&str] = &["dual-brain"];

pub const ALLOWED_EFFORTS: &[&str] = &["low", "medium", "high", "xhigh", "max"];

pub const ALLOWED_CONTEXTS: &[&str] = &["fork"];

pub const ALLOWED_SHELLS: &[&str] = &["bash", "powershell"];

pub const RESERVED_NAME_PREFIXES: &[&str] = &["claude", "anthropic"];

pub const NAME_MAX_LEN: usize = 64;

/// Combined `description` + `when_to_use` character cap.
pub const DESCRIPTION_COMBINED_MAX: usize = 1536;

pub const BODY_LINE_WARN_THRESHOLD: usize = 500;
