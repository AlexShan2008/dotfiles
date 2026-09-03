# Dotfiles

Personal macOS setup managed with [chezmoi](https://www.chezmoi.io/). It keeps shell, Git, SSH, applications, development tools, macOS preferences, and personal AI skills reproducible across machines.

## 1. Install a New Mac

You need macOS, an internet connection, and an administrator account for Homebrew.

```bash
curl -fsLS https://raw.githubusercontent.com/alexshanx/dotfiles/main/install.sh | sh
```

During setup:

- Enter the Git email for this machine and choose whether it is a work machine.
- Approve the Xcode Command Line Tools dialog if it appears.
- Enter your administrator password if Homebrew requests it.

The installer handles chezmoi, Homebrew packages (including the Codex app), shell plugins, development tools, Claude Code, managed files, and macOS preferences. When it finishes:

```bash
exec zsh
chezmoi status
```

SSH keys, GPG keys, npm authentication, and other credentials are intentionally left for manual setup.

## 2. Sync an Existing Mac

Pull the latest repository version and apply it:

```bash
chezmoi update
```

To review remote changes before applying them:

```bash
chezmoi git -- pull --ff-only
chezmoi diff
chezmoi apply
```

An unrestricted apply may run lifecycle scripts. A [Brewfile](Brewfile) change, for example, triggers package installation. When only one file needs updating, apply that target directly:

```bash
chezmoi apply ~/.zshrc
```

## 3. Change and Publish Dotfiles

Edit a managed file, review the generated change, and apply it locally:

```bash
chezmoi edit ~/.zshrc
chezmoi diff ~/.zshrc
chezmoi apply ~/.zshrc
```

Add a new file, or capture an intentional change made directly to an existing target:

```bash
chezmoi add ~/.config/example/config.toml
chezmoi re-add ~/.zshrc
```

Commit from the source repository:

```bash
chezmoi cd
git status
git add -A
git commit -m "chore: update dotfiles"
git push
exit
```

## 4. Keep Machine-Specific Data Local

The initial Git email and work-machine choice are stored in `~/.config/chezmoi/chezmoi.toml`; inspect them with `chezmoi data`.

On a work machine, create `~/.config/git/gitlab.local.config` for repositories under `~/Code/GitLab`:

```ini
[user]
  email = you@company.com
```

Put secrets and machine-only environment variables in `~/.zshrc.local`. It is loaded automatically and ignored by chezmoi:

```bash
export ANTHROPIC_AUTH_TOKEN="your-token"
export WORK_SPECIFIC_VAR="value"
```

## 5. Manage Personal AI Skills

`~/.agents/skills` is the only source of truth. Claude receives one compatibility symlink per skill under `~/.claude/skills`.

To manage a newly created local skill:

```bash
chezmoi add ~/.agents/skills/<skill-name>
ln -s ../../.agents/skills/<skill-name> ~/.claude/skills/<skill-name>
chezmoi add ~/.claude/skills/<skill-name>
```

Restart the relevant AI tool after adding or renaming a skill.

## 6. Resolve Local Changes

When chezmoi reports that a destination changed since it was last written:

1. Inspect it with `chezmoi diff <path>`.
2. Keep the local version with `chezmoi re-add <path>`, or restore the managed version with `chezmoi apply <path>`.
3. Use `chezmoi apply --force <path>` only after reviewing that specific target; avoid forcing the entire repository.

## 7. Automated Toolchain Updates

[Renovate](https://docs.renovatebot.com/) updates the tools pinned in [`~/.proto/.prototools`](home/dot_proto/dot_prototools). Install the Renovate GitHub App for this repository once; [`renovate.json`](renovate.json) handles the rest. Other repository dependencies, including Homebrew packages and GitHub Actions, stay outside this automation.

Renovate checks on the first day of each month, waits 14 days after a release, groups the proto-managed tools into one pull request, and merges it after CI passes. Node.js stays on its configured major release line so that an odd-numbered, non-LTS release is not selected automatically. Failed CI leaves the pull request open for investigation.

After an automated update is merged, apply it locally with the normal sync command:

```bash
chezmoi update
```

## Repository Map

| Path | Purpose |
| --- | --- |
| [install.sh](install.sh) | New-machine entry point |
| [Brewfile](Brewfile) | Homebrew packages and applications |
| [home](home) | Files mapped into the home directory |
| [home/.chezmoiscripts](home/.chezmoiscripts) | Bootstrap and lifecycle automation |
| [renovate.json](renovate.json) | Monthly proto toolchain updates |

Useful inspection commands: `chezmoi status`, `chezmoi diff`, `chezmoi managed`, `chezmoi data`, and `chezmoi cd`.

GitHub Actions checks shell scripts, Zsh syntax, and a Linux apply/verify dry-run. Licensed under the [MIT License](LICENSE).
