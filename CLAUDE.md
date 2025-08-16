# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles configuration repository (`dotrc`) that manages shell configurations, application settings, and development environment setup for macOS. The repository contains configuration files and setup scripts for various CLI tools and applications.

## Architecture & Structure

### Core Components

- **Shell Configuration**: `zshrc`, `zshenv`, `zimrc` - Zsh shell setup with ZimFW framework
- **Application Configs**: `zed/`, `starship.toml`, `batrc`, `tigrc`, `ghosttyrc` - Settings for various development tools
- **Terminal Apps**: Ghostty terminal configuration with Nord theme
- **Git Configuration**: `gitmessage` - Git commit message template
- **Claude Configuration**: `claude/CLAUDE.md` - Global Claude Code instructions (symlinked to ~/.claude/CLAUDE.md)

### File Linking Strategy

Most configuration files are designed to be symlinked from their target locations to this repository:

- `ln -sf ${DOTRCDIR}/starship.toml ${XDG_CONFIG_HOME}/starship.toml`
- `ln -sf ${DOTRCDIR}/zed/settings.json ${XDG_CONFIG_HOME}/zed/settings.json`
- `ln -sf ${DOTRCDIR}/ghosttyrc ${XDG_CONFIG_HOME}/ghostty/config`
- `ln -sf ${DOTRCDIR}/claude/CLAUDE.md ${HOME}/.claude/CLAUDE.md`
- See README.md for complete setup instructions

## Common Tasks

### Testing Configuration Changes

- **Shell configs**: Source files directly or restart terminal
  ```bash
  source ~/.config/dotrc/zshrc
  ```
- **Starship**: Changes take effect immediately
- **Application configs**: Restart the specific application

### Managing Environment Variables

- Global environment variables go in `zshenv`
- Shell-specific settings go in `zshrc`
- Work-specific overrides can be added to `~/.zshrc.work` (sourced from zshrc:54)

### Updating Tools

Use the built-in update function defined in `zshrc:56-63`:

```bash
update  # Alias for update_system function
```

## Tool Stack

### Shell Environment

- **Zsh** with **ZimFW** framework (zimrc configuration)
- **Starship** prompt (starship.toml configuration)
- **mise-en-place** for language version management
- **zoxide** for smart directory navigation
- **fzf** for fuzzy finding

### Development Tools

- **Zed** editor (settings.json with Catppuccin theme, VSCode keybindings)
- **Ghostty** terminal (ghosttyrc with Nord Wave theme, Cascadia Code font)
- **bat** as enhanced cat (batrc configuration)
- **eza** as enhanced ls (aliased in zshrc:70-72)
- **tig** for git interface (tigrc configuration)
- **git-delta** for enhanced git diffs
- **ollama** for local LLM (gemma3, qwen3 models)
- **Claude Code** CLI tool for AI-assisted development

### Key Aliases & Functions

- `ls` → `eza --icons=auto --group-directories-first --git`
- `ll` → `eza -l --git --icons=auto`
- `lt` → `eza -l --tree --icons=auto`
- `cat` → `bat`
- `vi` → `vim`
- `update` → runs brew update/upgrade, zimfw update, npm upgrade, cleanup
- `bws` → `brew search`
- `bwi` → `brew install`

## Installation & Setup

### Prerequisites

1. Install Homebrew and authenticate with 1Password SSH agent
2. Install GitHub CLI: `brew install gh && gh auth login`
3. Install basic tools: `brew install gh starship bat eza zoxide fzf vim git git-delta tig mise ollama`
4. Install applications: `brew install --cask 1password 1password-cli claude raycast zed visual-studio-code ghostty`
5. Clone this repo: `gh repo clone ujuc/dotrc ${HOME}/.config/dotrc`
6. Link zshenv: `ln -sf ${HOME}/.config/dotrc/zshenv ${HOME}/.zshenv`

### Environment Variables

- `DOTRCDIR` should point to this repository location
- `XDG_CONFIG_HOME` used for application configs
- `ZDOTDIR` for Zsh configuration directory

## Configuration Guidelines

### Shell Scripts

- Follow existing zsh syntax and patterns
- Use `(( $+commands[tool] ))` for command existence checks (see zshrc:41, 49)
- Maintain compatibility with ZimFW module system

### Application Settings

- **Zed**: Uses Catppuccin Macchiato theme, VSCode keybindings, format on save enabled
- **Ghostty**: Nord Wave theme, Cascadia Code + D2Coding fonts, zsh integration
- **Starship**: Configured with status, sudo, time, and memory_usage modules enabled
- **Git**: Uses zdiff3 merge style, delta pager, commit template from gitmessage
- **Claude Code**: Global instructions symlinked from claude/CLAUDE.md
- **Ollama**: Configured with gemma3 and qwen3 models for local LLM

### File Management

- Preserve existing symlink structure
- Test configuration changes before committing
- Follow the commit message template in `gitmessage`

## Troubleshooting

### Common Issues

- If ZimFW modules fail to load, run `zimfw install` manually
- If symlinks are broken, re-run the appropriate `ln -sf` command from README.md
- For shell issues, check `zshenv` is properly linked to `~/.zshenv`

### Debugging Shell Configuration

1. Check if `zshenv` is sourced: `echo $DOTRCDIR`
2. Verify ZimFW installation: `zimfw info`
3. Test individual module loading in clean shell

This repository focuses on configuration management rather than code development, so most changes involve editing configuration files and testing them in the appropriate applications.

## Notes

- Repository includes comprehensive Claude Code instructions in `claude/` directory with modular documentation
- Work-specific shell configurations can be added to `~/.zshrc.work` (automatically sourced)
- Font configuration includes Cascadia Code, D2Coding, IBM Plex, Noto, and Nanum font families
