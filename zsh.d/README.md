# Zsh Configuration Modules

Modular and optimized Zsh configuration with lazy loading for performance.

## Structure

```
zsh.d/
├── 00-env.zsh        # Environment variables and PATH
├── 10-history.zsh    # History configuration
├── 20-plugins.zsh    # Zimfw and plugins (includes completion)
├── 30-tools.zsh      # External tools (starship, fzf, zoxide, mise)
├── 40-aliases.zsh    # Aliases and functions
└── 99-local.zsh      # Local/work overrides
```

## Loading Order

Modules are loaded in numerical order (00 → 99) by `zshrc`:

1. **00-env.zsh**: Sets up `fpath`, `PATH`, and basic environment
2. **10-history.zsh**: Configures history behavior
3. **20-plugins.zsh**: Initializes Zim framework and plugins (includes completion via zimfw)
4. **30-tools.zsh**: Loads external tools with lazy loading
5. **40-aliases.zsh**: Defines aliases and utility functions
6. **99-local.zsh**: Sources local overrides (`.zshrc.work`, 1Password)

**Note**: Completion is handled by zimfw's `completion` module in `20-plugins.zsh`.

## Performance Optimizations

### Auto-compilation

All modules are automatically compiled to bytecode (`.zwc` files) on first load or when modified:
- **zshrc**: Main loader
- **zsh.d/*.zsh**: All modules  
- **.zcompdump**: Completion cache

This provides ~30-50% faster parsing. Manual compilation: `zcompile` or `compile-zsh.sh`.

### Lazy Loading

Tools that are expensive to initialize are wrapped in lazy-loading functions:

- **zoxide** (`z`, `zi`): Initializes on first use (~20-30ms saved)
- **mise**: Initializes on first use (~50-100ms saved), OR immediately if project config detected

### Eager Loading

Tools loaded immediately (needed for every session or fast enough):

- **starship**: Required for prompt
- **fzf**: Commonly used, fast initialization (~10ms)
- **zimfw plugins**: Core shell functionality

### Completion Caching

Completion is managed by zimfw's `completion` module, which automatically optimizes `compinit` for faster loading.

### Benchmarking

Use built-in tools to measure performance:

```bash
zbench          # Benchmark startup time (10 runs)
zprofile        # Show timing per module
zcompile        # Manually compile all configs
```

## Adding New Modules

1. Create file with naming pattern: `XX-name.zsh` (XX = load order)
2. Place in `zsh.d/` directory
3. No need to modify `zshrc` - auto-loaded

## Customization

### Personal Settings

Edit existing modules directly:
- Aliases → `40-aliases.zsh`
- Tools → `30-tools.zsh`

### Work-Specific Settings

Create `~/.zshrc.work` (gitignored):
```bash
# Company-specific aliases, PATH, etc.
export WORK_ENV="production"
alias deploy="..."
```

Automatically sourced by `99-local.zsh`.

## Testing Changes

```bash
# Syntax check
zsh -n ~/.config/dotrc/zshrc

# Test in new shell
zsh -c 'echo "Config loaded successfully"'

# Reload current shell
source ~/.config/dotrc/zshrc
```

## Troubleshooting

### Module not loading

Check file naming: `XX-name.zsh` format required.

### Tool not found

Check if lazy loading is active:
```bash
# Trigger initialization
z ~  # for zoxide
mise list  # for mise
```

### Slow startup

Add timing to debug:
```bash
# Temporarily add to zshrc
for config_file in ${DOTRCDIR}/zsh.d/*.zsh(N); do
    echo "Loading ${config_file:t}"
    time source "${config_file}"
done
```

## Reverting Changes

Backup available at: `${DOTRCDIR}/zshrc.backup`

```bash
cd ${DOTRCDIR}
mv zshrc.backup zshrc
rm -rf zsh.d/
```
