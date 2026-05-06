# Changelog

All notable changes to this add-on are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] — 2026-05-05

Initial stable release. Full rewrite from a 2025 beta — the previous codebase
shipped a working client UI but documented features (a `mcp-connect` web
command, persistent volumes, Bats tests, health checks, an HTTPS proxy URL on
:6278) that were never implemented or were broken. This release ships only
what works.

### Added
- Pre-installed MCP Inspector image. The Inspector binary is baked into the
  image at build time, so `ddev start` after the first build comes up in
  seconds instead of waiting on `npm install`.
- Pinned MCP Inspector version (`@modelcontextprotocol/inspector@0.21.2`).
  Bumps are explicit edits to the Dockerfile, not silent `@latest` drift.
- Real Bats test suite covering install, restart, client UI reachability,
  proxy reachability, host command output, and add-on removal.
- CI matrix `[stable, HEAD]` against `ddev/github-action-add-on-test@v2`
  with daily cron schedule for upstream regression detection.
- `removal_actions` in `install.yaml` — `ddev add-on remove mcp-inspector`
  now leaves the project clean.
- `commands/host/mcp-inspector` actions: `open` (default), `status`, `logs`,
  `urls`, `version`. Status checks the actual reachable endpoint, not a
  nonexistent `/health` route.
- GitHub Sponsors and Buy Me a Coffee links (see `.github/FUNDING.yml`).

### Fixed
- Proxy URL on HTTPS:6277 actually works end-to-end. The previous beta
  documented `:6278` but never bound it; this release exposes the proxy
  on HTTPS:6277 directly (matching the inspector's `SERVER_PORT`, which
  is what the inspector's browser-side JS uses to derive the proxy URL).
- `ddev mcp-inspector status` returns truthful output. Previously always
  reported failure.

### Removed
- Unused `/var/run/docker.sock` mount.
- Unused `apk add git` from container startup.
- Orphan `.ddev/mcp-servers/.gitkeep` placeholder.
- Orphan `.gitignore` reference to `.ddev/.env.mcp-inspector`.
- The fictional `mcp-connect` web command (it never shipped).

### Migration from `craftpulse/ddev-mcp-inspector` 1.0.0-beta.1
This add-on is now published as `michtio/ddev-mcp-inspector`. To migrate:
```bash
ddev add-on remove mcp-inspector
ddev add-on get michtio/ddev-mcp-inspector
ddev restart
```
