# Livenexx Plugin

Livenexx plugins for Claude Code - development tooling and workflows

## Available Plugins

### Dev

Development CLI skills, GitHub workflows, and Claude Code hooks - Docker, Vercel, Next.js, GitHub CLI, Playwright, Lighthouse, Git workflows, Biome linter setup, and modular status line

**Skills (8)**:

| Category | Skills |
|----------|--------|
| Deployment & Hosting | vercel-cli |
| Frontend & Frameworks | nextjs-cli |
| DevOps & Infrastructure | docker-cli, github-cli |
| Testing & Quality | playwright-cli, lighthouse-cli |
| Claude Code Hooks & Utilities | git-workflow, linter-setup |

**Commands (10)**: `/clean-gone`, `/commit-push-pr`, `/commit`, `/debug`, `/dev`, `/fix-pr-comments`, `/gh-switch`, `/issue-worktree`, `/merge-to-main`, `/run-task`

**Scripts**: git-workflow

## File Structure

```text
livenexx-plugin/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   └── dev/
        ├── README.md
        ├── skills/           # 8 skills
        ├── commands/          # 10 commands
        └── scripts/
├── schemas/
│   └── marketplace.schema.json
└── README.md
```

## Installation

### Via `origin` (leobrival/livenexx-plugin)

```bash
/plugin marketplace add leobrival/livenexx-plugin
/plugin install dev@livenexx-plugin
```

### Via `onylivenexx` (onylivenexx/dev)

```bash
/plugin marketplace add onylivenexx/dev
/plugin install dev@livenexx-plugin
```

### Verify

```bash
/plugin list
```

## License

MIT
