# Constitution — Docker CLI

## Non-Negotiable Principles

### P1: No Root in Production

**Statement**: Never run containers as root in production environments. Always specify a non-root user.
**Rationale**: Running as root inside a container exposes the host to privilege escalation attacks. A container breakout with root access compromises the entire host system.
**Violation example**: Deploying a Dockerfile without `USER` directive or running `docker run` without `--user` flag in production.

### P2: Pin Image Versions

**Statement**: Always use specific image tags (e.g., `node:22.3.0-alpine`) instead of `latest` or mutable tags.
**Rationale**: Mutable tags like `latest` cause non-reproducible builds. A previously working deployment can break silently when the upstream image changes.
**Violation example**: Using `FROM node:latest` in a Dockerfile or `docker pull nginx:latest` for production deployments.

### P3: No Unnecessary Ports

**Statement**: Never expose ports that are not required by the application. Only bind to specific interfaces when possible.
**Rationale**: Exposed ports increase the attack surface. Binding to `0.0.0.0` when only localhost access is needed allows external access to internal services.
**Violation example**: Running `docker run -p 0.0.0.0:5432:5432 postgres` when the database should only be accessible from the application network.

## Validation Checklist

- [ ] P1 respected: Containers run as non-root user in production
- [ ] P2 respected: All image references use pinned version tags
- [ ] P3 respected: Only required ports are exposed with appropriate interface binding

## Amendment Process

1. Document the proposed change
2. Justify why the existing principle is insufficient
3. Get explicit user approval
4. Update this file with change date and rationale
