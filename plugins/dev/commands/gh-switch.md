---
description: Switch active GitHub account. Usage: /gh-switch <username>
allowed-tools: Bash(gh auth:*)
---

## Context

- Current auth status: !`gh auth status 2>&1`

## Instructions

Switch the active GitHub CLI account to the specified user.

**Argument**: `$ARGUMENTS` — the GitHub username to switch to (e.g., `leobrival`, `stanbrunet`)

### Steps

1. If `$ARGUMENTS` is empty, show the current auth status and list available accounts. Ask the user which account to switch to.
2. Run `gh auth switch --user $ARGUMENTS`
3. Confirm the switch by running `gh auth status` and showing the new active account.
4. If the switch fails (user not found in keyring), suggest `gh auth login` to add the account first.
