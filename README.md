# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Quick Start (New Machine)

```bash
curl -fsLS https://raw.githubusercontent.com/AlexShan2008/dotfiles/main/install.sh | sh
```

> Requires [Homebrew](https://brew.sh/) to be installed first.

This single command will:

1. Install chezmoi via Homebrew
2. Clone this repo
3. Prompt for machine-specific configuration (email, work/personal)
4. Install Xcode Command Line Tools, Homebrew, and packages
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

- CLI: git, git-lfs, zsh, zoxide, difftastic, eza, mas
- Terminal: Ghostty
- Prompt: Starship
- Mac App Store: Xcode, Xnip
- Editors: Cursor, Zed
- Development: Docker, OrbStack
- Design: Figma
- AI: ChatGPT, Claude
- Network: Clash Verge Rev
- Security: Bitwarden
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
| `20-install-packages`  | on Brewfile change | `brew bundle`              |
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

- **Email**: Git email address
- **Is Work Machine**: Toggles work vs personal settings

Stored in `~/.config/chezmoi/chezmoi.toml`.

### Private Configuration

Create `~/.zshrc.local` for secrets (sourced by `.zshrc`, ignored by chezmoi):

```bash
export ANTHROPIC_AUTH_TOKEN="your-token"
export WORK_SPECIFIC_VAR="value"
```

## Repository Structure

```
dotfiles/
├── .chezmoiroot              # Points to home/
├── .chezmoi.toml.tmpl         # Setup prompts (email, work machine)
├── .chezmoiignore             # Ignore rules
├── install.sh                 # Bootstrap script
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
