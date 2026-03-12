# Linter Setup Troubleshooting Guide

Common issues and solutions for Biome and markdownlint-cli2 operations.

## Installation Issues

### Biome Not Found

**Symptom:** `command not found: biome` or `biome is not recognized`

**Diagnosis:**

```bash
# Check if installed locally
ls node_modules/.bin/biome

# Check package.json
grep biome package.json
```

**Solutions:**

```bash
# Use package runner instead of bare command
bunx --bun biome check .    # bun
npx @biomejs/biome check .  # npm
pnpm exec biome check .     # pnpm

# Or install globally (not recommended)
bun add -g @biomejs/biome

# Verify installation
bunx --bun biome version
```

### markdownlint-cli2 Not Found

**Symptom:** `command not found: markdownlint-cli2`

**Solutions:**

```bash
# Install locally
bun add -D markdownlint-cli2

# Use via package runner
bunx markdownlint-cli2 '**/*.md'
npx markdownlint-cli2 '**/*.md'

# Or install globally
npm install markdownlint-cli2 --global

# Homebrew alternative
brew install markdownlint-cli2
```

### Version Mismatch

**Symptom:** Features not available or unexpected behavior

**Diagnosis:**

```bash
# Check Biome version
bunx --bun biome version

# Check markdownlint-cli2 version
bunx markdownlint-cli2 --help | head -1
```

**Solutions:**

```bash
# Update Biome to latest
bun add -D -E @biomejs/biome@latest

# Migrate config after major update
bunx --bun biome migrate --write

# Update markdownlint-cli2
bun add -D markdownlint-cli2@latest
```

## Configuration Issues

### Biome Config Not Detected

**Symptom:** `No configuration found` or default rules applied

**Diagnosis:**

```bash
# Check config resolution
bunx --bun biome rage

# Verify file exists
ls biome.json biome.jsonc 2>/dev/null
```

**Solutions:**

```bash
# biome.json must be in project root or ancestor directory
# Check you're running from the right directory
pwd
ls biome.json

# Create config if missing
bunx --bun biome init

# Specify config path explicitly
bunx --bun biome check --config-path=./config/biome.json .

# If both biome.json and biome.jsonc exist, biome.json wins
# Remove one to avoid confusion
```

### markdownlint Config Not Applied

**Symptom:** Default rules used instead of custom config

**Diagnosis:**

```bash
# Check which config files exist
ls .markdownlint* 2>/dev/null
ls .markdownlint-cli2* 2>/dev/null
```

**Solutions:**

```bash
# Config files are discovered in this order:
# 1. .markdownlint-cli2.jsonc
# 2. .markdownlint-cli2.yaml
# 3. .markdownlint-cli2.cjs
# 4. .markdownlint-cli2.mjs
# 5. package.json (root only)

# .markdownlint.json overrides only the "config" property
# Ensure file is in the right directory (searched up from each .md file)

# Explicit config
markdownlint-cli2 --config .markdownlint.json '**/*.md'

# Check JSON syntax
cat .markdownlint.json | python3 -m json.tool
```

### Invalid biome.json Syntax

**Symptom:** `Failed to parse configuration file`

**Solutions:**

```bash
# Validate JSON syntax
cat biome.json | python3 -m json.tool

# Common mistakes:
# - Trailing commas in biome.json (not allowed)
# - Use biome.jsonc for comments and trailing commas
bunx --bun biome init --jsonc

# Validate against schema
# Add $schema field:
# "$schema": "https://biomejs.dev/schemas/2.3.11/schema.json"
```

### Config Extends Not Resolving

**Symptom:** `Cannot find configuration to extend`

**Solutions:**

```bash
# Check the path is relative to biome.json location
# biome.json:
# "extends": ["../../base-biome.json"]  <- relative path

# Verify the target file exists
ls ../../base-biome.json

# In monorepos, each package's biome.json extends root
# packages/web/biome.json -> extends: ["../../biome.json"]
```

## Migration Issues

### ESLint Migration Misses Rules

**Symptom:** Some ESLint rules not converted to Biome equivalents

**Solutions:**

```bash
# Include inspired rules (similar behavior, not identical)
bunx --bun biome migrate eslint --write --include-inspired

# Include nursery (experimental) rules
bunx --bun biome migrate eslint --write --include-nursery

# Check migration output for unmigrated rules
# They're listed in the terminal output

# For rules with no Biome equivalent:
# Option 1: Accept the gap
# Option 2: Keep ESLint for those specific rules only
# Option 3: Use biome search with GritQL as workaround
```

### ESLint Migration Fails to Parse Config

**Symptom:** `Cannot parse ESLint configuration`

**Solutions:**

```bash
# YAML configs: convert to JSON first
# .eslintrc.yml -> .eslintrc.json

# JavaScript configs (.eslintrc.js):
# Ensure Node.js is available for module resolution
node --version

# Flat config (eslint.config.js): supported since Biome 2.0

# Cyclic extends: simplify the extends chain
# Remove redundant extends before migrating
```

### Prettier Migration Conflicts

**Symptom:** Formatting differs between Prettier and Biome after migration

**Solutions:**

```bash
# Known differences:
# - Biome defaults to tabs, Prettier to spaces
# - Some edge cases in JSX formatting differ
# - Parenthesization may differ in complex expressions

# Run both formatters and diff
bunx prettier --write src/
bunx --bun biome format --write src/
git diff

# Accept Biome's formatting (it's intentional)
# Or override specific options in biome.json:
# "javascript.formatter.quoteStyle": "single"  <- if Prettier used single
```

## Markdown Issues

### Line Length Violations Everywhere

**Symptom:** MD013 errors on almost every file

**Solutions:**

```json
// .markdownlint.json - Disable line length
{
  "MD013": false
}

// Or increase limit and exclude code blocks
{
  "MD013": {
    "line_length": 120,
    "code_blocks": false,
    "tables": false,
    "headings": false
  }
}
```

### HTML in Markdown Flagged

**Symptom:** MD033 errors for allowed HTML elements

**Solutions:**

```json
{
  "MD033": {
    "allowed_elements": [
      "br", "details", "summary", "img",
      "a", "sup", "sub", "kbd", "abbr",
      "picture", "source", "video",
      "table", "thead", "tbody", "tr", "th", "td"
    ]
  }
}
```

### Front Matter Causes Errors

**Symptom:** MD041 or other errors triggered by YAML front matter

**Solutions:**

```json
// .markdownlint.json
{
  "MD041": false
}

// Or configure front matter pattern in .markdownlint-cli2.jsonc
{
  "frontMatter": "/^---\\s*\\n[\\s\\S]*?\\n---\\s*$/m"
}
```

### Too Many Files Analyzed

**Symptom:** markdownlint processes files in node_modules or build output

**Solutions:**

```bash
# Exclude in glob pattern
markdownlint-cli2 '**/*.md' '!node_modules/**' '!dist/**' '!build/**'

# Or configure ignores in .markdownlint-cli2.jsonc
```

```json
{
  "ignores": ["node_modules/**", "dist/**", "build/**", ".git/**"],
  "gitignore": true
}
```

## Conflict Resolution

### Biome and Prettier Conflicting

**Symptom:** Files keep changing between the two formatters

**Solutions:**

```bash
# Best solution: remove Prettier entirely, use Biome for everything
bun remove prettier eslint-config-prettier eslint-plugin-prettier
rm .prettierrc* .prettierignore

# If keeping Prettier for unsupported languages:
# Use Biome for JS/TS/JSX/CSS/JSON
# Use Prettier for Markdown, YAML, HTML
```

VS Code `settings.json`:

```json
{
  "editor.defaultFormatter": "biomejs.biome",
  "[markdown]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[yaml]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  }
}
```

### Biome and ESLint Conflicting

**Symptom:** Different rules report different errors

**Solutions:**

```bash
# Disable overlapping ESLint rules
# In .eslintrc, disable rules that Biome handles:
# no-unused-vars -> noUnusedVariables (Biome)
# no-debugger -> noDebugger (Biome)

# Or use eslint-config-biome to disable conflicts
# (community package, check availability)

# Best: complete the migration and remove ESLint
```

### markdownlint and Prettier Conflicting

**Symptom:** Prettier reformats Markdown, markdownlint then flags it

**Solutions:**

```json
// .markdownlint.json - Disable rules that conflict with Prettier
{
  "MD010": false,
  "MD013": false,
  "MD030": false,
  "MD060": false
}
```

```bash
# Run Prettier first, then markdownlint
prettier --write '**/*.md' && markdownlint-cli2 --fix '**/*.md'
```

## Performance Issues

### Biome Slow on Large Repos

**Diagnosis:**

```bash
# Check how many files are processed
bunx --bun biome check --verbose . 2>&1 | head -20

# Check file count
find . -name '*.ts' -o -name '*.tsx' -o -name '*.js' | wc -l
```

**Solutions:**

```json
// biome.json - Limit scope
{
  "files": {
    "includes": ["src/**", "tests/**"],
    "maxSize": 524288
  },
  "vcs": {
    "enabled": true,
    "useIgnoreFile": true
  }
}
```

```bash
# Use daemon for repeated checks
bunx --bun biome start
bunx --bun biome check --use-server .

# Check only changed files
bunx --bun biome check --changed .
```

### markdownlint Slow on Many Files

**Solutions:**

```bash
# Limit scope
markdownlint-cli2 'docs/**/*.md' 'README.md'

# Use .gitignore
```

```json
// .markdownlint-cli2.jsonc
{
  "gitignore": true,
  "ignores": ["node_modules/**", "**/CHANGELOG.md"]
}
```

## Rule-Specific Issues

### noUnusedImports False Positives

**Symptom:** Biome flags type-only imports as unused

**Solutions:**

```json
{
  "linter": {
    "rules": {
      "correctness": {
        "noUnusedImports": "error"
      }
    }
  },
  "javascript": {
    "jsxRuntime": "transparent"
  }
}
```

```bash
# Auto-fix removes unused imports
bunx --bun biome check --write .

# This also converts regular imports to type imports where appropriate
```

### useNamingConvention Too Strict

**Symptom:** Naming convention errors for legitimate patterns

**Solutions:**

```json
{
  "linter": {
    "rules": {
      "style": {
        "useNamingConvention": {
          "level": "warn",
          "options": {
            "strictCase": false,
            "conventions": [
              {
                "selector": { "kind": "variable" },
                "formats": ["camelCase", "CONSTANT_CASE", "PascalCase"]
              },
              {
                "selector": { "kind": "function" },
                "formats": ["camelCase", "PascalCase"]
              }
            ]
          }
        }
      }
    }
  }
}
```

### noConsole Blocking Legitimate Logging

**Solutions:**

```json
{
  "linter": {
    "rules": {
      "suspicious": {
        "noConsole": {
          "level": "warn",
          "options": {
            "allow": ["warn", "error", "info", "debug"]
          }
        }
      }
    }
  }
}
```

```javascript
// Or suppress per-line
// biome-ignore lint/suspicious/noConsole: startup logging
console.log("Server started on port", port);
```

## Common Error Messages

### `The file size exceeds the limit`

```json
// Increase max file size
{
  "files": {
    "maxSize": 2097152
  }
}
```

### `Skipped file because it's ignored`

```bash
# File is in .gitignore and vcs.useIgnoreFile is true
# Either remove from .gitignore or use files.includes to force include
```

### `Parse error: expected expression`

```bash
# File has syntax errors
# Use --skip-parse-errors to continue linting other files
bunx --bun biome check --skip-parse-errors .

# Or format with errors
# "formatter.formatWithErrors": true
```

### markdownlint `ENOENT`

```bash
# File path in glob doesn't exist
# Check glob patterns match actual file locations
ls **/*.md

# Use literal path prefix for special characters
markdownlint-cli2 ':path/with[brackets].md'
```
