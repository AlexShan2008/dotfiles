# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## 🚀 Quick Start

### First Time Setup (New Machine)

```bash
# One-command setup
chezmoi init --apply git@github.com:AlexShan2008/dotfiles.git
```

This will:
1. Clone this repo to `~/.local/share/chezmoi`
2. Prompt for machine-specific configuration (email, work/personal)
3. Apply all dotfiles to your home directory
4. Set correct file permissions automatically

### Manual Setup

```bash
# Install chezmoi
brew install chezmoi

# Initialize from this repo
chezmoi init git@github.com:AlexShan2008/dotfiles.git

# Preview changes
chezmoi diff

# Apply dotfiles
chezmoi apply
```

## 📦 What's Included

### Configuration Files
- **Shell**: `.zshrc` with Oh My Zsh git plugin, zoxide, starship
- **Git**: Git config, GitHub/GitLab settings, ignore patterns
- **Editors**: Cursor settings and keybindings
- **Terminal**: Starship prompt configuration, Ghostty config
- **Development**: Proto tools configuration

### Package Management
- **Brewfile**: Homebrew packages and applications
  - CLI tools: git, zsh, zoxide, difftastic, eza
  - Terminal: Warp, Ghostty
  - Editors: VS Code, Cursor, Zed
  - Development: Docker
  - Browsers: Chrome
  - Fonts: Fira Code

### Scripts
- `setup-macos.zsh`: Initial macOS setup script
- `update-dotfiles.zsh`: Daily update script for packages and configs

## 🔧 Daily Usage

### Editing Dotfiles

```bash
# Edit a file (opens in your $EDITOR)
chezmoi edit ~/.zshrc

# Or edit directly and update chezmoi
vim ~/.zshrc
chezmoi add ~/.zshrc

# Preview changes
chezmoi diff

# Apply changes
chezmoi apply
```

### Committing Changes

```bash
# Go to chezmoi source directory
chezmoi cd

# Git operations
git add .
git commit -m "feat: update config"
git push

# Or use git directly
cd ~/.local/share/chezmoi
git add .
git commit -m "feat: update config"
git push
```

### Syncing to Other Machines

```bash
# Update from remote
chezmoi update

# This is equivalent to:
# cd ~/.local/share/chezmoi
# git pull
# chezmoi apply
```

## 🔐 Machine-Specific Configuration

### Private Configuration (Not Tracked)

Create `~/.zshrc.local` for machine-specific secrets:

```bash
# Example: ~/.zshrc.local
export ANTHROPIC_AUTH_TOKEN="your-token"
export WORK_SPECIFIC_VAR="value"

# Work-specific aliases
alias work-vpn='connect-to-vpn'
```

This file is automatically sourced by `.zshrc` but ignored by chezmoi (via `.chezmoiignore`).

### Machine Type Configuration

On first `chezmoi init`, you'll be prompted:
- **Email**: Git email address
- **Is Work Machine**: Different configs for work vs personal

These values are stored in `~/.config/chezmoi/chezmoi.toml` and can be used in templates.

## 📁 Repository Structure

```
~/.local/share/chezmoi/          # Chezmoi source directory
├── .chezmoi.toml.tmpl           # Initial setup prompts
├── .chezmoiignore               # Files to ignore
├── README.md                    # This file
├── LICENSE                      # MIT License
├── Brewfile                     # Homebrew packages
├── .zshrc                       # Shell configuration
├── .config/                     # Application configs
│   ├── git/                     # Git configuration
│   ├── starship/                # Starship prompt
│   ├── ghostty/                 # Ghostty terminal config
│   ├── editor/                  # Editor settings
│   └── scripts/                 # Setup scripts
├── .proto/                      # Proto tool config
└── .ssh/                        # SSH configuration
```

## 🎯 Chezmoi Features Used

### File Attributes
- **Private files**: SSH config (permissions 600)
- **Executable scripts**: `setup-macos.zsh`, `update-dotfiles.zsh`

### Ignored Files
Files in `.chezmoiignore` are kept in the repo but not applied to your home directory:
- `README.md` (documentation only)
- `LICENSE` (documentation only)
- `.zshrc.local` (machine-specific secrets)

## 🛠️ Useful Commands

```bash
# View all managed files
chezmoi managed

# Check what would change
chezmoi status

# Show differences
chezmoi diff

# Apply specific file
chezmoi apply ~/.zshrc

# Remove a file from chezmoi
chezmoi forget ~/.someconfig

# Execute template for testing
chezmoi execute-template "{{ .chezmoi.hostname }}"

# View template data
chezmoi data
```

## 🔄 Migration from Other Dotfiles Management

If you're migrating from a different dotfiles setup:

```bash
# Add existing files to chezmoi
chezmoi add ~/.zshrc
chezmoi add ~/.gitconfig
chezmoi add ~/.config/starship/starship.toml

# Preview what would be added
chezmoi add --dry-run ~/.zshrc

# Bulk add directory
chezmoi add ~/.config/git
```

## 📚 Resources

- [Chezmoi Documentation](https://www.chezmoi.io/)
- [Chezmoi User Guide](https://www.chezmoi.io/user-guide/setup/)
- [Managing Machine-to-Machine Differences](https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/)

## 📝 License

MIT License - See [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Based on best practices from:
- [chezmoi.io](https://www.chezmoi.io/)
- [Bryan Lee](https://github.com/liby/dotfiles)
- Various dotfiles repositories in the community
