//! Skill validation core: frontmatter parsing and validation rules.
//!
//! Parses YAML frontmatter as a raw [`serde_yaml::Mapping`] and runs a suite
//! of checks against it. Invalid values (e.g. `model: "gpt-4"`) do not fail
//! parsing — they surface as findings so the caller can report them cleanly.

pub mod frontmatter;
pub mod rules;
pub mod validate;

pub use frontmatter::Frontmatter;
pub use validate::{Finding, Severity, ValidationReport, validate_skill};
