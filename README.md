# Dotfiles

My personal dotfiles for various tools, helping me set up and maintain a consistent development environment across machines.

## Included Configurations

- Homebrew
- Node.js
- Visual Studio Code
- iTerm2 

## Installation

1. Clone the repository:
```bash
git clone git@github.com:AlexShan2008/dotfiles.git ~/.dotfiles
```

2. Install Homebrew (if not already installed):
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

3. Install dependencies using Homebrew Bundle:
```bash
cd ~/.dotfiles
brew bundle
```

4. Run the installation script:
```bash
./install.sh
```

