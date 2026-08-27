---
name: commit
description: Review current Git changes, exclude secrets or risky hunks, infer the repository's commit convention, and create a concise professional commit. Use when the user asks to commit changes or invokes a commit workflow.
---

# Safe Commit

Use this skill when the user asks to commit the current changes.

## Workflow

1. Inspect the repository first.
   - Run `git rev-list --count HEAD` to determine whether this is the first commit.
   - Run `git log --oneline -n 15` to infer the active commit style.
   - Run `git status --short`, `git diff --stat`, `git diff`, and `git diff --cached` if anything is staged.

2. Determine the commit format.
   - If the repository already has a clear convention, follow it.
   - If this is the first commit, use Conventional Commits.
   - If the existing history is inconsistent, prefer Conventional Commits.

3. Review the staged changes for sensitive or risky content.
   - If `ai-commit-scan` is available, run `ai-commit-scan --staged` before proposing a commit.
   - If the command is unavailable, perform the same review manually from the staged diff.
   - If the scan reports findings, review them carefully and exclude risky files or hunks.
   - Do not echo raw secret values back to the user.
   - Use `ai-commit-scan --all` only when broader inspection is necessary.

4. Perform a mandatory security and sensitive-content review.
   - Never commit secrets, access tokens, API keys, private keys, passwords, cookies, session material, or `.env` files containing real values.
   - Exclude PII and credentials.
   - Exclude files or hunks that introduce meaningful security risk, such as hardcoded secrets, removed auth checks, dangerous shell execution, insecure deserialization, or unjustified security-setting relaxations.
   - Exclude local-only or generated files unless they are clearly intended to be versioned.
   - If sensitive or risky content is found, do not stage it. Tell the user which paths or hunks were excluded and why.

5. Stage only the safe subset.
   - Do not revert or disturb unrelated user changes.
   - Prefer one logical commit. If the working tree contains unrelated changes, explain that and ask before splitting.

6. Write the commit message.
   - Keep it concise, professional, and specific.
   - Prioritize the problem solved first, then the action taken.
   - Avoid filler and vague phrasing.
   - Never add `Co-authored-by`.
   - If Conventional Commits apply, use them cleanly and minimally.

7. Commit and report.
   - Commit only the safe staged changes.
   - Report the final commit message, any excluded files or hunks, and notable security checks performed.

If there are no safe changes to commit, do not create a commit.
