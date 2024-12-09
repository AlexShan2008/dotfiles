#!/bin/zsh

set -e

DOTFILES_REPO_URL="https://github.com/AlexShan2008/dotfiles.git"
DOTFILES_BARE_DIR="$HOME/.dotfiles"

log() {
  local level="$1"
  shift
  echo "[$level] $@"
}

check_macos() {
  if [[ "$OSTYPE" != "darwin"* ]]; then
    log "ERROR" "This script is only for macOS."
    exit 1
  fi
}

is_apple_silicon() {
  [[ "$(/usr/bin/uname -m)" == "arm64" ]]
}

print_banner() {
  clear

  cat << EOF
===========================================================
                                                           
              █████╗ ██╗     ███████╗██╗  ██╗              
              ██╔══██╗██║     ██╔════╝╚██╗██╔╝             
              ███████║██║     █████╗   ╚███╔╝              
              ██╔══██║██║     ██╔══╝   ██╔██╗              
              ██║  ██║███████╗███████╗██╔╝ ██╗             
              ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝                           
                                                           
===========================================================
                ** SYSTEM CONFIGURATION **
===========================================================
                                
        ⚙️  Preparing: Alex's Setup Environment: macOS
                                
===========================================================
            The setup will commence in 3 seconds...
===========================================================
EOF

  sleep 3
  
  echo "                 Times up! Here we start!                  "
  echo "-----------------------------------------------------------"

  cd $HOME
}

restore_dotfiles() {
  log "INFO" "Restoring dotfiles..."
  
  if [[ -d "$DOTFILES_BARE_DIR" ]]; then
    log "INFO" "Dotfiles already restored, skipping..."
  else
    git clone --bare "$DOTFILES_REPO_URL" "$DOTFILES_BARE_DIR"
    git --git-dir="$DOTFILES_BARE_DIR" --work-tree="$HOME" config --local status.showUntrackedFiles no
    git --git-dir="$DOTFILES_BARE_DIR" --work-tree="$HOME" checkout --force
  fi

  git --git-dir="$DOTFILES_BARE_DIR" --work-tree="$HOME" remote set-url origin "git@github.com:AlexShan2008/dotfiles.git"
}

setup_ohmyzsh() {
  log "INFO" "Starting Oh My Zsh setup..."

  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    log "INFO" "Oh My Zsh is already installed, skipping installation."
  else
    log "INFO" "Oh My Zsh is not installed, proceeding with installation..."
    if ! sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
      log "ERROR" "Failed to install Oh My Zsh. Exiting setup."
      return 1
    fi
    log "INFO" "Oh My Zsh installed successfully."
  fi

  local ZSH_PLUGINS_PREFIX="$HOME/.zsh/plugins"
  local plugins=(
    "zsh-users/zsh-autosuggestions"
    "zsh-users/zsh-completions"
    "zdharma-continuum/fast-syntax-highlighting"
  )

  log "INFO" "Preparing to install Zsh plugins..."
  mkdir -p "$ZSH_PLUGINS_PREFIX"

  for plugin_repo in "${plugins[@]}"; do
    local plugin_name=$(basename "$plugin_repo")
    local plugin_path="$ZSH_PLUGINS_PREFIX/$plugin_name"

    if [[ -d "$plugin_path" ]]; then
      log "INFO" "Plugin $plugin_name is already installed, skipping."
    else
      log "INFO" "Cloning plugin $plugin_name from https://github.com/$plugin_repo..."
      if ! git clone "https://github.com/$plugin_repo.git" "$plugin_path"; then
        log "ERROR" "Failed to clone plugin $plugin_name. Skipping this plugin."
        continue
      fi
      log "INFO" "Plugin $plugin_name installed successfully."
    fi
  done

  log "INFO" "Oh My Zsh setup complete!"
}

install_homebrew() {
  log "INFO" "Installing Homebrew..."
  
  if command -v brew > /dev/null; then
    log "INFO" "Homebrew already installed. Updating..."
    brew update
  else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  eval "$(/opt/homebrew/bin/brew shellenv)"
}

install_homebrew_packages() {
  log "INFO" "Installing Homebrew packages..."

  local brewfile="$HOME/Brewfile"

  if [[ ! -f "$brewfile" ]]; then
    log "INFO" "No Brewfile found at $brewfile"
    log "INFO" "Skipping package installation"
    return 0
  fi

  local current_locale=$(defaults read NSGlobalDomain AppleLocale 2>/dev/null || echo en_CN)

  local brew_bundle_status

  # Temporarily set locale to en_US for mas-cli compatibility
  # Reference: https://github.com/mas-cli/mas/blob/main/Sources/mas/Controllers/ITunesSearchAppStoreSearcher.swift#L18-L22
  defaults write NSGlobalDomain AppleLocale -string en_US

  # Run brew bundle
  if brew bundle --file="$brewfile"; then
    log "INFO" "Brewfile successfully installed"
    brew_bundle_status=0
  else
    log "ERROR" "Brewfile installation failed"
    log "ERROR" "You may want to run 'brew bundle' manually later"
    brew_bundle_status=1
  fi

  # Restore original locale setting
  defaults write NSGlobalDomain AppleLocale -string "$current_locale"

  return $brew_bundle_status
}

install_nodejs() {
  log "INFO" "==========================================================="
  log "INFO" "               Setting up Node.js Environment              "
  log "INFO" "-----------------------------------------------------------"

  if command -v proto > /dev/null; then
    echo "proto is already installed, skipping..."
  else
    echo "Installing proto..."
    if ! curl -fsSL https://moonrepo.dev/install/proto.sh | bash -s -- --no-profile --yes; then
      echo "Error: Failed to install proto. Exiting..." >&2
      return 1
    fi
  fi

  log "INFO" "Installing Node.js LTS and pnpm..."

  if ! proto install node; then
    log "ERROR" "Failed to install Node.js. Exiting..." >&2
    return 1
  fi

  log "INFO" "Node.js Version: $(proto run node -- --version)"
  log "INFO" "* Installing pnpm..."

  if ! proto install pnpm; then
    log "ERROR" "Failed to install pnpm. Exiting..." >&2
    return 1
  fi
  log "INFO" "pnpm installed successfully!"
  log "INFO" "pnpm Version: $(proto run pnpm -- --version)"

  log "INFO" "Configuring npm global packages..."
  
  export NPM_CONFIG_PREFIX="$HOME/.npm-global"
  
  mkdir -p "$NPM_CONFIG_PREFIX"

  local npm_global_pkgs=(
    @upimg/cli
    0x
    npm-why
  )

  for pkg in "${npm_global_pkgs[@]}"; do
    log "INFO" "Installing: $pkg"
    if ! proto run npm -- install -g "$pkg"; then
      log "WARNING" "Failed to install $pkg" >&2
    fi
  done

  log "INFO" "Node.js Environment Setup Complete!"
}

install_rust() {
  log "INFO" "==========================================================="
  log "INFO" "                      Install Rust                         "
  log "INFO" "-----------------------------------------------------------"

  if command -v rustc > /dev/null; then
    echo "Rust is already installed, skipping..."
  else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  fi
}

reload_zshrc() {
  log "INFO" "==========================================================="
  log "INFO" "                   Reload Alex's Environment zshrc                  "
  log "INFO" "-----------------------------------------------------------"

  if [[ ! -f "$HOME/.zshrc" ]]; then
    log "ERROR" "No .zshrc file found. Exiting."
    return 1
  fi

  log "WARNING" "Removing .zcompdump files in $HOME..."
  rm -f "$HOME/.zcompdump"*

  log "INFO" "Sourcing .zshrc..."
  autoload -Uz compinit && compinit -i

  log "INFO" "Reloading zsh configuration..."
  exec zsh
}

setup_iterm2() {
  log "INFO" "==========================================================="
  log "INFO" "                   Setting up iTerm2...                    "
  log "INFO" "-----------------------------------------------------------"

  if [ ! -d "/Applications/iTerm.app" ]; then
    log "ERROR" "iTerm2 is not installed, skipping configuration..."
    return 0
  fi

  local iterm2_default_config="$HOME/Library/Preferences/com.googlecode.iterm2.plist"

  if [ ! -f "$iterm2_default_config" ]; then
    log "ERROR" "Default iTerm2 config file not found: $iterm2_default_config"
    return 0
  fi

  log "INFO" "Setting iTerm2 to use its default config location..."

  defaults write -app iTerm PrefsCustomFolder ""
  defaults write -app iTerm LoadPrefsFromCustomFolder -bool false

  log "INFO" "iTerm2 configuration completed using default settings."
}


display_todo_list() {
  log "INFO" "==========================================================="
  log "INFO" "      Alex's Environment Setup Completed Successfully!     "
  log "INFO" "==========================================================="
  log "INFO" "                                                           "
  log "INFO" "  Do not forget to run these things:                       "
  log "INFO" "                                                           "
  log "INFO" "    - NPM login                                            "
  log "INFO" "    - Setup .npmrc                                         "
  log "INFO" "    - Setup iTerm2 or Warp                                 "
  log "INFO" "    - Setup launchd for notes                              "
  log "INFO" "    - Create a case-sensitive volume                       "
  log "INFO" "                                                           "
  log "INFO" "==========================================================="
}

finish() {
  cd $HOME
  display_todo_list
}

main() {
  check_macos
  print_banner
  restore_dotfiles
  setup_ohmyzsh
  install_homebrew
  install_homebrew_packages
  install_nodejs
  install_rust
  reload_zshrc
  setup_iterm2
  finish
}

main "$@"
