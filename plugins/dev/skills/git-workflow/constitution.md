# Constitution — Git Workflow

## Non-Negotiable Principles

### P1: No Force Push Without Approval

**Statement**: Never execute `git push --force` or `git push --force-with-lease` without explicit user approval.
**Rationale**: Force pushing rewrites remote history and can permanently destroy teammates' work. The damage is often irreversible and affects the entire team.
**Violation example**: Running `git push --force origin main` to fix a merge conflict instead of rebasing or merging properly.

### P2: Feature Branches Only

**Statement**: Never commit directly to `main` or `master`. All changes must go through feature branches.
**Rationale**: Direct commits to protected branches bypass code review, CI checks, and quality gates. Feature branches ensure traceability and reversibility.
**Violation example**: Running `git commit` while on `main` and pushing directly without creating a branch.

### P3: Verify Clean Working Tree

**Statement**: Always verify the working tree state before destructive git operations (reset, checkout, clean).
**Rationale**: Destructive operations on a dirty working tree can permanently lose uncommitted work. A quick `git status` check prevents data loss.
**Violation example**: Running `git checkout -- .` or `git reset --hard` without first checking for uncommitted changes.

## Validation Checklist

- [ ] P1 respected: No force push commands executed without user confirmation
- [ ] P2 respected: Current branch is not `main` or `master` before committing
- [ ] P3 respected: `git status` checked before any destructive operation

## Amendment Process

1. Document the proposed change
2. Justify why the existing principle is insufficient
3. Get explicit user approval
4. Update this file with change date and rationale
