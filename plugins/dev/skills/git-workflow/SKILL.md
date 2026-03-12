---
name: git-workflow
description: Complete Git development workflow toolkit. Covers commit, push, PR creation, merge to main, branch cleanup, debug, PR comment resolution, issue-based worktree creation, task execution, and worktree hooks configuration. Use when users need any Git-based development workflow or worktree isolation setup.
allowed-tools: Bash(git *), Bash(gh *), Bash(bun *), Bash(npm *), Bash(pnpm *), Bash(yarn *), Bash(chmod *), Bash(cat *), Bash(ls *), Bash(mkdir *), Read, Write, Edit, Grep, Glob
handoffs:
  - command: /commit
    condition: "When workflow completes successfully"
---

# Git Workflow Toolkit

Complete development workflow toolkit covering the full Git lifecycle: from issue to merge.

## Context (Gather Before Any Workflow)

Before executing any workflow, collect the current git state:

```bash
# Current branch
git branch --show-current

# Working tree status
git status

# Staged and unstaged changes
git diff HEAD

# Recent commits
git log --oneline -10
```

This context informs which workflow to use and how to proceed.

## Package Manager Detection

Used by multiple workflows. Detect in this order:

```bash
if [ -f "pnpm-lock.yaml" ]; then echo "pnpm"
elif [ -f "package-lock.json" ]; then echo "npm"
elif [ -f "yarn.lock" ]; then echo "yarn"
elif [ -f "bun.lockb" ]; then echo "bun"
fi
```

## Workflows Overview

| Workflow | Trigger | Description |
|---|---|---|
| [Commit](#workflow-1-commit) | After code changes | Stage, validate, commit (Commitizen), push |
| [Commit + PR](#workflow-2-commit--pr) | Feature complete | Commit, push, create pull request |
| [Debug](#workflow-3-debug) | Project issues | Detect, categorize, fix all validation errors |
| [Fix PR Comments](#workflow-4-fix-pr-comments) | After review | Resolve all unresolved PR review comments |
| [Merge to Main](#workflow-5-merge-to-main) | PR approved | Merge feature branch with conflict resolution |
| [Clean Gone](#workflow-6-clean-gone) | After merges | Delete local branches removed from remote |
| [Run Task](#workflow-7-run-task) | New task/issue | Full implementation from issue to PR |
| [Issue Worktree](#workflow-8-issue-worktree) | New issue | Create isolated worktree from GitHub issue |

---

## Workflow 1: Commit

Stage all changes, run validation, create a Commitizen-format commit, and push.

**Model**: Use `haiku` for speed (simple, repetitive task).

### Steps

1. **Detect package manager** (see [Package Manager Detection](#package-manager-detection))

2. **Stage all changes**

   ```bash
   git add .
   ```

3. **Run validation** (use parallel subagents if available)
   - `[pm] run lint` (if exists in package.json)
   - `[pm] run typecheck` (if exists in package.json)
   - `[pm] run build` (if exists in package.json)

   If any validation fails, stop and report errors.

4. **Review staged diff**

   ```bash
   git diff --staged
   ```

5. **Create commit** (Commitizen convention)
   - Keep commit message simple and clear
   - Format: `type(scope): description`

   Types:
   - `feat`: New feature
   - `fix`: Bug fix
   - `refactor`: Code refactoring
   - `docs`: Documentation
   - `test`: Tests
   - `chore`: Maintenance

   Examples:
   - `feat: add user authentication`
   - `fix: resolve memory leak in parser`
   - `refactor: simplify validation logic`
   - `docs: update API documentation`

6. **Push to remote**

   ```bash
   git push
   ```

### Notes

- All files are automatically staged
- Validation runs before commit (lint, typecheck, build)
- Commit message follows conventional commits
- Automatically pushes to current branch

---

## Workflow 2: Commit + PR

Commit, push, and create a pull request in one flow.

### Steps

1. **Check current branch**
   - If on `main`/`master`: create a new descriptive branch first (`feat/...`, `fix/...`)

2. **Stage all changes**

   ```bash
   git add .
   ```

3. **Run validation** (same as Workflow 1, step 3)
   - `[pm] run lint` (if exists)
   - `[pm] run typecheck` (if exists)
   - `[pm] run build` (if exists)

   If any validation fails, stop and report errors. Do NOT push or create PR with failing validation.

4. **Create commit** (Commitizen convention, same as Workflow 1 step 5)

5. **Push to origin**

   ```bash
   git push -u origin <branch-name>
   ```

6. **Create Pull Request**

   ```bash
   gh pr create --title "[Title]" --body "## Changes
   - ...

   ## Testing
   - All tests passing
   - TypeScript compilation passes
   - Linting passes

   ## Related Issues
   Closes #123"
   ```

   PR body should include:
   - Summary of changes
   - Testing done
   - Related issues (if any)

### Notes

- Creates new branch if on main/master
- Commits with conventional commit format
- Runs full validation BEFORE push (lint, typecheck, build)
- Pushes and creates PR in one workflow
- Uses `gh` CLI for PR creation

---

## Workflow 3: Debug

Detect and fix all project issues (lint, typecheck, tests, build). Comprehensive project health check.

### Steps

1. **Detect stack and project structure**

   **Check for:**
   - `package.json` — Node.js/TypeScript project
   - `requirements.txt` / `pyproject.toml` — Python project
   - `go.mod` — Go project
   - `Cargo.toml` — Rust project

   **Extract information:**
   - Package manager (npm, pnpm, yarn, bun, pip, cargo, etc.)
   - Language version
   - Framework (Next.js, Express, FastAPI, etc.)
   - Testing framework
   - Linter configuration

2. **Discover available commands**

   **Scan `package.json` scripts (Node.js/TypeScript):**

   ```bash
   cat package.json | grep -E "lint|typecheck|type-check|test|build|format|validate"
   ```

   **Common command patterns to detect:**
   - `lint` / `eslint` / `biome lint` / `biome check` — Linting
   - `typecheck` / `tsc --noEmit` — Type checking
   - `test` / `vitest` / `jest` — Unit tests
   - `build` — Production build
   - `format` / `prettier` — Code formatting

3. **Run all validation commands** (use parallel subagents)
   - Linting (if available)
   - Type checking (if available)
   - Unit tests (if available)
   - Build (if available)

   **For each command:**
   - Capture full output
   - Record exit code
   - Count errors/warnings
   - Extract file paths and line numbers from errors

4. **Analyze and categorize issues**

   - **Critical** — Blocks build/deploy:
     - Build failures
     - Type errors in critical paths
     - Test failures

   - **High Priority** — Code quality issues:
     - Linting errors (not warnings)
     - Type errors in non-critical code

   - **Medium Priority** — Maintainability:
     - Linting warnings
     - Formatting issues

5. **Create fix plan**: Critical → High → Medium (Phase 1, 2, 3)

6. **Execute fixes systematically**

   1. **Read the problematic files first** (understand context)
   2. **Apply fixes one category at a time**
   3. **Use appropriate strategies:**
      - Type errors: Add missing type annotations, fix incorrect types
      - Lint errors: Remove unused imports, fix naming conventions
      - Build errors: Fix missing dependencies, resolve module issues
      - Test failures: Update broken assertions, fix mock data
   4. **Auto-format after fixes:**
      ```bash
      [pm] run format  # or prettier --write .
      ```

7. **Verify fixes** (re-run all validation commands with parallel subagents)
   - Compare before/after results
   - Report issues fixed, time taken, remaining issues (if any)

8. **Summary report**

   ```markdown
   # Debug Session Complete

   ## Project Health: HEALTHY / NEEDS WORK / CRITICAL

   **Stack detected:** [Framework info]

   ## Issues Fixed
   - [List of fixed issues]

   ## Validation Results
   - Linting: [status]
   - Type checking: [status]
   - Tests: [status]
   - Build: [status]

   ## Next Steps
   - [Recommendations]
   ```

### Key Principles

- **Detect don't assume**: Scan for actual commands, don't guess
- **Parallel execution**: Run all checks simultaneously
- **Systematic fixes**: Critical → High → Medium
- **Always verify**: Re-run validation after fixes
- **Context-aware**: Read files before fixing
- **Report clearly**: Show before/after comparison

---

## Workflow 4: Fix PR Comments

Fetch and fix all unresolved PR review comments.

### Steps

1. **Check authentication**

   ```bash
   gh auth status
   ```

   If not authenticated, stop and ask user to run `gh auth login`.

2. **Detect current PR**

   ```bash
   gh pr view --json number,title,url
   ```

   If no PR found, stop and inform user.

3. **Fetch unresolved comments**

   ```bash
   gh pr view --comments | grep -A 5 "UNRESOLVED"
   ```

   Extract:
   - Comment author
   - File path
   - Line number
   - Comment text
   - Suggested change

4. **Plan fixes**
   - Read all files mentioned in comments
   - Understand context (read 2-3 related files)
   - Create fix plan for each comment:
     - What needs to change
     - Why it needs to change
     - How to implement it

5. **Apply fixes systematically**
   - Fix one comment at a time
   - Read file before editing
   - Apply the fix
   - Verify the fix addresses the comment

6. **Commit and push**

   ```bash
   git add .
   git commit -m "fix: resolve PR review comments"
   git push
   ```

7. **Summary report**

   ```
   Fixed N PR comments:
   - src/utils/api.ts:45 - Added error handling
   - src/components/User.tsx:112 - Fixed prop types
   - tests/auth.test.ts:23 - Updated test assertion

   Pushed to branch: feature/user-auth
   PR: https://github.com/user/repo/pull/123
   ```

### Error Handling

- **No PR found**: Inform user and suggest creating one
- **No unresolved comments**: Report success, nothing to fix
- **Not authenticated**: Guide user to authenticate with `gh auth login`
- **Comment ambiguous**: Ask user for clarification

### Notes

- Only fixes unresolved comments
- Commits all fixes in one commit
- Automatically pushes to current branch
- Reads context before making changes

---

## Workflow 5: Merge to Main

Merge current branch to main with conflict resolution and quality checks.

### Steps

1. **Prepare for merge**

   ```bash
   # Verify on feature branch (NOT main)
   git branch --show-current

   # Ensure all changes committed
   git status

   # Check for uncommitted changes
   if [ -n "$(git status --porcelain)" ]; then
     echo "Uncommitted changes found"
     # Run Commit workflow first
   fi
   ```

   Fetch latest main:

   ```bash
   git fetch origin main
   ```

   Preview merge diff:

   ```bash
   git diff origin/main...HEAD
   ```

2. **Create PR** (if none exists)

   Finalize changes:
   - If uncommitted changes exist, run Commit workflow first
   - Ensure all validation passes (lint, typecheck, tests)

   ```bash
   gh pr create \
     --base main \
     --title "[Feature] Clear description" \
     --body "## Changes
   - Implemented [feature]
   - Fixed [issue]

   ## Testing
   - All tests passing
   - TypeScript compilation passes
   - Linting passes

   ## Related Issues
   Closes #123"
   ```

3. **Conflict detection and resolution**

   ```bash
   gh pr view --json mergeable,mergeStateStatus
   ```

   **If conflicts detected:**

   1. **Analyze conflicts:**

      ```bash
      git merge-tree $(git merge-base HEAD origin/main) HEAD origin/main
      ```

   2. **Resolution strategy:**

      **Automatic resolution (when safe):**
      - Both modified same file, different sections: Accept both changes
      - One added, one modified: Accept both changes
      - Formatting conflicts: Accept current branch (already validated)

      **Manual resolution required:**
      - Both modified same lines: Analyze semantics
      - Deleted vs modified: Understand intent
      - Complex logic conflicts: Ask user for guidance

   3. **Apply resolution:**

      ```bash
      git checkout main
      git pull origin main
      git merge <feature-branch>
      # Resolve conflicts
      # Test the merged code
      ```

   4. **Verify resolution:**
      - Run full test suite
      - Run type checker
      - Run linter
      - Ensure build passes

4. **Quality assurance**

   ```bash
   MANAGER=$(
     if [ -f "pnpm-lock.yaml" ]; then echo "pnpm"
     elif [ -f "yarn.lock" ]; then echo "yarn"
     elif [ -f "bun.lockb" ]; then echo "bun"
     else echo "npm"
     fi
   )

   $MANAGER run lint
   $MANAGER run typecheck
   $MANAGER run test
   $MANAGER run build
   ```

   Wait for CI checks:

   ```bash
   gh pr checks
   ```

5. **Complete merge**

   ```bash
   gh pr merge --auto --squash --delete-branch
   ```

   Merge options:
   - `--squash`: Squash all commits into one (cleaner history)
   - `--merge`: Keep all commits (preserve history)
   - `--rebase`: Rebase and merge (linear history)
   - `--delete-branch`: Clean up feature branch

6. **Cleanup and verification**

   ```bash
   git checkout main
   git pull origin main
   git log --oneline -5

   # Delete local feature branch
   git branch -d <feature-branch>

   # Verify remote cleanup
   gh pr list --state closed --limit 5
   ```

7. **Post-merge summary**

   ```
   Merge Complete

   Branch: feature/user-authentication
   PR: #123 - Add user authentication
   Merge type: Squash

   Summary:
   - X files changed
   - Y insertions, Z deletions
   - 0 conflicts (or N auto-resolved)
   - All CI checks passed

   Main branch updated successfully.
   ```

### Conflict Resolution Strategies

1. **Accept Current Branch (feature)**: When feature branch has validated changes
2. **Accept Main Branch**: When main has critical fixes
3. **Merge Both**: When changes are in different sections
4. **Smart Merge**: Analyze semantics and combine logically
5. **Ask User**: When conflict is ambiguous or complex

### Error Handling

- **Uncommitted changes**: Run Commit workflow first
- **CI checks failing**: Fix issues before merge
- **Complex conflicts**: Ask user for guidance
- **Not authenticated**: Run `gh auth login`
- **No PR found**: Create PR first

### Notes

- Automatically detects and resolves simple conflicts
- Asks for guidance on complex conflicts
- Runs full validation before merge
- Cleans up branches after merge
- Provides detailed merge summary

---

## Workflow 6: Clean Gone

Delete local branches that no longer exist on remote.

### Steps

1. **Fetch and prune**

   ```bash
   git fetch --prune
   ```

2. **Find gone branches**

   ```bash
   git for-each-ref --format '%(refname:short) %(upstream:track)' refs/heads | grep '\[gone\]'
   ```

3. **Delete gone branches**

   ```bash
   git branch -d <branch-name>
   ```

   Use `-D` (force) only if `-d` fails and after confirming with user.

4. **Report results**

   ```
   Cleaned up branches:
   - feature/old-feature (deleted)
   - fix/resolved-bug (deleted)

   Remaining branches:
   - main
   - develop
   - feature/current-work
   ```

### Notes

- Only deletes fully merged branches by default (`-d`)
- Preserves current branch
- Fetches from remote first to get accurate status
- Reports what was deleted and what remains

---

## Workflow 7: Run Task

Full implementation workflow from GitHub issue or task file to pull request.

### Input

`$ARGUMENT` can be:
- GitHub issue URL: `https://github.com/user/repo/issues/123`
- Issue number: `123`
- File path: `./tasks/add-feature.md`
- Inline description: `"Add email validation"`

### Steps

1. **Fetch task details**

   **For GitHub issue:**

   ```bash
   gh issue view $ARGUMENT --json title,body,labels,assignees
   ```

   **For file path:**

   ```bash
   cat $ARGUMENT
   ```

   Extract:
   - Task description
   - Requirements
   - Acceptance criteria
   - Technical notes

2. **Plan implementation**

   **Discovery phase:**
   - Read all relevant files
   - Understand existing patterns
   - Identify files to modify
   - Find similar implementations

   **Create detailed plan:**

   ```
   ## Implementation Plan

   ### Context
   [What needs to be built and why]

   ### Files to modify:
   1. src/components/Feature.tsx
   2. src/services/api.ts
   3. tests/Feature.test.ts

   ### Steps:
   1. [Specific implementation steps]
   2. [...]
   ```

3. **Implement changes**

   **Systematic implementation:**
   1. Read files before editing (understand context)
   2. Make changes following the plan
   3. Run TypeScript type checker continuously
   4. Fix type errors immediately as they appear
   5. Add proper type annotations, resolve import issues
   6. Run linter and auto-format code

4. **Run validation** before committing
   - `[pm] run lint`
   - `[pm] run typecheck`
   - `[pm] run test`
   - `[pm] run build`

   Fix any failures before proceeding.

5. **Commit** (Commitizen convention)

   ```bash
   git add .
   git commit -m "feat: [clear description of changes]"
   ```

6. **Create Pull Request**

   ```bash
   gh pr create --title "[Title]" --body "## Changes
   - Implemented [feature]
   - Fixed [issue]

   ## Testing
   - TypeScript compilation passes
   - All tests passing
   - Linting passes

   ## Related Issues
   Closes #123"
   ```

### Error Handling

- **Issue not found**: Verify issue number and repo access
- **File not found**: Check file path is correct
- **Type errors**: Fix all TypeScript errors before committing
- **Tests fail**: Fix tests before creating PR
- **Not authenticated**: Run `gh auth login`

### Notes

- Reads context before making changes
- Runs TypeScript continuously for immediate feedback
- Auto-corrects type errors as they appear
- Creates clean, reviewable commits
- Generates comprehensive PR descriptions

---

## Workflow 8: Issue Worktree

Create an isolated git worktree from a GitHub issue with AI-powered branch naming.

**Requires**: Worktree Manager scripts in `skills/git-workflow/scripts/worktree-manager/`.

### Setup (first time)

```bash
# Find the worktree-manager path
PLUGIN_DIR=$(dirname "$(find ~ -path "*/skills/git-workflow/scripts/worktree-manager/src/index.ts" -type f 2>/dev/null | head -1)")
cd "$PLUGIN_DIR/.." && bun install
```

### Input

- GitHub issue URL: `https://github.com/user/repo/issues/123`

### Steps

1. **Parse argument**
   - Issue URL or issue number → construct full URL from current repo

2. **Execute Worktree Manager**

   ```bash
   bun <plugin-path>/scripts/worktree-manager/src/index.ts <github-issue-url> [options]
   ```

   Automatically:
   - Fetches issue details via `gh` CLI
   - Generates branch name using Claude CLI (fallback: simple generation)
   - Creates isolated worktree with new branch
   - Copies `.env*` files
   - Installs dependencies (auto-detects package manager)
   - Opens terminal with Claude in plan mode

### Options

| Option | Description |
|---|---|
| `--terminal <app>` | Terminal app (Hyper, iTerm2, Warp, Terminal) |
| `--no-deps` | Skip dependency installation |
| `--no-terminal` | Don't open terminal |
| `--debug` | Enable debug logging |
| `--branch <name>` | Override branch name |
| `--profile <name>` | Config profile (minimal, fast, full) |
| `--output <dir>` | Custom worktree base directory |

### Branch naming

- **AI-Powered**: `issue-{number}-{contextual-description}` (max 50 chars, kebab-case)
- **Fallback**: `issue-{number}-{sanitized-title}`

### Additional commands

```bash
# List all worktrees
bun <plugin-path>/scripts/worktree-manager/src/index.ts list

# Clean up old worktrees
bun <plugin-path>/scripts/worktree-manager/src/index.ts clean

# Force cleanup
bun <plugin-path>/scripts/worktree-manager/src/index.ts clean --force
```

---

## Worktree Hooks

Configure Claude Code's `WorktreeCreate` and `WorktreeRemove` hook events for enriched worktree isolation.

When Claude Code creates an isolated worktree (via `isolation: "worktree"` in agents or `claude --worktree`), these hooks automatically:

- Copy `.env*` files from the source repo
- Install dependencies (bun/pnpm/yarn/npm auto-detection)
- Save metadata (`.worktree-meta.json`) for tracking
- Archive metadata on removal for history
- Clean up orphan branches and empty directories

### Scripts Location

The hook scripts are co-located with this skill:

```
skills/git-workflow/scripts/worktree-hooks/
├── on-create.sh   # WorktreeCreate hook
└── on-remove.sh   # WorktreeRemove hook
```

To find the absolute path on this system:

```bash
find ~ -path "*/skills/git-workflow/scripts/worktree-hooks/on-create.sh" -type f 2>/dev/null | head -1
```

### Install Hooks

1. Locate the scripts:

```bash
HOOK_DIR=$(dirname "$(find ~ -path "*/skills/git-workflow/scripts/worktree-hooks/on-create.sh" -type f 2>/dev/null | head -1)")
echo "Hook scripts found at: $HOOK_DIR"
```

2. Verify scripts are executable:

```bash
chmod +x "$HOOK_DIR/on-create.sh" "$HOOK_DIR/on-remove.sh"
```

3. Add hooks to `~/.claude/settings.json` under the `hooks` key:

```json
{
  "hooks": {
    "WorktreeCreate": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "<HOOK_DIR>/on-create.sh"
          }
        ]
      }
    ],
    "WorktreeRemove": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "<HOOK_DIR>/on-remove.sh"
          }
        ]
      }
    ]
  }
}
```

Replace `<HOOK_DIR>` with the absolute path found in step 1.

4. Test the hooks:

```bash
# Simulate WorktreeCreate (from a git repo directory)
echo '{"name":"test-hook","cwd":"'$(git rev-parse --show-toplevel)'"}' | "$HOOK_DIR/on-create.sh"
```

### Check Hook Status

```bash
# Check if hooks are configured in settings.json
cat ~/.claude/settings.json | python3 -c "
import sys, json
settings = json.load(sys.stdin)
hooks = settings.get('hooks', {})
create = hooks.get('WorktreeCreate')
remove = hooks.get('WorktreeRemove')
print(f'WorktreeCreate: {\"configured\" if create else \"not configured\"}')
print(f'WorktreeRemove: {\"configured\" if remove else \"not configured\"}')
if create:
    cmd = create[0]['hooks'][0]['command']
    print(f'  Create script: {cmd}')
if remove:
    cmd = remove[0]['hooks'][0]['command']
    print(f'  Remove script: {cmd}')
"

# Check recent hook activity
tail -20 /tmp/worktree-hooks.log 2>/dev/null || echo "No hook logs yet"

# Check archived worktrees
ls ~/.claude/worktree-archive/ 2>/dev/null || echo "No archived worktrees yet"
```

### View Worktree History

```bash
for f in ~/.claude/worktree-archive/*.json; do
  [ -f "$f" ] || continue
  python3 -c "
import json
with open('$f') as fh:
    m = json.load(fh)
    print(f\"{m.get('name','?'):30s} {m.get('repo','?'):20s} created={m.get('created_at','?')[:19]}  removed={m.get('removed_at','?')[:19]}\")
" 2>/dev/null
done
```

### Disable Hooks

Remove the `WorktreeCreate` and `WorktreeRemove` entries from `~/.claude/settings.json` to revert to default git worktree behavior.

### Hook Configuration

Both scripts are configured via environment variables. Set them in your shell profile (`~/.zshrc`) or inline in the hook command.

**on-create.sh**:

| Variable | Default | Description |
|---|---|---|
| `WORKTREE_BASE_DIR` | `~/Developer/worktrees` | Base directory for worktrees |
| `WORKTREE_COPY_ENV` | `true` | Copy `.env*` files from source repo |
| `WORKTREE_INSTALL_DEPS` | `true` | Auto-install dependencies |
| `WORKTREE_LOG_FILE` | `/tmp/worktree-hooks.log` | Log file path |

**on-remove.sh**:

| Variable | Default | Description |
|---|---|---|
| `WORKTREE_CLEANUP_BRANCH` | `true` | Delete the local branch after removal |
| `WORKTREE_ARCHIVE_META` | `true` | Archive metadata before deletion |
| `WORKTREE_ARCHIVE_DIR` | `~/.claude/worktree-archive` | Archive directory |
| `WORKTREE_LOG_FILE` | `/tmp/worktree-hooks.log` | Log file path |

Example with custom config in settings.json:

```json
{
  "hooks": {
    "WorktreeCreate": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "WORKTREE_BASE_DIR=/tmp/worktrees WORKTREE_INSTALL_DEPS=false <HOOK_DIR>/on-create.sh"
          }
        ]
      }
    ]
  }
}
```

### How Hooks Work

**WorktreeCreate (on-create.sh)**:

Triggered when Claude Code needs an isolated worktree (`isolation: "worktree"` or `claude --worktree`).

Input: JSON on stdin with `name` (worktree identifier) and `cwd` (source repo path).

Steps:
1. Creates worktree via `git worktree add` in `$WORKTREE_BASE_DIR/<repo>-worktree/<name>`
2. Copies all `.env*` files from repo root (excludes `node_modules/`, `.git/`)
3. Detects package manager (bun > pnpm > yarn > npm) and runs install
4. Saves `.worktree-meta.json` inside the worktree
5. Prints absolute path to stdout (required by Claude Code)

Output: Absolute path to the created worktree directory (stdout). All logs go to stderr.

**WorktreeRemove (on-remove.sh)**:

Triggered when Claude Code removes a worktree (session end or agent cleanup).

Input: JSON on stdin with `worktree_path` and `cwd`.

Steps:
1. Archives `.worktree-meta.json` to `~/.claude/worktree-archive/` with removal timestamp
2. Removes worktree via `git worktree remove --force`
3. Prunes stale git worktree references
4. Deletes orphan branch (if safe — not checked out elsewhere, already merged)
5. Removes empty parent directories

### Worktree Hook Dependencies

- bash, git (required)
- python3 (JSON parsing — ships with macOS)
- bun/pnpm/yarn/npm (for dependency installation, at least one required)

### Worktree Hook Troubleshooting

**Hook not triggering**:
- Verify hooks are in `~/.claude/settings.json` under `hooks.WorktreeCreate` / `hooks.WorktreeRemove`
- Scripts must be executable: `chmod +x on-create.sh on-remove.sh`
- Check logs: `tail -f /tmp/worktree-hooks.log`

**"not a git repository" error**:
- The hook uses `cwd` from the input JSON — make sure you're running `claude --worktree` from inside a git repo
- When using `isolation: "worktree"` in Task tool, the parent agent's cwd must be a git repo

**Dependencies not installing**:
- Check which package manager is available: `which bun pnpm yarn npm`
- Set `WORKTREE_INSTALL_DEPS=false` to skip installation
- Check the log for specific install errors

**Worktree path conflict**:
- If a worktree with the same name exists, the script will fail
- Clean up old worktrees: `git worktree list` then `git worktree remove <path>`

---

## Decision Tree

| Situation | Workflow |
|---|---|
| Just finished coding, want to save | **Commit** |
| Feature complete, ready for review | **Commit + PR** |
| Something is broken, need to fix everything | **Debug** |
| Got review comments on my PR | **Fix PR Comments** |
| PR approved, ready to ship | **Merge to Main** |
| Too many old local branches | **Clean Gone** |
| Starting work on an issue/task | **Run Task** |
| Need isolated environment for an issue | **Issue Worktree** |

## Error Handling

All workflows share common error handling:

- **Not a git repository**: Inform user, suggest `cd` to a repo
- **Not authenticated**: `gh auth login`
- **Uncommitted changes**: Run Commit workflow first
- **Validation fails**: Stop and report errors before proceeding
- **Merge conflicts**: Attempt auto-resolve, ask user for complex cases
- **CI checks failing**: Wait or fix before merge

## Notes

- All workflows auto-detect the package manager (pnpm > npm > yarn > bun)
- Commitizen convention enforced for all commits
- Validation runs before every commit (lint, typecheck, build)
- `gh` CLI required for PR/issue operations
- Workflows can be chained: Run Task → Commit + PR → Merge to Main
