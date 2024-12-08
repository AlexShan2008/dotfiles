#!/bin/zsh

set -e

DOTFILES_REPO_URL="https://github.com/AlexShan2008/dotfiles.git"
DOTFILES_BARE_DIR="$HOME/.dotfiles"
FONT_DOWNLOAD_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/InconsolataLGC.zip"
FONT_TEMP_DIR="/tmp/InconsolataLGC"
FONT_TARGET_DIR="$HOME/Library/Fonts"

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
  log "INFO" "Installing Oh My Zsh..."
  
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    log "INFO" "Oh My Zsh is already installed, skipping..."
  else
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi

  log "INFO" "Installing Zsh plugins..."
  local plugins=("zsh-autosuggestions" "zsh-completions" "fast-syntax-highlighting")
  local plugin_url_base="https://github.com/zsh-users"
  local plugin_dir="$HOME/.zsh/plugins"

  mkdir -p "$plugin_dir"
  for plugin in "${plugins[@]}"; do
    if [[ ! -d "$plugin_dir/$plugin" ]]; then
      git clone "${plugin_url_base}/${plugin}.git" "$plugin_dir/$plugin"
    fi
  done
}

install_fonts() {
  log "INFO" "Installing Inconsolata LGC Nerd Font..."

  if ls "${FONT_TARGET_DIR}"/*InconsolataLGCNerdFontMono* 1> /dev/null 2>&1; then
    log "INFO" "Fonts already installed, skipping..."
    return
  fi

  mkdir -p "${FONT_TEMP_DIR}"
  curl -L "$FONT_DOWNLOAD_URL" -o "/tmp/InconsolataLGC.zip"
  unzip "/tmp/InconsolataLGC.zip" -d "$FONT_TEMP_DIR"
  cp "${FONT_TEMP_DIR}"/*InconsolataLGCNerdFontMono*.ttf "$FONT_TARGET_DIR"
  rm -rf "/tmp/InconsolataLGC.zip" "$FONT_TEMP_DIR"

  log "INFO" "Fonts installed successfully."
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

main() {
  check_macos
  print_banner
#   restore_dotfiles
#   setup_ohmyzsh
#   setup_gpg_agent
#   install_fonts
#   install_homebrew
#   log "INFO" "Setup completed successfully!"
}

main "$@"
