#!/usr/bin/env bash
set -euo pipefail

# Installation script for Worktree Manager
# Checks dependencies and sets up the environment

echo "🌳 Worktree Manager - Installation"
echo "==================================="
echo ""

# Check Bun
echo "Checking Bun..."
if command -v bun &> /dev/null; then
    BUN_VERSION=$(bun --version)
    echo "✅ Bun is installed (version: $BUN_VERSION)"
else
    echo "❌ Bun is not installed"
    echo ""
    echo "Install Bun with:"
    echo "  curl -fsSL https://bun.sh/install | bash"
    echo ""
    exit 1
fi

# Check Git
echo ""
echo "Checking Git..."
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    echo "✅ Git is installed ($GIT_VERSION)"
else
    echo "❌ Git is not installed"
    exit 1
fi

# Check GitHub CLI
echo ""
echo "Checking GitHub CLI..."
if command -v gh &> /dev/null; then
    GH_VERSION=$(gh --version | head -n 1)
    echo "✅ GitHub CLI is installed ($GH_VERSION)"

    # Check authentication
    if gh auth status &> /dev/null; then
        echo "✅ GitHub CLI is authenticated"
    else
        echo "⚠️  GitHub CLI is not authenticated"
        echo ""
        echo "Authenticate with:"
        echo "  gh auth login"
        echo ""
    fi
else
    echo "❌ GitHub CLI is not installed"
    echo ""
    echo "Install with:"
    echo "  brew install gh"
    echo ""
fi

# Check Claude CLI (optional)
echo ""
echo "Checking Claude CLI (optional)..."
if command -v claude &> /dev/null; then
    echo "✅ Claude CLI is installed"
else
    echo "⚠️  Claude CLI is not installed (optional, used for AI branch naming)"
fi

# Check package managers
echo ""
echo "Checking package managers..."
PACKAGE_MANAGERS=()
for PM in pnpm npm yarn bun; do
    if command -v $PM &> /dev/null; then
        PACKAGE_MANAGERS+=("$PM")
        echo "✅ $PM is installed"
    fi
done

if [ ${#PACKAGE_MANAGERS[@]} -eq 0 ]; then
    echo "⚠️  No package managers found"
fi

# Suggest alias
echo ""
echo "==================================="
echo "✅ Installation check complete!"
echo ""
echo "Add this alias to your shell config (~/.zshrc or ~/.bashrc):"
echo ""
echo "  alias worktree='bun ~/.claude/scripts/worktree-manager/src/index.ts'"
echo ""
echo "Then reload your shell:"
echo "  source ~/.zshrc  # or source ~/.bashrc"
echo ""
echo "Usage:"
echo "  worktree https://github.com/user/repo/issues/123"
echo "  worktree list"
echo "  worktree clean"
echo ""
