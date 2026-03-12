# Linter Setup Common Patterns

Real-world patterns and workflows for setting up and configuring Biome and markdownlint-cli2.

## Project Setup Recipes

### TypeScript Project (Node.js / Bun)

```bash
# Install
bun add -D -E @biomejs/biome markdownlint-cli2

# Init
bunx --bun biome init
```

`biome.json`:

```json
{
  "$schema": "https://biomejs.dev/schemas/2.3.11/schema.json",
  "vcs": {
    "enabled": true,
    "clientKind": "git",
    "useIgnoreFile": true,
    "defaultBranch": "main"
  },
  "formatter": {
    "indentStyle": "tab",
    "lineWidth": 80
  },
  "linter": {
    "rules": {
      "recommended": true,
      "style": {
        "useConst": "error",
        "useTemplate": "error"
      }
    }
  },
  "javascript": {
    "formatter": {
      "quoteStyle": "double",
      "semicolons": "always",
      "trailingCommas": "all"
    }
  }
}
```

### React / Next.js Project

```json
{
  "$schema": "https://biomejs.dev/schemas/2.3.11/schema.json",
  "vcs": {
    "enabled": true,
    "clientKind": "git",
    "useIgnoreFile": true
  },
  "formatter": {
    "indentStyle": "tab"
  },
  "linter": {
    "rules": {
      "recommended": true,
      "correctness": {
        "useExhaustiveDependencies": "warn"
      }
    },
    "domains": {
      "react": "recommended"
    }
  },
  "javascript": {
    "jsxRuntime": "transparent",
    "formatter": {
      "quoteStyle": "double",
      "jsxQuoteStyle": "double"
    }
  },
  "css": {
    "formatter": { "enabled": true }
  },
  "overrides": [
    {
      "includes": ["next.config.*"],
      "linter": {
        "rules": {
          "style": { "useDefaultParameterLast": "off" }
        }
      }
    }
  ]
}
```

### Full-Stack with Tailwind CSS

```json
{
  "$schema": "https://biomejs.dev/schemas/2.3.11/schema.json",
  "formatter": {
    "indentStyle": "tab"
  },
  "linter": {
    "rules": {
      "recommended": true
    },
    "domains": {
      "react": "recommended"
    }
  },
  "css": {
    "parser": {
      "tailwindDirectives": true
    },
    "formatter": {
      "enabled": true
    }
  }
}
```

### Library / Package

```json
{
  "$schema": "https://biomejs.dev/schemas/2.3.11/schema.json",
  "vcs": {
    "enabled": true,
    "clientKind": "git",
    "useIgnoreFile": true
  },
  "formatter": {
    "indentStyle": "tab"
  },
  "linter": {
    "rules": {
      "recommended": true,
      "style": {
        "noNonNullAssertion": "error",
        "useExportType": "error",
        "useImportType": "error"
      },
      "suspicious": {
        "noExplicitAny": "error"
      }
    }
  },
  "overrides": [
    {
      "includes": ["**/*.test.ts", "**/*.spec.ts"],
      "linter": {
        "rules": {
          "suspicious": { "noExplicitAny": "off" }
        }
      }
    }
  ]
}
```

## Migration Recipes

### Complete ESLint + Prettier Migration

```bash
# Step 1: Migrate ESLint
bunx --bun biome migrate eslint --write --include-inspired

# Step 2: Migrate Prettier
bunx --bun biome migrate prettier --write

# Step 3: Suppress all existing violations
bunx --bun biome check --write --unsafe --suppress="migration"

# Step 4: Verify
bunx --bun biome check .

# Step 5: Run both tools in parallel during transition
# package.json:
# "lint": "biome check . && eslint --no-error-on-unmatched-pattern src/",

# Step 6: When confident, remove ESLint + Prettier
bun remove \
  eslint prettier \
  @typescript-eslint/parser @typescript-eslint/eslint-plugin \
  eslint-config-prettier eslint-plugin-prettier \
  eslint-plugin-react eslint-plugin-react-hooks \
  eslint-plugin-import eslint-plugin-jsx-a11y

rm -f .eslintrc* .eslintignore .prettierrc* .prettierignore
```

### Gradual Migration (Keep ESLint for Unsupported Rules)

```bash
# Migrate only the rules Biome supports
bunx --bun biome migrate eslint --write

# Keep ESLint for remaining rules
# In .eslintrc, remove rules now handled by Biome
# Run both in CI:
# biome check . && eslint src/
```

### From TSLint (legacy)

```bash
# TSLint -> ESLint first (if not done)
npx tslint-to-eslint-config

# Then ESLint -> Biome
bunx --bun biome migrate eslint --write
```

## npm Scripts Patterns

### Standard Setup

```json
{
  "scripts": {
    "lint": "biome check .",
    "lint:fix": "biome check --write .",
    "format": "biome format --write .",
    "lint:md": "markdownlint-cli2 '**/*.md' '!node_modules/**'",
    "fix:md": "markdownlint-cli2 --fix '**/*.md' '!node_modules/**'",
    "lint:all": "biome check . && markdownlint-cli2 '**/*.md' '!node_modules/**'",
    "fix:all": "biome check --write . && markdownlint-cli2 --fix '**/*.md' '!node_modules/**'"
  }
}
```

### With Typecheck and Build

```json
{
  "scripts": {
    "lint": "biome check .",
    "lint:fix": "biome check --write .",
    "typecheck": "tsc --noEmit",
    "validate": "bun run typecheck && bun run lint && bun run lint:md",
    "lint:md": "markdownlint-cli2 '**/*.md' '!node_modules/**'",
    "fix:md": "markdownlint-cli2 --fix '**/*.md' '!node_modules/**'"
  }
}
```

## CI/CD Integration

### GitHub Actions (Full)

```yaml
name: Code Quality
on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v2
      - run: bun install

      # Biome with GitHub annotations
      - name: Biome lint
        run: bunx --bun biome ci --reporter=github .

      # markdownlint
      - uses: DavidAnson/markdownlint-cli2-action@main
        with:
          globs: "**/*.md"

      # TypeScript check
      - name: Type check
        run: bunx tsc --noEmit
```

### GitLab CI

```yaml
lint:
  image: oven/bun:latest
  script:
    - bun install
    - bunx --bun biome ci --reporter=gitlab . > gl-codequality.json || true
    - bunx markdownlint-cli2 '**/*.md' '!node_modules/**'
  artifacts:
    reports:
      codequality: gl-codequality.json
```

### Pre-commit Hook (lefthook)

`lefthook.yml`:

```yaml
pre-commit:
  parallel: true
  commands:
    biome:
      glob: "*.{js,ts,jsx,tsx,css,json,graphql}"
      run: bunx --bun biome check --staged --write --no-errors-on-unmatched {staged_files}
      stage_fixed: true
    markdownlint:
      glob: "*.md"
      run: bunx markdownlint-cli2 --fix {staged_files}
      stage_fixed: true
```

### Pre-commit Hook (husky + lint-staged)

```json
{
  "lint-staged": {
    "*.{js,ts,jsx,tsx,css,json}": [
      "biome check --write --no-errors-on-unmatched"
    ],
    "*.md": [
      "markdownlint-cli2 --fix"
    ]
  }
}
```

## Monorepo Patterns

### Shared Root Config

```
monorepo/
├── biome.json           (shared base)
├── .markdownlint.json   (shared markdown rules)
├── packages/
│   ├── web/
│   │   └── biome.json   (extends root, adds React domain)
│   ├── api/
│   │   └── biome.json   (extends root, adds Node globals)
│   └── shared/
│       └── biome.json   (extends root, stricter rules)
```

Root `biome.json`:

```json
{
  "$schema": "https://biomejs.dev/schemas/2.3.11/schema.json",
  "vcs": { "enabled": true, "clientKind": "git", "useIgnoreFile": true },
  "formatter": { "indentStyle": "tab" },
  "linter": { "rules": { "recommended": true } }
}
```

`packages/web/biome.json`:

```json
{
  "extends": ["../../biome.json"],
  "linter": { "domains": { "react": "recommended" } }
}
```

`packages/api/biome.json`:

```json
{
  "extends": ["../../biome.json"],
  "javascript": { "globals": ["Bun", "process"] }
}
```

### Per-Package Scripts (Turborepo)

`turbo.json`:

```json
{
  "tasks": {
    "lint": {
      "dependsOn": ["^lint"]
    },
    "lint:fix": {
      "cache": false
    }
  }
}
```

## Editor Configuration

### VS Code (project `.vscode/settings.json`)

```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "biomejs.biome",
  "editor.codeActionsOnSave": {
    "source.fixAll.biome": "explicit",
    "source.organizeImports.biome": "explicit"
  },
  "[markdown]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true
  },
  "[json]": {
    "editor.defaultFormatter": "biomejs.biome"
  },
  "[jsonc]": {
    "editor.defaultFormatter": "biomejs.biome"
  }
}
```

### VS Code Extensions

```json
{
  "recommendations": [
    "biomejs.biome",
    "DavidAnson.vscode-markdownlint"
  ]
}
```

### Zed (project `settings.json`)

```json
{
  "languages": {
    "JavaScript": {
      "formatter": { "language_server": { "name": "biome" } },
      "code_actions_on_format": {
        "source.fixAll.biome": true,
        "source.organizeImports.biome": true
      }
    },
    "TypeScript": {
      "formatter": { "language_server": { "name": "biome" } },
      "code_actions_on_format": {
        "source.fixAll.biome": true,
        "source.organizeImports.biome": true
      }
    },
    "TSX": {
      "formatter": { "language_server": { "name": "biome" } },
      "code_actions_on_format": {
        "source.fixAll.biome": true,
        "source.organizeImports.biome": true
      }
    },
    "CSS": {
      "formatter": { "language_server": { "name": "biome" } }
    },
    "JSON": {
      "formatter": { "language_server": { "name": "biome" } }
    }
  }
}
```

## Advanced Rule Configuration

### Strict Mode (Library Quality)

```json
{
  "linter": {
    "rules": {
      "recommended": true,
      "correctness": {
        "noUnusedVariables": "error",
        "noUnusedImports": "error",
        "useExhaustiveDependencies": "error"
      },
      "style": {
        "noNonNullAssertion": "error",
        "useConst": "error",
        "useExportType": "error",
        "useImportType": "error",
        "useTemplate": "error",
        "useNamingConvention": {
          "level": "error",
          "options": {
            "strictCase": false
          }
        }
      },
      "suspicious": {
        "noExplicitAny": "error",
        "noConsole": {
          "level": "warn",
          "options": { "allow": ["warn", "error"] }
        }
      }
    }
  }
}
```

### Relaxed Mode (Rapid Prototyping)

```json
{
  "linter": {
    "rules": {
      "recommended": true,
      "style": {
        "noNonNullAssertion": "off",
        "useConst": "warn"
      },
      "suspicious": {
        "noExplicitAny": "off",
        "noConsole": "off"
      },
      "complexity": {
        "noForEach": "off"
      }
    }
  }
}
```

### Markdown Config for Documentation Projects

`.markdownlint.json`:

```json
{
  "default": true,
  "MD013": false,
  "MD024": { "allow_different_nesting": true },
  "MD029": false,
  "MD033": {
    "allowed_elements": [
      "br", "details", "summary", "img",
      "a", "sup", "sub", "kbd", "abbr",
      "picture", "source", "video"
    ]
  },
  "MD040": { "allowed_languages": [] },
  "MD041": false,
  "MD044": {
    "names": ["JavaScript", "TypeScript", "Biome", "GitHub"],
    "code_blocks": false
  },
  "MD060": false
}
```

### Markdown Config for API Documentation

`.markdownlint.json`:

```json
{
  "default": true,
  "MD013": { "line_length": 120, "code_blocks": false, "tables": false },
  "MD024": { "allow_different_nesting": true },
  "MD033": { "allowed_elements": ["br", "details", "summary"] },
  "MD036": false,
  "MD041": false
}
```

## Using Both Tools Together

### Combined Validation Script

```bash
#!/bin/bash
# validate.sh - Run all quality checks

set -e

echo "Running Biome check..."
bunx --bun biome check .

echo "Running markdownlint..."
bunx markdownlint-cli2 '**/*.md' '!node_modules/**'

echo "Running TypeScript check..."
bunx tsc --noEmit

echo "All checks passed!"
```

### Combined Fix Script

```bash
#!/bin/bash
# fix.sh - Auto-fix all issues

echo "Fixing code with Biome..."
bunx --bun biome check --write .

echo "Fixing Markdown..."
bunx markdownlint-cli2 --fix '**/*.md' '!node_modules/**'

echo "Done!"
```
