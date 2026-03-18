---
description: Start the development server for the current project with auto-detection
allowed-tools: Bash(bun *), Bash(npm *), Bash(pnpm *), Bash(yarn *), Bash(npx *), Bash(bunx *), Bash(cat *), Bash(lsof *), Bash(kill *), Read, Glob
---

## Context

- Current directory: !`pwd`
- Package manager lockfiles: !`ls -1 bun.lockb package-lock.json pnpm-lock.yaml yarn.lock 2>/dev/null || echo "none found"`
- Package.json scripts: !`cat package.json 2>/dev/null | grep -A 20 '"scripts"' || echo "no package.json"`

## Instructions

Start the development server for the current project. Follow these steps:

### Step 1: Detect Package Manager

Check for lockfiles in priority order:
1. `bun.lockb` → use `bun`
2. `pnpm-lock.yaml` → use `pnpm`
3. `yarn.lock` → use `yarn`
4. `package-lock.json` → use `npm`
5. No lockfile → default to `bun`

### Step 2: Detect Dev Script

Read `package.json` scripts and find the dev command:
1. If `"dev"` script exists → use it
2. If `"start:dev"` script exists → use it
3. If `"serve"` script exists → use it
4. Otherwise → report that no dev script was found and suggest creating one

### Step 3: Check Port Availability

Check if the default port (usually 3000) is already in use:
```bash
lsof -ti:3000
```

If occupied, inform the user and suggest:
- Kill the existing process: `lsof -ti:3000 | xargs kill -9`
- Use an alternative port (pass `--port 3001` or `-p 3001`)

### Step 4: Start the Server

Run the dev server in background using the detected package manager:
```bash
{package_manager} run dev
```

**Framework-specific flags** (apply automatically if detected):
- **Next.js** (`next dev` in scripts): Add `--turbopack` unless `--webpack` is in the script
- **Vite** (`vite` in scripts): No extra flags needed
- **AdonisJS** (`node ace serve` in scripts): Add `--hmr` if not present

### Step 5: Verify

Wait a few seconds, then confirm:
- Server is running (process alive)
- Report the URL (e.g., `http://localhost:3000`)
- Report any startup errors from the console

### Special Cases

- If `$ARGUMENTS` contains a port number, use that port
- If `$ARGUMENTS` contains `--help`, show this command's usage
- If the project has a known issue with Turbopack (e.g., crashes), fall back to webpack
