#!/usr/bin/env bash
# WorktreeCreate hook for Claude Code
# Reads JSON from stdin, creates an enriched worktree, prints absolute path to stdout.
# All logs go to stderr to keep stdout clean for Claude Code.
#
# Input (stdin JSON):
#   { "name": "bold-oak-a3f2", "cwd": "/path/to/repo", ... }
#
# Output (stdout):
#   /absolute/path/to/created/worktree
#
# Configuration via environment variables:
#   WORKTREE_BASE_DIR    - Base directory for worktrees (default: ~/Developer/worktrees)
#   WORKTREE_COPY_ENV    - Copy .env files from source repo (default: true)
#   WORKTREE_INSTALL_DEPS - Auto-install dependencies (default: true)
#   WORKTREE_LOG_FILE    - Log file path (default: /tmp/worktree-hooks.log)

set -euo pipefail

# --- Configuration ---
WORKTREE_BASE_DIR="${WORKTREE_BASE_DIR:-$HOME/Developer/worktrees}"
WORKTREE_COPY_ENV="${WORKTREE_COPY_ENV:-true}"
WORKTREE_INSTALL_DEPS="${WORKTREE_INSTALL_DEPS:-true}"
WORKTREE_LOG_FILE="${WORKTREE_LOG_FILE:-/tmp/worktree-hooks.log}"

# --- Logging (all to stderr + file) ---
log() {
  local level="$1"
  shift
  local msg="[worktree-hook:create] [$level] $(date '+%H:%M:%S') $*"
  echo "$msg" >&2
  echo "$msg" >> "$WORKTREE_LOG_FILE"
}

# --- Read stdin JSON ---
INPUT=$(cat)
NAME=$(echo "$INPUT" | /usr/bin/python3 -c "import sys,json; print(json.load(sys.stdin).get('name',''))" 2>/dev/null)
CWD=$(echo "$INPUT" | /usr/bin/python3 -c "import sys,json; print(json.load(sys.stdin).get('cwd',''))" 2>/dev/null)

if [ -z "$NAME" ]; then
  log "ERROR" "Missing 'name' in input JSON"
  exit 1
fi

if [ -z "$CWD" ]; then
  CWD="$(pwd)"
fi

log "INFO" "Creating worktree: name=$NAME cwd=$CWD"

# --- Resolve repo name ---
REPO_NAME=$(basename "$CWD")
WORKTREE_DIR="$WORKTREE_BASE_DIR/${REPO_NAME}-worktree/$NAME"

# --- Create worktree ---
mkdir -p "$(dirname "$WORKTREE_DIR")"

DEFAULT_BRANCH=$(git -C "$CWD" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||' || echo "main")

log "INFO" "git worktree add -b $NAME $WORKTREE_DIR $DEFAULT_BRANCH"
git -C "$CWD" worktree add -b "$NAME" "$WORKTREE_DIR" "$DEFAULT_BRANCH" >&2 2>&1

if [ ! -d "$WORKTREE_DIR" ]; then
  log "ERROR" "Worktree directory was not created: $WORKTREE_DIR"
  exit 1
fi

log "INFO" "Worktree created at $WORKTREE_DIR"

# --- Copy .env files ---
if [ "$WORKTREE_COPY_ENV" = "true" ]; then
  REPO_ROOT=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null || echo "$CWD")
  ENV_COUNT=0

  while IFS= read -r envfile; do
    [ -z "$envfile" ] && continue
    REL_PATH="${envfile#"$REPO_ROOT"/}"
    TARGET="$WORKTREE_DIR/$REL_PATH"
    mkdir -p "$(dirname "$TARGET")"
    cp "$envfile" "$TARGET"
    ENV_COUNT=$((ENV_COUNT + 1))
    log "DEBUG" "Copied: $REL_PATH"
  done < <(find "$REPO_ROOT" -name ".env*" -type f -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null)

  if [ "$ENV_COUNT" -gt 0 ]; then
    log "INFO" "Copied $ENV_COUNT .env file(s)"
  fi
fi

# --- Install dependencies ---
if [ "$WORKTREE_INSTALL_DEPS" = "true" ] && [ -f "$WORKTREE_DIR/package.json" ]; then
  log "INFO" "Installing dependencies..."

  if [ -f "$WORKTREE_DIR/bun.lockb" ] || [ -f "$WORKTREE_DIR/bun.lock" ]; then
    (cd "$WORKTREE_DIR" && bun install --frozen-lockfile 2>&1) >&2 || log "WARN" "bun install failed"
  elif [ -f "$WORKTREE_DIR/pnpm-lock.yaml" ]; then
    (cd "$WORKTREE_DIR" && pnpm install --frozen-lockfile 2>&1) >&2 || log "WARN" "pnpm install failed"
  elif [ -f "$WORKTREE_DIR/yarn.lock" ]; then
    (cd "$WORKTREE_DIR" && yarn install --frozen-lockfile 2>&1) >&2 || log "WARN" "yarn install failed"
  elif [ -f "$WORKTREE_DIR/package-lock.json" ]; then
    (cd "$WORKTREE_DIR" && npm ci 2>&1) >&2 || log "WARN" "npm ci failed"
  else
    (cd "$WORKTREE_DIR" && bun install 2>&1) >&2 || log "WARN" "fallback bun install failed"
  fi

  log "INFO" "Dependencies installed"
fi

# --- Save metadata ---
METADATA_FILE="$WORKTREE_DIR/.worktree-meta.json"
/usr/bin/python3 -c "
import json, datetime
meta = {
    'name': '$NAME',
    'repo': '$REPO_NAME',
    'cwd': '$CWD',
    'created_at': datetime.datetime.now().isoformat(),
    'hook': 'WorktreeCreate'
}
with open('$METADATA_FILE', 'w') as f:
    json.dump(meta, f, indent=2)
" 2>/dev/null

log "INFO" "Metadata saved to $METADATA_FILE"

# --- Output absolute path (required by Claude Code) ---
echo "$WORKTREE_DIR"
