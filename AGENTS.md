# Idelium Docker Directives

These rules extend the workspace-level Idelium engineering directives.

## Directives

1. **Use English for documentation and source-code comments.** This includes
   Dockerfile comments, shell-script messages, Compose descriptions, operational
   runbooks, and troubleshooting notes.
2. **Build immutable artifacts.** Pin base-image versions or digests and application
   revisions. Production and release configurations must not use `latest` or clone
   a moving branch during a build.
3. **Never embed secrets.** Passwords, private keys, application keys, and tokens
   must come from environment-specific secret management. Commit only documented
   placeholders and safe development defaults.
4. **Use verified downloads.** Do not disable TLS validation. Pin downloaded tools
   and verify checksums or signatures when the upstream supports them.
5. **Make startup deterministic.** Database migrations, seeds, and application
   builds must finish successfully before the stack is reported ready. Avoid
   detached initialization commands whose result is not checked.
6. **Define health and dependency readiness.** Database, API, and frontend services
   require meaningful healthchecks. Depend on health, not merely on container
   process creation.
7. **Separate development and production concerns.** Demo credentials, database
   seeds, self-signed certificates, mounted source, and debugging tools must not be
   enabled implicitly in a production configuration.
8. **Run containers with minimum privilege.** Use non-root users where practical,
   minimize installed packages and image layers, and avoid exposing unnecessary
   ports or services.

## Required verification

- Validate the final Compose configuration.
- Build every image from a clean cache when changing build instructions.
- Start the complete stack and wait for all healthchecks.
- Run an HTTP smoke test through the public frontend endpoint to the API.
- Confirm that no committed file or rendered configuration contains a real secret.
