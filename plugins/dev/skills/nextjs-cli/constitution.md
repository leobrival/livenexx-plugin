# Constitution — nextjs-cli

Non-negotiable principles for the Next.js CLI and scaffolding skill.

## P1 — Never Overwrite Existing Configuration Without Diff Review

**Statement**: Before suggesting any command that modifies `next.config.js`, `next.config.ts`,
`tailwind.config.ts`, `tsconfig.json`, or `.env` files in an existing project, the current file
content must be read and compared against the proposed change. Overwrite-in-place suggestions
are not acceptable without showing the diff.

**Rationale**: `create-next-app` flags and manual config changes silently overwrite existing
configuration. Overwriting a customized `next.config.js` (with custom headers, redirects, or
experimental flags) erases weeks of project-specific work and can break the build.

**Violation example**: Suggesting `npx create-next-app@latest .` in an existing project directory
without warning that this will overwrite configuration files.

**Correct behavior**: Read the existing config file first. Present the proposed change as a diff.
For `create-next-app` in existing projects, explicitly warn: "This command will overwrite
[list files]. Back up custom configurations before running."

---

## P2 — Production Builds Must Pass Lint and Typecheck Before `next build`

**Statement**: The workflow for any production build must include `next lint` and TypeScript
type checking before `next build`. Skipping these steps in a build recommendation is not acceptable.

**Rationale**: `next build` can succeed with TypeScript errors if `typescript.ignoreBuildErrors: true`
is set (a common anti-pattern). Shipping code with type errors to production causes runtime failures
that could have been caught pre-deployment. Lint must also pass to enforce consistent code quality.

**Violation example**: Providing a deploy workflow that goes directly from code changes to
`npm run build` without a lint or typecheck step.

**Correct behavior**: Structure production build workflows as:
1. `npm run lint` (or `bun run lint`)
2. `npm run typecheck` (or equivalent)
3. `npm run build`
4. `npm run start` (local production test)

---

## P3 — Environment Variables Containing Secrets Must Never Have `NEXT_PUBLIC_` Prefix

**Statement**: Any environment variable containing a secret, API key, database URL, or credential
must not be prefixed with `NEXT_PUBLIC_`. If the user's requested configuration would expose a
secret client-side, this must be flagged and corrected.

**Rationale**: `NEXT_PUBLIC_` variables are inlined into the JavaScript bundle and visible to
any browser user who inspects the source. Exposing database URLs, API keys, or tokens this way
is a critical security vulnerability.

**Violation example**: Generating `.env.local` with `NEXT_PUBLIC_DATABASE_URL=postgresql://...`
or `NEXT_PUBLIC_STRIPE_SECRET_KEY=sk_live_...`.

**Correct behavior**: Remove the `NEXT_PUBLIC_` prefix from any secret. If the client-side code
genuinely needs to call an external service, generate an API route in `app/api/` as a server-side
proxy instead of exposing the secret client-side.

---

## P4 — Cache Invalidation Strategy Must Match Data Freshness Requirements

**Statement**: When recommending a data fetching strategy (`cache: 'force-cache'`, ISR, SSR),
the recommendation must be justified by the data's update frequency. Using `force-cache` for
content that updates frequently, or `cache: 'no-store'` for static content, must be flagged.

**Rationale**: Incorrect cache strategy is the leading cause of stale content bugs (users see
outdated data) and unnecessary server load (SSR for static content that never changes). The
recommendation must match the actual data characteristics.

**Violation example**: Recommending `cache: 'force-cache'` for a pricing page that updates
weekly without mentioning ISR with `revalidate: 86400`.

**Correct behavior**: Map cache strategy to data freshness:
- Static (never changes) → `force-cache`
- Updates periodically → ISR with appropriate `revalidate` value
- Real-time or per-user → `cache: 'no-store'`

State the reasoning for the chosen strategy in the recommendation.

---

## Validation Checklist

Before delivering any Next.js CLI guidance:

- [ ] Existing config files read before any overwrite suggestion
- [ ] Production build workflows include lint → typecheck → build sequence
- [ ] No `NEXT_PUBLIC_` prefix on environment variables containing secrets
- [ ] Data fetching cache strategy justified by data freshness requirements
- [ ] Dependency version pinned (not `latest`) when suggesting package.json changes
- [ ] App Router patterns used for Next.js 13+ projects (not Pages Router unless explicitly requested)

---

## Amendment Process

Principles may be amended when:

1. Next.js introduces a built-in secrets management solution that changes the `NEXT_PUBLIC_` risk model
2. A major Next.js version (15+) changes the default caching behavior or config file format
3. A project uses Pages Router by design (document the reason and adjust P4 accordingly)

Document the Next.js version, changelog URL, and date for any amendment.
P3 (no secrets client-side) cannot be weakened under any circumstance.
