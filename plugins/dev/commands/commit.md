---
description: Create a git commit following Commitizen convention with validation and push
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git push:*), Bash(git branch:*), Bash(git log:*), Bash(npm run *), Bash(pnpm *), Bash(yarn *), Bash(bun *)
model: haiku
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Instructions

Execute **Workflow 1: Commit** from the `git-workflow` skill.
