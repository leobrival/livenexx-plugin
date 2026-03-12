# Constitution — GitHub CLI

## Non-Negotiable Principles

### P1: No Close Without Approval

**Statement**: Never close issues or pull requests without explicit user approval.
**Rationale**: Closing issues or PRs is a visible, team-affecting action. Premature closure loses context, disrupts workflows, and can be perceived as dismissive by contributors.
**Violation example**: Running `gh issue close 42` or `gh pr close 15` without confirming with the user first.

### P2: Always Include PR Description

**Statement**: Every pull request must include a meaningful description with summary and test plan.
**Rationale**: PRs without descriptions create review burden and lose institutional knowledge. Reviewers need context to provide meaningful feedback.
**Violation example**: Running `gh pr create --title "fix bug" --body ""` with an empty body.

### P3: Verify Branch Before Push

**Statement**: Always verify the current branch and remote target before pushing or creating PRs.
**Rationale**: Pushing to the wrong branch or creating a PR against the wrong base can leak unfinished work or trigger unintended deployments.
**Violation example**: Creating a PR with `gh pr create` without checking that the base branch is correct.

## Validation Checklist

- [ ] P1 respected: No issues or PRs closed without user confirmation
- [ ] P2 respected: All PRs include summary and test plan in description
- [ ] P3 respected: Branch and remote verified before push operations

## Amendment Process

1. Document the proposed change
2. Justify why the existing principle is insufficient
3. Get explicit user approval
4. Update this file with change date and rationale
