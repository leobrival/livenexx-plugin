# Linter Setup Commands Reference

Complete reference for Biome and markdownlint-cli2 CLI commands, configuration schema, and rule groups.

## Biome CLI Commands

### `biome check`

Run formatter, linter, and import organizer.

```bash
# Check all files
biome check .

# Check specific files
biome check src/index.ts src/utils.ts

# Auto-fix issues
biome check --write .

# Fix including unsafe fixes
biome check --write --unsafe .

# Only lint staged files
biome check --staged --write

# Only lint changed files (vs default branch)
biome check --changed --write

# Only lint changes since specific ref
biome check --since=main --write

# Run specific rule groups only
biome check --only=correctness .
biome check --only=style/useConst .

# Skip specific rules
biome check --skip=style/noNonNullAssertion .

# Suppress violations with comment
biome check --write --suppress --reason="todo: fix later" .

# Limit diagnostics output
biome check --max-diagnostics=20 .

# Treat warnings as errors
biome check --error-on-warnings .
```

### `biome lint`

Run linter only (no formatting).

```bash
# Lint all files
biome lint .

# Auto-fix lint issues
biome lint --write .

# With unsafe fixes
biome lint --write --unsafe .

# Specific files
biome lint src/**/*.ts
```

### `biome format`

Run formatter only (no linting).

```bash
# Check formatting (no changes)
biome format .

# Apply formatting
biome format --write .

# Format stdin
echo '{"key":"value"}' | biome format --stdin-file-path=data.json
```

### `biome ci`

Read-only mode for CI pipelines. Never writes files.

```bash
# Basic CI check
biome ci .

# GitHub Actions reporter (creates annotations)
biome ci --reporter=github .

# JUnit XML output
biome ci --reporter=junit . > report.xml

# GitLab reporter
biome ci --reporter=gitlab .

# Summary only
biome ci --reporter=summary .
```

**Available reporters:** `json`, `json-pretty`, `github`, `junit`, `summary`, `gitlab`, `checkstyle`, `rdjson`

### `biome init`

Create configuration file.

```bash
# Create biome.json
biome init

# Create biome.jsonc (with comments)
biome init --jsonc
```

### `biome migrate`

Upgrade config or migrate from other tools.

```bash
# Upgrade config for breaking changes
biome migrate --write

# Migrate from ESLint
biome migrate eslint --write

# Migrate with inspired rules (similar but not identical)
biome migrate eslint --write --include-inspired

# Migrate with nursery rules
biome migrate eslint --write --include-nursery

# Migrate from Prettier
biome migrate prettier --write
```

### `biome search`

Search code patterns with GritQL.

```bash
# Find all console.log calls
biome search 'console.log($args)' .

# Find specific patterns
biome search 'if ($x === null)' src/
```

### `biome explain`

Get documentation for a rule.

```bash
biome explain noDebugger
biome explain useConst
biome explain style/useTemplate
```

### Utility Commands

```bash
# Debug info (config resolution, file paths)
biome rage

# Start/stop daemon
biome start
biome stop

# Clean daemon logs
biome clean

# Version
biome version
```

### Global Flags

| Flag | Description |
|------|-------------|
| `--write` / `--fix` | Apply changes to files |
| `--unsafe` | Apply unsafe fixes too |
| `--staged` | Only process git-staged files |
| `--changed` | Only changed files vs default branch |
| `--since REF` | Only changed files since git ref |
| `--only=group/rule` | Run only specific rules |
| `--skip=group/rule` | Exclude specific rules |
| `--suppress` | Add suppression comments |
| `--reason "text"` | Reason for suppression |
| `--config-path PATH` | Custom config location |
| `--max-diagnostics N` | Limit output count |
| `--error-on-warnings` | Treat warnings as errors |
| `--reporter FORMAT` | Output format |
| `--colors off\|force` | Color output control |
| `--verbose` | Verbose output |
| `--use-server` | Use daemon process |
| `--stdin-file-path` | Process stdin as file |
| `--no-errors-on-unmatched` | No error for zero matches |
| `--skip-parse-errors` | Ignore parse errors |
| `--diagnostic-level` | Min level: `info`, `warn`, `error` |

**Exit codes:** `0` = success, `1` = errors found, `2` = execution failure

---

## Biome Configuration Schema

### Full `biome.json` Structure

```jsonc
{
  // Schema validation
  "$schema": "https://biomejs.dev/schemas/2.3.11/schema.json",

  // Inherit from other configs
  "extends": ["./base.json"],

  // Stop config lookup at this file
  "root": true,

  // File handling
  "files": {
    "includes": ["src/**", "tests/**"],  // "!" to exclude, "!!" to force exclude
    "ignoreUnknown": false,
    "maxSize": 1048576
  },

  // Version control
  "vcs": {
    "enabled": true,
    "clientKind": "git",
    "useIgnoreFile": true,
    "root": ".",
    "defaultBranch": "main"
  },

  // Global formatter settings
  "formatter": {
    "enabled": true,
    "includes": ["src/**"],
    "formatWithErrors": false,
    "indentStyle": "tab",         // "tab" | "space"
    "indentWidth": 2,
    "lineEnding": "lf",           // "lf" | "crlf" | "cr"
    "lineWidth": 80,
    "attributePosition": "auto",  // "auto" | "multiline"
    "bracketSpacing": true,
    "expand": "auto",             // "auto" | "always" | "never"
    "useEditorconfig": false
  },

  // Linter settings
  "linter": {
    "enabled": true,
    "includes": ["src/**"],
    "rules": {
      "recommended": true,
      "a11y": {},            // accessibility rules
      "complexity": {},      // code complexity rules
      "correctness": {},     // bug detection rules
      "nursery": {},         // experimental rules (opt-in)
      "performance": {},     // performance rules
      "security": {},        // security rules
      "style": {},           // code style rules
      "suspicious": {}       // suspicious code rules
    },
    "domains": {
      "react": "recommended",   // "recommended" | "all" | "off"
      "solid": "off",
      "test": "recommended"
    }
  },

  // JavaScript/TypeScript settings
  "javascript": {
    "parser": {
      "unsafeParameterDecoratorsEnabled": false,
      "jsxEverywhere": true
    },
    "formatter": {
      "quoteStyle": "double",        // "single" | "double"
      "jsxQuoteStyle": "double",     // "single" | "double"
      "quoteProperties": "asNeeded", // "asNeeded" | "preserve"
      "trailingCommas": "all",       // "all" | "es5" | "none"
      "semicolons": "always",        // "always" | "asNeeded"
      "arrowParentheses": "always",  // "always" | "asNeeded"
      "bracketSameLine": false,
      "bracketSpacing": true,
      "operatorLinebreak": "after",  // "after" | "before"
      "expand": "auto"               // "auto" | "always" | "never"
    },
    "globals": ["Bun", "Deno"],
    "jsxRuntime": "transparent",     // "transparent" | "reactClassic"
    "linter": { "enabled": true },
    "assist": { "enabled": true }
  },

  // JSON settings
  "json": {
    "parser": {
      "allowComments": false,
      "allowTrailingCommas": false
    },
    "formatter": {
      "enabled": true,
      "trailingCommas": "none",
      "bracketSpacing": true,
      "expand": "auto"
    }
  },

  // CSS settings
  "css": {
    "parser": {
      "cssModules": false,
      "tailwindDirectives": false
    },
    "formatter": {
      "enabled": false,
      "quoteStyle": "double"
    }
  },

  // GraphQL settings
  "graphql": {
    "formatter": {
      "enabled": false,
      "quoteStyle": "double"
    }
  },

  // HTML settings (experimental)
  "html": {
    "formatter": {
      "enabled": false,
      "whitespaceSensitivity": "css",  // "css" | "strict" | "ignore"
      "indentScriptAndStyle": false,
      "selfCloseVoidElements": "never",
      "bracketSameLine": false
    }
  },

  // Assist (code actions)
  "assist": {
    "enabled": true,
    "includes": [],
    "actions": {
      "recommended": true
    }
  },

  // Per-file overrides
  "overrides": [
    {
      "includes": ["**/*.test.ts"],
      "linter": {
        "rules": {
          "suspicious": { "noExplicitAny": "off" }
        }
      }
    }
  ]
}
```

### Linter Rule Groups

| Group | Default Severity | Description |
|-------|-----------------|-------------|
| `a11y` | error | Accessibility violations (ARIA, alt text, labels) |
| `complexity` | error | Overly complex code (cyclomatic, nesting depth) |
| `correctness` | error | Incorrect or useless code (unreachable, unused) |
| `nursery` | - | Experimental rules, must be enabled explicitly |
| `performance` | error | Performance anti-patterns (delete, spread in accumulators) |
| `security` | error | Security vulnerabilities (dangerouslySetInnerHTML, eval) |
| `style` | warn | Code style consistency (naming, const, template literals) |
| `suspicious` | error | Suspicious patterns (debugger, duplicate keys, any) |

### Rule Severity Levels

| Level | Behavior |
|-------|----------|
| `"error"` | Exits with non-zero code |
| `"warn"` | Warning only (unless `--error-on-warnings`) |
| `"info"` | Informational, no exit code impact |
| `"off"` | Disabled |
| `"on"` | Enabled at default severity |

### Rule Configuration Syntax

```jsonc
{
  "linter": {
    "rules": {
      // Enable/disable entire group
      "style": "off",

      // Configure individual rules
      "suspicious": {
        "noDebugger": "error",          // severity only
        "noExplicitAny": "warn",

        // severity + options
        "noConsole": {
          "level": "warn",
          "options": {
            "allow": ["warn", "error", "info"]
          }
        }
      },

      // Naming conventions with options
      "style": {
        "useNamingConvention": {
          "level": "error",
          "options": {
            "strictCase": false,
            "conventions": [
              { "selector": { "kind": "variable" }, "formats": ["camelCase", "CONSTANT_CASE"] }
            ]
          }
        }
      }
    }
  }
}
```

---

## markdownlint-cli2 CLI

### Commands

```bash
# Lint Markdown files
markdownlint-cli2 '**/*.md'

# Lint with exclusions
markdownlint-cli2 '**/*.md' '!node_modules/**' '!dist/**'

# Auto-fix issues
markdownlint-cli2 --fix '**/*.md'

# Custom config file
markdownlint-cli2 --config .markdownlint-custom.jsonc '**/*.md'

# Format stdin to stdout
echo "# Test" | markdownlint-cli2 --format

# No globs from config
markdownlint-cli2 --no-globs specific-file.md

# Literal path (bypass glob expansion)
markdownlint-cli2 ':path/with[brackets].md'

# Read from stdin
echo "# Test" | markdownlint-cli2 -
```

**Exit codes:** `0` = no errors, `1` = lint errors found, `2` = execution failure

### Configuration Files

**Discovery order (in same directory):**
1. `.markdownlint-cli2.jsonc`
2. `.markdownlint-cli2.yaml`
3. `.markdownlint-cli2.cjs`
4. `.markdownlint-cli2.mjs`
5. `package.json` (root only, `markdownlint-cli2` key)

**Rule-only config (overrides `config` property):**
- `.markdownlint.jsonc`
- `.markdownlint.json`
- `.markdownlint.yaml`
- `.markdownlint.yml`
- `.markdownlint.cjs`
- `.markdownlint.mjs`

### Full `.markdownlint-cli2.jsonc` Schema

```jsonc
{
  // Rule configuration
  "config": {
    "default": true,
    "MD013": false,
    "MD029": false,
    "MD033": { "allowed_elements": ["br", "details", "summary"] },
    "MD060": false
  },

  // Custom rules (npm packages or local paths)
  "customRules": ["markdownlint-rule-search-replace"],

  // Auto-fix on run
  "fix": false,

  // Front matter pattern (RegExp)
  "frontMatter": "/^---\\s*\\n[\\s\\S]*?\\n---\\s*$/m",

  // Respect .gitignore
  "gitignore": true,

  // Default glob patterns
  "globs": ["**/*.md"],

  // Exclude patterns
  "ignores": ["node_modules/**", "dist/**", "build/**"],

  // markdown-it plugins
  "markdownItPlugins": [
    ["markdown-it-footnote"]
  ],

  // Additional module resolution paths
  "modulePaths": ["./node_modules"],

  // Suppress version banner
  "noBanner": true,

  // Disable inline config (HTML comments)
  "noInlineConfig": false,

  // Suppress progress dots
  "noProgress": false,

  // Output formatters
  "outputFormatters": [
    ["markdownlint-cli2-formatter-pretty"]
  ],

  // Show found files
  "showFound": false
}
```

### Simplified `.markdownlint.json`

```json
{
  "default": true,
  "MD013": false,
  "MD029": false,
  "MD033": {
    "allowed_elements": ["br", "details", "summary", "img"]
  },
  "MD041": false,
  "MD047": true,
  "MD060": false,
  "extends": "./node_modules/some-shared-config/index.json"
}
```

### Key markdownlint Rules

| Rule | Alias | Fixable | Description |
|------|-------|---------|-------------|
| MD001 | heading-increment | No | Heading levels increment by one |
| MD003 | heading-style | No | Consistent heading style (atx/setext) |
| MD004 | ul-style | Yes | Unordered list style (dash/asterisk/plus) |
| MD005 | list-indent | Yes | Consistent list item indentation |
| MD007 | ul-indent | Yes | Unordered list indent (default: 2) |
| MD009 | no-trailing-spaces | Yes | No trailing whitespace |
| MD010 | no-hard-tabs | Yes | No hard tabs |
| MD012 | no-multiple-blanks | Yes | No multiple consecutive blank lines |
| MD013 | line-length | No | Line length limit (default: 80) |
| MD022 | blanks-around-headings | Yes | Blank lines around headings |
| MD024 | no-duplicate-headings | No | No duplicate heading text |
| MD025 | single-h1 | No | Single H1 per document |
| MD031 | blanks-around-fences | Yes | Blank lines around code fences |
| MD032 | blanks-around-lists | Yes | Blank lines around lists |
| MD033 | no-html | No | No inline HTML |
| MD034 | no-bare-urls | Yes | No bare URLs |
| MD040 | fenced-code-language | No | Language required on code fences |
| MD041 | first-line-h1 | No | First line must be H1 |
| MD047 | single-trailing-newline | Yes | Single trailing newline |
| MD048 | code-fence-style | Yes | Consistent fence style (backtick/tilde) |
| MD049 | emphasis-style | Yes | Consistent emphasis style |
| MD050 | strong-style | Yes | Consistent strong style |
| MD058 | blanks-around-tables | Yes | Blank lines around tables |

### Inline Suppression

```markdown
<!-- markdownlint-disable MD013 -->
This long line will not be flagged by the line-length rule.
<!-- markdownlint-enable MD013 -->

<!-- markdownlint-disable-next-line MD041 -->
Not a heading on the first line.

<!-- markdownlint-disable MD033 MD013 -->
Multiple rules disabled at once.
<!-- markdownlint-enable -->

<!-- markdownlint-capture -->
<!-- markdownlint-disable -->
Everything here is ignored.
<!-- markdownlint-restore -->
```
