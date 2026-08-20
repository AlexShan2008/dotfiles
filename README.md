# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Quick Start (New Machine)

```bash
curl -fsLS https://raw.githubusercontent.com/alxshan/dotfiles/main/install.sh | sh
```

> One-shot setup. On first run, a macOS dialog will appear to install Xcode Command Line Tools — click Install and wait.

This single command will:

1. Install chezmoi (official installer, no admin rights needed)
2. Clone this repo and prompt for machine-specific configuration (email, work machine)
3. Install Xcode Command Line Tools (macOS dialog, if missing)
4. Install Homebrew and packages from Brewfile
5. Set up Oh My Zsh with plugins
6. Install development tools (proto, Node.js, pnpm, Rust)
7. Apply all dotfiles to your home directory

## What's Included

### Configuration Files

- **Shell**: `.zshrc` with zsh plugins, zoxide, starship prompt
- **Git**: Global config with GitHub/GitLab identity includes
- **Editors**: Cursor settings
- **Terminal**: Ghostty config, Starship prompt
- **Development**: Proto tools configuration
- **SSH**: SSH client config

### Packages (Brewfile)

- CLI: git, git-lfs, awscli, vercel-cli, zsh, zoxide, difftastic, eza, mas
- Terminal: Ghostty
- Prompt: Starship
- Mac App Store: Xcode, Xnip, Bitwarden
- Editors: Cursor, Zed, Sublime Merge
- Development: OrbStack
- Design: Figma
- Network: Clash Verge Rev
- Productivity: Bob
- Communication: Slack, Zoom, Telegram
- Browsers: Chrome
- Fonts: Fira Code

### Lifecycle Scripts

chezmoi automatically runs setup scripts at the right time:

| Script                 | Trigger            | Purpose                    |
| ---------------------- | ------------------ | -------------------------- |
| `01-install-xcode-clt` | once               | Xcode Command Line Tools   |
| `10-install-homebrew`  | once               | Homebrew installation      |
| `20-install-packages`  | on Brewfile change | phased brew/cask/mas sync  |
| `30-setup-ohmyzsh`     | once               | Oh My Zsh + plugins        |
| `80-install-dev-tools` | once               | proto, Node.js, pnpm, Rust |
| `90-configure-macos`   | on change          | macOS system preferences   |
| `99-final-message`     | on change          | Post-setup instructions    |

## Daily Usage

```bash
# Edit a managed file
chezmoi edit ~/.zshrc

# Preview changes
chezmoi diff

# Apply changes
chezmoi apply

# Pull and apply latest from remote
chezmoi update

# See all managed files
chezmoi managed

# Go to source directory
chezmoi cd
```

## Machine-Specific Configuration

### Prompted Values

On first `chezmoi init`, you'll be prompted for:

- **Email**: Git email address → set as the global git identity
- **Is Work Machine**: When `true`, loads the GitLab work config
  (`~/Code/GitLab` repos get SSH-signed commits)

Stored in `~/.config/chezmoi/chezmoi.toml`.

### Work Machine Identity

The work email itself stays out of this repo. On work machines, create
`~/.config/git/gitlab.local.config` (not managed by chezmoi, safe from
`chezmoi apply`):

```ini
[user]
  email = you@company.com
```

### Private Configuration

Create `~/.zshrc.local` for secrets (sourced by `.zshrc`, ignored by chezmoi):

```bash
export ANTHROPIC_AUTH_TOKEN="your-token"
export WORK_SPECIFIC_VAR="value"
```

## CI

GitHub Actions runs shellcheck and a zsh syntax check on every push, plus a
full `chezmoi apply` + `chezmoi verify` dry run on Linux (macOS-only steps are
skipped there).

## Repository Structure

```
dotfiles/
├── .chezmoiroot              # Points to home/
├── .chezmoi.toml.tmpl         # Setup prompts (email, work machine)
├── .chezmoiignore             # Ignore rules
├── .github/workflows/ci.yml   # Lint + apply/verify CI
├── install.sh                 # Bootstrap script (installs chezmoi only)
├── Brewfile                   # Homebrew packages
├── README.md
├── LICENSE
└── home/                      # chezmoi source directory
    ├── .chezmoiscripts/       # Lifecycle scripts
    ├── dot_zshrc
    ├── private_dot_ssh/
    ├── dot_proto/
    └── dot_config/
        ├── git/
        ├── ghostty/
        ├── starship/
        └── editor/
```

## Resources

- [chezmoi documentation](https://www.chezmoi.io/)
- [chezmoi user guide](https://www.chezmoi.io/user-guide/setup/)

## License

MIT License - See [LICENSE](LICENSE) file for details.
