# Constitution — Vercel CLI

## Non-Negotiable Principles

### P1: No Production Deploy Without Confirmation

**Statement**: Never run `vercel --prod` without explicit user confirmation. Always create a preview deployment first.
**Rationale**: Production deployments on Vercel are instant and global. A broken production deployment immediately affects all users worldwide with no automatic rollback.
**Violation example**: Running `vercel --prod` without first creating a preview with `vercel` and verifying the preview URL works correctly.

### P2: Use Preview Deployments

**Statement**: Always create a preview deployment (`vercel` without `--prod`) before promoting to production.
**Rationale**: Preview deployments provide a safe environment to verify functionality, performance, and visual correctness before exposing changes to real users.
**Violation example**: Skipping the preview step and deploying directly to production with `vercel --prod`.

### P3: Verify Environment Variables

**Statement**: Always verify that required environment variables are set before deploying. Never hardcode secrets in code or configuration.
**Rationale**: Missing environment variables cause runtime failures in production. Hardcoded secrets in deployed code are exposed to the client and logged in build output.
**Violation example**: Deploying without checking `vercel env ls` and having the application crash because `DATABASE_URL` is undefined in production.

## Validation Checklist

- [ ] P1 respected: Production deployments confirmed by user before execution
- [ ] P2 respected: Preview deployment created and verified before production
- [ ] P3 respected: Environment variables verified before deployment

## Amendment Process

1. Document the proposed change
2. Justify why the existing principle is insufficient
3. Get explicit user approval
4. Update this file with change date and rationale
