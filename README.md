<h1 align="center">Dotfiles</h1>

Welcome to my personal dotfiles repository!

This collection of configuration files and scripts helps me quickly set up and maintain a consistent development environment across different machines, especially macOS systems. It includes configurations for various tools, terminal setups, and utility scripts to streamline my workflow.

## Features

- Configurations for commonly used tools and applications
- Scripts to automate environment setup
- Organized structure for easy management and customization

## Getting Started

To use these dotfiles on a new machine, simply clone the repository and follow the setup instructions [below](#setup).

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
