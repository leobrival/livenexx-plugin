---
name: linter-setup
description: Linting and formatting setup expert using Biome and markdownlint-cli2. Use when users need to set up linters, configure Biome for TypeScript/JavaScript/CSS/JSON, configure markdownlint for Markdown files, migrate from ESLint/Prettier, or add code quality tooling to a project.
user-invocable: false
allowed-tools: Bash(biome:*), Bash(bunx biome:*), Bash(npx biome:*), Bash(markdownlint-cli2:*), Bash(npx markdownlint-cli2:*)
handoffs:
  - command: /commit
    condition: "When workflow completes successfully"
model: sonnet
---

# Linter Setup Guide

Biome is a fast all-in-one linter, formatter, and import organizer for JavaScript, TypeScript, JSX, CSS, JSON, GraphQL, and HTML. markdownlint-cli2 is the standard linter for Markdown files. This guide provides workflows for setting up both tools in any project.

## Quick Start

```bash
# Install Biome (pin exact version)
bun add -D -E @biomejs/biome

# Initialize Biome config
bunx --bun biome init

# Check code (lint + format + imports)
bunx --bun biome check .

# Auto-fix all issues
bunx --bun biome check --write .

# Install markdownlint-cli2
bun add -D markdownlint-cli2

# Lint Markdown files
bunx markdownlint-cli2 '**/*.md' '!node_modules/**'

# Fix Markdown issues
bunx markdownlint-cli2 --fix '**/*.md' '!node_modules/**'
```

## Common Workflows

### Workflow 1: New Project Setup (Biome + markdownlint)

```bash
# Install both tools
bun add -D -E @biomejs/biome markdownlint-cli2

# Initialize Biome
bunx --bun biome init
```

Create `biome.json`:

```json
{
  "$schema": "https://biomejs.dev/schemas/2.3.11/schema.json",
  "vcs": {
    "enabled": true,
    "clientKind": "git",
    "useIgnoreFile": true
  },
  "formatter": {
    "indentStyle": "tab",
    "lineWidth": 80
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true
    }
  },
  "javascript": {
    "formatter": {
      "quoteStyle": "double",
      "semicolons": "always",
      "trailingCommas": "all"
    }
  },
  "json": {
    "formatter": {
      "trailingCommas": "none"
    }
  }
}
```

Create `.markdownlint.json`:

```json
{
  "default": true,
  "MD013": false,
  "MD029": false,
  "MD033": {
    "allowed_elements": ["br", "details", "summary", "img"]
  },
  "MD060": false
}
```

Add npm scripts to `package.json`:

```json
{
  "scripts": {
    "lint": "biome check .",
    "lint:fix": "biome check --write .",
    "format": "biome format --write .",
    "lint:md": "markdownlint-cli2 '**/*.md' '!node_modules/**'",
    "fix:md": "markdownlint-cli2 --fix '**/*.md' '!node_modules/**'"
  }
}
```

### Workflow 2: Migrate from ESLint and Prettier

```bash
# Migrate ESLint rules to Biome
bunx --bun biome migrate eslint --write

# Include inspired rules (slightly different behavior)
bunx --bun biome migrate eslint --write --include-inspired

# Migrate Prettier options to Biome
bunx --bun biome migrate prettier --write

# Suppress existing violations (clean migration)
bunx --bun biome lint --write --unsafe --suppress="migration from ESLint"

# Verify migration
bunx --bun biome check .

# Remove ESLint and Prettier when satisfied
bun remove eslint prettier @typescript-eslint/parser @typescript-eslint/eslint-plugin eslint-config-prettier eslint-plugin-react
rm .eslintrc* .prettierrc* .eslintignore .prettierignore
```

### Workflow 3: CI/CD Integration

```bash
# CI mode: read-only check, exits non-zero on errors
bunx --bun biome ci .

# With GitHub reporter for annotations
bunx --bun biome ci --reporter=github .

# With JUnit for CI dashboards
bunx --bun biome ci --reporter=junit . > biome-report.xml

# Markdown lint in CI
bunx markdownlint-cli2 '**/*.md' '!node_modules/**'
```

GitHub Actions example:

```yaml
# .github/workflows/lint.yml
name: Lint
on: [push, pull_request]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v2
      - run: bun install
      - run: bunx --bun biome ci --reporter=github .
      - uses: DavidAnson/markdownlint-cli2-action@main
        with:
          globs: "**/*.md"
```

### Workflow 4: Git Hooks with lint-staged

```bash
# Install lint-staged and lefthook (or husky)
bun add -D lint-staged lefthook
```

Configure `package.json`:

```json
{
  "lint-staged": {
    "*.{js,ts,jsx,tsx,css,json}": ["biome check --write --no-errors-on-unmatched"],
    "*.md": ["markdownlint-cli2 --fix"]
  }
}
```

Or use Biome's built-in git integration:

```bash
# Lint only staged files
bunx --bun biome check --staged --write

# Lint changes since default branch
bunx --bun biome check --changed --write

# Lint changes since specific ref
bunx --bun biome check --since=main --write
```

### Workflow 5: Monorepo Setup

```bash
# Root biome.json (shared config)
# Each package can have its own biome.json that inherits
```

Root `biome.json`:

```json
{
  "$schema": "https://biomejs.dev/schemas/2.3.11/schema.json",
  "formatter": {
    "indentStyle": "tab"
  },
  "linter": {
    "rules": {
      "recommended": true
    }
  }
}
```

Package `packages/frontend/biome.json`:

```json
{
  "$schema": "https://biomejs.dev/schemas/2.3.11/schema.json",
  "extends": ["../../biome.json"],
  "linter": {
    "domains": {
      "react": "recommended"
    }
  }
}
```

Package `packages/backend/biome.json`:

```json
{
  "$schema": "https://biomejs.dev/schemas/2.3.11/schema.json",
  "extends": ["../../biome.json"],
  "javascript": {
    "globals": ["Bun"]
  }
}
```

## Decision Tree

**When to use which tool:**

- **To lint TS/JS/JSX/TSX/CSS/JSON/GraphQL**: Use `biome check`
- **To format TS/JS/JSX/TSX/CSS/JSON**: Use `biome format`
- **To lint Markdown (.md) files**: Use `markdownlint-cli2`
- **To auto-fix code issues**: Use `biome check --write`
- **To auto-fix Markdown**: Use `markdownlint-cli2 --fix`
- **To run in CI (read-only)**: Use `biome ci`
- **To migrate from ESLint**: Use `biome migrate eslint --write`
- **To migrate from Prettier**: Use `biome migrate prettier --write`
- **To lint only staged files**: Use `biome check --staged`
- **To lint changes since branch**: Use `biome check --changed`
- **For detailed Biome config**: See [Commands Reference](./reference/commands-reference.md)
- **For config recipes**: See [Common Patterns](./reference/common-patterns.md)
- **For troubleshooting**: See [Troubleshooting Guide](./reference/troubleshooting.md)

## Common Patterns

### Biome Rule Configuration

```json
{
  "linter": {
    "rules": {
      "recommended": true,
      "style": {
        "noNonNullAssertion": "warn",
        "useConst": "error",
        "useTemplate": "error"
      },
      "suspicious": {
        "noExplicitAny": "warn",
        "noDebugger": "error"
      },
      "complexity": {
        "noForEach": "off"
      }
    },
    "domains": {
      "react": "recommended",
      "test": "recommended"
    }
  }
}
```

### Biome File Overrides

```json
{
  "overrides": [
    {
      "includes": ["**/*.test.ts", "**/*.spec.ts"],
      "linter": {
        "rules": {
          "suspicious": {
            "noExplicitAny": "off"
          }
        }
      }
    },
    {
      "includes": ["scripts/**"],
      "formatter": {
        "lineWidth": 120
      }
    }
  ]
}
```

### Suppress and Ignore

```javascript
// Biome: suppress a specific rule
// biome-ignore lint/suspicious/noDebugger: needed for development
debugger;

// Biome: suppress formatting
// biome-ignore format: keep manual alignment
const matrix = [
  [1, 0, 0],
  [0, 1, 0],
  [0, 0, 1],
];
```

```markdown
<!-- markdownlint-disable MD013 -->
Long line that should not be flagged.
<!-- markdownlint-enable MD013 -->

<!-- markdownlint-disable-next-line MD041 -->
Not a heading on the first line.
```

### Editor Configuration (VS Code)

```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "biomejs.biome",
  "editor.codeActionsOnSave": {
    "source.fixAll.biome": "explicit",
    "source.organizeImports.biome": "explicit"
  },
  "[markdown]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  }
}
```

## Troubleshooting

**Common Issues:**

1. **Biome not found after install**
   - Solution: Use `bunx --bun biome` or `npx @biomejs/biome` instead of bare `biome`
   - See: [Installation Issues](./reference/troubleshooting.md#installation-issues)

2. **Config not picked up**
   - Quick fix: Verify `biome.json` is in project root with `biome rage`
   - See: [Configuration Issues](./reference/troubleshooting.md#configuration-issues)

3. **ESLint migration misses rules**
   - Quick fix: Add `--include-inspired --include-nursery` flags
   - See: [Migration Issues](./reference/troubleshooting.md#migration-issues)

4. **markdownlint too strict**
   - Quick fix: Disable `MD013` (line length) in `.markdownlint.json`
   - See: [Markdown Issues](./reference/troubleshooting.md#markdown-issues)

5. **Conflicts between Prettier and Biome**
   - Quick fix: Remove Prettier and let Biome handle all formatting
   - See: [Conflict Resolution](./reference/troubleshooting.md#conflict-resolution)

For detailed troubleshooting steps, see the [Troubleshooting Guide](./reference/troubleshooting.md).

## Reference Files

**Load as needed for detailed information:**

- **[Commands Reference](./reference/commands-reference.md)** - Complete CLI documentation for Biome and markdownlint-cli2 with all flags, configuration schema, and rule groups. Use when you need exact syntax or config options.

- **[Common Patterns](./reference/common-patterns.md)** - Real-world patterns for project setup, migration recipes, monorepo configs, CI/CD integration, editor setup, and advanced rule configuration. Use for implementing specific setups.

- **[Troubleshooting Guide](./reference/troubleshooting.md)** - Detailed error messages, diagnosis steps, and resolution strategies for installation, configuration, migration, and runtime issues. Use when encountering errors or unexpected behavior.

**When to use each reference:**

- Use **Commands Reference** when you need exact syntax, config schema, or the full list of Biome/markdownlint rules
- Use **Common Patterns** for project setup recipes, migration guides, or CI/CD pipeline configuration
- Use **Troubleshooting** when tools won't install, configs aren't detected, or rules behave unexpectedly

## Resources

- Biome Docs: https://biomejs.dev
- Biome GitHub: https://github.com/biomejs/biome
- Biome Rules: https://biomejs.dev/linter/rules/
- markdownlint-cli2: https://github.com/DavidAnson/markdownlint-cli2
- markdownlint Rules: https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md
- Biome VS Code Extension: https://marketplace.visualstudio.com/items?itemName=biomejs.biome
