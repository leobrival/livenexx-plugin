# Dev Plugin

Development CLI skills, GitHub workflows, and Claude Code hooks - Docker, Vercel, Next.js, GitHub CLI, Playwright, Lighthouse, Git workflows, Biome linter setup, and modular status line

## Skills (8)

### Deployment & Hosting

| Skill | Description |
|-------|-------------|
| **vercel-cli** | Vercel CLI expert for serverless deployment. |

### Frontend & Frameworks

| Skill | Description |
|-------|-------------|
| **nextjs-cli** | Next.js CLI expert for React development. |

### DevOps & Infrastructure

| Skill | Description |
|-------|-------------|
| **docker-cli** | Docker CLI expert for containerization. |
| **github-cli** | GitHub CLI (gh) expert for repository management. |

### Testing & Quality

| Skill | Description |
|-------|-------------|
| **lighthouse-cli** | Lighthouse CLI expert for web performance auditing. |
| **playwright-cli** | Playwright CLI expert for E2E testing and browser automation. |

### Claude Code Hooks & Utilities

| Skill | Description | Hooks |
|-------|-------------|-------|
| **git-workflow** | Complete Git development workflow toolkit. | `WorktreeCreate`, `WorktreeRemove` |
| **linter-setup** | Linting and formatting setup expert using Biome and markdownlint-cli2. | — |

## Commands (10)

| Command | Description |
|---------|-------------|
| `/clean-gone` | Clean up local branches that no longer exist on remote |
| `/commit-push-pr` | Commit, push, and open a pull request in one command |
| `/commit` | Create a git commit following Commitizen convention with validation and push |
| `/debug` | Detect and fix all project issues - lint, typecheck, tests, build errors |
| `/dev` | Start the development server for the current project with auto-detection |
| `/fix-pr-comments` | Fetch all unresolved comments from current PR and fix them automatically |
| `/gh-switch` | Switch active GitHub account. Usage: /gh-switch <username> |
| `/issue-worktree` | Create an isolated git worktree from a GitHub issue with automated branch nam... |
| `/merge-to-main` | Perform manual merge to main branch with automated conflict resolution and PR... |
| `/run-task` | Execute a task from file path or GitHub issue with full implementation workflow |

## Scripts

### git-workflow

- **worktree-hooks/**
- **worktree-manager/**

## License

MIT
