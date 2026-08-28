---
name: commit
description: Review current Git changes, exclude secrets or risky hunks, infer the repository's commit convention, and create a concise professional commit. Use when the user asks to commit changes or invokes a commit workflow.
---

# Safe Commit

Create one safe, logical commit without disturbing unrelated work.

## Workflow

## 1. Inspect the repository

* Confirm the directory is a Git repository.
* Determine whether `HEAD` exists. When it does, run `git rev-list --count HEAD` and `git log --oneline -n 15`.
* Run `git status --short`, `git diff --stat`, and `git diff`. If anything is staged, also run `git diff --cached`.
* Identify the intended logical change. If the working tree contains unrelated changes, preserve them and ask before creating multiple commits.

## 2. Choose the commit format

* Follow a clear convention in the existing history.
* For the first commit or inconsistent history, use Conventional Commits.
* Prefer `<type>: <subject>`. Add `(scope)` only when it clarifies a package or subsystem, especially in a monorepo.

## 3. Stage and review the safe subset

* Stage only changes that belong to the intended commit; never revert, overwrite, or disturb unrelated work.
* Review the complete staged diff with `git diff --cached`.
* Run `ai-commit-scan --staged` when available; otherwise perform the same review manually. Use `--all` only when broader inspection is necessary.
* Review every finding. Unstage unsafe files or hunks, then inspect the staged diff again.
* Never commit secrets, credentials, tokens, private keys, passwords, cookies, session data, real `.env` values, or PII.
* Exclude unjustified security regressions such as removed auth checks, dangerous shell execution, insecure deserialization, or relaxed security settings.
* Exclude unintended local-only or generated files.
* Never reveal raw secret values. If no safe changes remain, do not commit.

## 4. Write the message

* Keep the subject concise, specific, and professional. State the problem solved or outcome before implementation detail.
* Match the repository's language and style; otherwise use clean, minimal Conventional Commits.
* Omit the body unless it adds essential context. If used, keep it to at most 100 characters, excluding required footers.
* Avoid vague wording such as `update`, `changes`, `fix stuff`, or `WIP`.
* Never add `Co-authored-by`.

## 5. Commit and report

* Commit only the reviewed staged changes.
* Verify the resulting commit and remaining working-tree state.
* Report the commit hash and final message, excluded files or hunks with reasons, and the security checks performed.
