#!/usr/bin/env bash
set -euo pipefail
# WorktreeRemove hook for Claude Code
# Reads JSON from stdin, cleans up worktree and associated resources.
# All logs go to stderr. Exit code is non-blocking (Claude Code ignores failures).
#
# Input (stdin JSON):
#   { "worktree_path": "/absolute/path/to/worktree", "cwd": "/path/to/repo", ... }
#
# Configuration via environment variables:
#   WORKTREE_CLEANUP_BRANCH  - Also delete the local branch (default: true)
#   WORKTREE_ARCHIVE_META    - Archive metadata before deletion (default: true)
#   WORKTREE_ARCHIVE_DIR     - Archive directory (default: ~/.claude/worktree-archive)
#   WORKTREE_LOG_FILE        - Log file path (default: /tmp/worktree-hooks.log)

set -uo pipefail

# --- Configuration ---
WORKTREE_CLEANUP_BRANCH="${WORKTREE_CLEANUP_BRANCH:-true}"
WORKTREE_ARCHIVE_META="${WORKTREE_ARCHIVE_META:-true}"
WORKTREE_ARCHIVE_DIR="${WORKTREE_ARCHIVE_DIR:-$HOME/.claude/worktree-archive}"
WORKTREE_LOG_FILE="${WORKTREE_LOG_FILE:-/tmp/worktree-hooks.log}"

# --- Logging (all to stderr + file) ---
log() {
  local level="$1"
  shift
  local msg="[worktree-hook:remove] [$level] $(date '+%H:%M:%S') $*"
  echo "$msg" >&2
  echo "$msg" >> "$WORKTREE_LOG_FILE"
}

# --- Read stdin JSON ---
INPUT=$(cat)
WORKTREE_PATH=$(echo "$INPUT" | /usr/bin/python3 -c "import sys,json; print(json.load(sys.stdin).get('worktree_path',''))" 2>/dev/null)
CWD=$(echo "$INPUT" | /usr/bin/python3 -c "import sys,json; print(json.load(sys.stdin).get('cwd',''))" 2>/dev/null)

if [ -z "$WORKTREE_PATH" ]; then
  log "ERROR" "Missing 'worktree_path' in input JSON"
  exit 1
fi

log "INFO" "Removing worktree: $WORKTREE_PATH"

# --- Archive metadata before deletion ---
if [ "$WORKTREE_ARCHIVE_META" = "true" ]; then
  METADATA_FILE="$WORKTREE_PATH/.worktree-meta.json"

  if [ -f "$METADATA_FILE" ]; then
    mkdir -p "$WORKTREE_ARCHIVE_DIR"

    WORKTREE_NAME=$(basename "$WORKTREE_PATH")
    TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
    ARCHIVE_FILE="$WORKTREE_ARCHIVE_DIR/${WORKTREE_NAME}_${TIMESTAMP}.json"

    # Enrich metadata with removal info
    /usr/bin/python3 -c "
import json, datetime
with open('$METADATA_FILE') as f:
    meta = json.load(f)
meta['removed_at'] = datetime.datetime.now().isoformat()
meta['hook'] = 'WorktreeRemove'
with open('$ARCHIVE_FILE', 'w') as f:
    json.dump(meta, f, indent=2)
" 2>/dev/null

    log "INFO" "Metadata archived to $ARCHIVE_FILE"
  fi
fi

# --- Get branch name before removal ---
BRANCH_NAME=""
if [ -n "$CWD" ] && [ -d "$CWD" ]; then
  BRANCH_NAME=$(git -C "$CWD" worktree list --porcelain 2>/dev/null | \
    awk -v path="$WORKTREE_PATH" '
      /^worktree / { wt = substr($0, 10) }
      /^branch /   { if (wt == path) { sub(/^branch refs\/heads\//, ""); print; exit } }
    ')
fi

# --- Remove worktree via git ---
if [ -n "$CWD" ] && [ -d "$CWD" ]; then
  git -C "$CWD" worktree remove "$WORKTREE_PATH" --force >&2 2>&1 || true
  log "INFO" "git worktree remove done"
fi

# --- Fallback: remove directory if still exists ---
if [ -d "$WORKTREE_PATH" ]; then
  rm -rf "$WORKTREE_PATH"
  log "INFO" "Directory removed (fallback)"
fi

# --- Prune stale worktree references ---
if [ -n "$CWD" ] && [ -d "$CWD" ]; then
  git -C "$CWD" worktree prune >&2 2>&1 || true
fi

# --- Cleanup orphan branch ---
if [ "$WORKTREE_CLEANUP_BRANCH" = "true" ] && [ -n "$BRANCH_NAME" ] && [ -n "$CWD" ]; then
  # Only delete if branch is not checked out elsewhere
  CHECKED_OUT=$(git -C "$CWD" worktree list --porcelain 2>/dev/null | grep -c "branch refs/heads/$BRANCH_NAME" || true)

  if [ "$CHECKED_OUT" -eq 0 ]; then
    git -C "$CWD" branch -d "$BRANCH_NAME" >&2 2>&1 && \
      log "INFO" "Branch deleted: $BRANCH_NAME" || \
      log "DEBUG" "Branch not deleted (unmerged or not found): $BRANCH_NAME"
  else
    log "DEBUG" "Branch still in use elsewhere: $BRANCH_NAME"
  fi
fi

# --- Cleanup empty parent directories ---
PARENT_DIR=$(dirname "$WORKTREE_PATH")
if [ -d "$PARENT_DIR" ] && [ -z "$(ls -A "$PARENT_DIR" 2>/dev/null)" ]; then
  rmdir "$PARENT_DIR" 2>/dev/null && log "DEBUG" "Removed empty parent: $PARENT_DIR" || true
fi

log "INFO" "Worktree cleanup complete: $WORKTREE_PATH"

exit 0
