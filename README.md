<div>
  <h1 align="center">Dotfiles</h1>
</div>

## Overview

A collection of configuration files and automation scripts for quickly setting up a consistent development environment on macOS systems, including:

- Preconfigured settings for commonly used tools and applications
- Scripts to automate environment setup and updates
- An organized structure for easy customization and management

Key components:

- Homebrew
- Node.js
- Visual Studio Code
- iTerm2

These files are managed using a **Git Bare Repo**, which keeps the `$HOME` directory clean.

## Installation

### 1. Clone the repository:

```sh
git clone --bare git@github.com:AlexShan2008/dotfiles.git $HOME/.dotfiles
```

### 2. Set Up Alias

Add the following to your shell config file (e.g., .zshrc or .bashrc) and reload it:

```sh
alias df='$(command -v git) --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
source ~/.zshrc  # Use `source ~/.bashrc` if using Bash
```

### 3. Hide untracked files

To avoid seeing a large list of untracked files when using the `df` command, you can use the following command:

```sh
df config --local status.showUntrackedFiles no
```

If this is not set, running `df status` will list a large number of untracked files because not all files in `$HOME` are tracked by Git, and we don't intend to track all of them, which can make the output cluttered.

### 4. Checkout files

Use the following command to check out the files from the repository to your `$HOME` directory:

```sh
df checkout
```

If you encounter file conflicts, such as the following error:

```sh
error: The following untracked working tree files would be overwritten by checkout:
  .zshrc
Please move or remove them before you can switch branches.
Aborting
```

You can back up your existing configuration files first:

```sh
mkdir -p .dotfiles-backup
df checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .dotfiles-backup/{}
```

Then try checking out the files again:

```sh
df checkout
```

## Usage

You can use the following commands to manage your dotfiles:

```sh
df add <file>: Add file to the repository
df commit -m "message": Commit changes
df remote add origin <git_url>: Set up the remote repository
df push -u origin <branch>: Push commits to the remote repository and link the remote branch to the local branch
df push: Push changes to the remote repository
df pull: Pull updates from the remote repository
```

## Automated Setup (Recommended)

For quick environment setup on a new Mac, use the bootstrap script:

```sh
curl -o /tmp/setup-macos.zsh https://raw.githubusercontent.com/AlexShan2008/dotfiles/main/.config/scripts/setup-macos.zsh && chmod +x /tmp/setup-macos.zsh && /tmp/setup-macos.zsh
```

## Contribution

Feel free to submit Issues or Pull Requests for suggestions or improvements!

## Acknowledgement

This repository heavily borrows from [Bryan Lee](https://github.com/liby/dotfiles). A big thanks to him for his amazing work!
