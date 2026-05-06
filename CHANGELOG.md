# Changelog

All notable changes to this add-on are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] — 2026-05-05

Initial release. The [MCP Inspector](https://github.com/modelcontextprotocol/inspector)
running as a service inside your DDEV project. Test stdio, SSE, and
Streamable HTTP MCP servers from any framework — Craft, Laravel, Drupal,
Node, Python, anything you build inside DDEV — without installing Node on
the host.

### Highlights
- **Pre-installed Inspector image.** The Inspector binary is baked in at
  build time, so `ddev start` after the first build comes up in a few
  seconds instead of waiting on `npm install`.
- **Pinned upstream version** (`@modelcontextprotocol/inspector@0.21.2`).
  Bumps are explicit edits to the Dockerfile, not silent `@latest` drift.
- **Sibling-container MCP servers.** The Inspector container has access
  to the Docker socket and ships with `docker-cli`, so it spawns stdio
  MCP servers in your project's web container via `docker exec`. No
  framework runtimes on the host.
- **Bats test suite** covering install, restart, client UI reachability,
  proxy reachability, host command output, and add-on removal.
- **CI matrix** `[stable, HEAD]` on `ddev/github-action-add-on-test@v2`
  with a daily cron schedule for upstream-regression detection.
- **Clean removal.** `ddev add-on remove mcp-inspector` reverses the
  install via `removal_actions` in `install.yaml`.
- **Host command** with sensible actions: `open` (default), `status`,
  `logs`, `urls`, `version`. `status` checks the actually reachable
  endpoint, not a `/health` route the Inspector doesn't expose.
- **Sponsorship links** via [GitHub Sponsors](https://github.com/sponsors/michtio)
  and [Buy Me a Coffee](https://www.buymeacoffee.com/michtio) — see
  `.github/FUNDING.yml`.

### Endpoints
- Client UI: `https://<project>.ddev.site:6275` (HTTP fallback `:6274`)
- Proxy: `https://<project>.ddev.site:6277` (HTTPS-only externally so
  the browser can fetch from the HTTPS UI without mixed-content errors)
- From sibling containers: `http://mcp-inspector:6274` and
  `http://mcp-inspector:6277`

### Security note
The `/var/run/docker.sock` mount is intentional: it's what lets the
Inspector container spawn stdio MCP servers in sibling DDEV containers.
This gives the Inspector container root-equivalent access to the host
Docker daemon. Acceptable for a local-dev tool; **do not run this image
in production** or expose it to untrusted networks. `DANGEROUSLY_OMIT_AUTH`
defaults to `true` for the same reason — fine on DDEV-local, do not
publish.
