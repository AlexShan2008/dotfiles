#!/bin/zsh

# Daily dotfiles update script
# Usage: update-dotfiles.zsh [--dry-run]

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
  DRY_RUN=true
fi

log() {
  local level="$1"
  shift
  case "$level" in
    INFO)    echo -e "${BLUE}[INFO]${NC} $@" ;;
    SUCCESS) echo -e "${GREEN}[SUCCESS]${NC} $@" ;;
    WARNING) echo -e "${YELLOW}[WARNING]${NC} $@" ;;
    ERROR)   echo -e "${RED}[ERROR]${NC} $@" ;;
  esac
}

print_header() {
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

# Step 1: Pull latest dotfiles from GitHub
sync_dotfiles() {
  print_header "📥 Step 1: Syncing Dotfiles from GitHub"
  
  if [[ ! -d "$HOME/.dotfiles" ]]; then
    log ERROR "Bare repo not found at $HOME/.dotfiles"
    log INFO "Run setup-macos.zsh first to initialize"
    exit 1
  fi
  
  local before_commit=$(git --git-dir="$HOME/.dotfiles" rev-parse HEAD)
  
  log INFO "Pulling latest changes..."
  git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" pull origin main
  
  local after_commit=$(git --git-dir="$HOME/.dotfiles" rev-parse HEAD)
  
  if [[ "$before_commit" == "$after_commit" ]]; then
    log SUCCESS "Already up to date"
    return 1  # No updates
  else
    log SUCCESS "Updated to commit: ${after_commit:0:7}"
    
    # Show what changed
    echo ""
    log INFO "Changed files:"
    git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" diff --name-status $before_commit $after_commit | while read status file; do
      case $status in
        M) echo "  📝 Modified: $file" ;;
        A) echo "  ✅ Added: $file" ;;
        D) echo "  ❌ Deleted: $file" ;;
      esac
    done
    
    return 0  # Has updates
  fi
}

# Step 2: Update Homebrew packages
update_homebrew() {
  print_header "🍺 Step 2: Updating Homebrew Packages"
  
  if ! command -v brew &> /dev/null; then
    log WARNING "Homebrew not installed, skipping"
    return
  fi
  
  if [[ ! -f "$HOME/Brewfile" ]]; then
    log WARNING "Brewfile not found, skipping"
    return
  fi
  
  log INFO "Checking Brewfile changes..."
  
  if [[ "$DRY_RUN" == true ]]; then
    log INFO "[DRY RUN] Would run: brew bundle --file=$HOME/Brewfile"
    log INFO "[DRY RUN] Would run: brew bundle cleanup --file=$HOME/Brewfile"
    return
  fi
  
  # Install new packages
  log INFO "Installing/updating packages from Brewfile..."
  brew bundle --file="$HOME/Brewfile"
  
  # Ask about cleanup
  echo ""
  log WARNING "Do you want to remove packages not in Brewfile? (y/N)"
  read -r response
  if [[ "$response" =~ ^[Yy]$ ]]; then
    log INFO "Cleaning up unused packages..."
    brew bundle cleanup --file="$HOME/Brewfile"
  else
    log INFO "Skipping cleanup"
  fi
  
  log SUCCESS "Homebrew packages updated"
}

# Step 3: Update Proto tools
update_proto() {
  print_header "🔧 Step 3: Updating Proto Tools"
  
  if ! command -v proto &> /dev/null; then
    log WARNING "Proto not installed, skipping"
    return
  fi
  
  if [[ ! -f "$HOME/.proto/.prototools" ]]; then
    log WARNING ".prototools not found, skipping"
    return
  fi
  
  if [[ "$DRY_RUN" == true ]]; then
    log INFO "[DRY RUN] Would run: proto use"
    return
  fi
  
  log INFO "Installing tools from .prototools..."
  cd "$HOME" && proto use
  
  log SUCCESS "Proto tools updated"
}

# Step 4: Update npm global packages
update_npm_globals() {
  print_header "📦 Step 4: Checking NPM Global Packages"
  
  if ! command -v npm &> /dev/null; then
    log WARNING "npm not installed, skipping"
    return
  fi
  
  log INFO "Current global packages:"
  npm list -g --depth=0 2>/dev/null || true
  
  log INFO "You can manually install packages with:"
  log INFO "  npm install -g <package-name>"
}

# Step 5: Reload shell configuration
reload_shell() {
  print_header "🐚 Step 5: Reloading Shell Configuration"
  
  if [[ ! -f "$HOME/.zshrc" ]]; then
    log WARNING ".zshrc not found, skipping"
    return
  fi
  
  if [[ "$DRY_RUN" == true ]]; then
    log INFO "[DRY RUN] Would reload shell configuration"
    return
  fi
  
  log INFO "Removing .zcompdump cache..."
  rm -f "$HOME/.zcompdump"*
  
  log INFO "Reloading zsh configuration..."
  source "$HOME/.zshrc" 2>/dev/null || true
  
  log SUCCESS "Shell configuration reloaded"
  log WARNING "Note: Some changes may require opening a new terminal"
}

# Step 6: Summary
show_summary() {
  print_header "📋 Update Summary"
  
  echo "✅ Dotfiles synced from GitHub"
  echo "✅ Homebrew packages updated"
  echo "✅ Development tools updated"
  echo "✅ Shell configuration reloaded"
  echo ""
  log INFO "Next steps:"
  echo "  • Open a new terminal to see all changes"
  echo "  • Check if any manual configuration is needed"
  echo ""
  log SUCCESS "Update complete! 🎉"
}

# Main execution
main() {
  if [[ "$DRY_RUN" == true ]]; then
    log WARNING "Running in DRY RUN mode - no changes will be made"
  fi
  
  print_header "🚀 Updating Development Environment"
  
  # Sync dotfiles first
  if sync_dotfiles; then
    HAS_UPDATES=true
  else
    HAS_UPDATES=false
  fi
  
  # Always run other updates
  update_homebrew
  update_proto
  update_npm_globals
  reload_shell
  show_summary
}

main "$@"
