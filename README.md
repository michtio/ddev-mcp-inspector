# DDEV MCP Inspector

[![tests](https://github.com/michtio/ddev-mcp-inspector/actions/workflows/tests.yml/badge.svg)](https://github.com/michtio/ddev-mcp-inspector/actions/workflows/tests.yml)
[![Latest release](https://img.shields.io/github/v/release/michtio/ddev-mcp-inspector)](https://github.com/michtio/ddev-mcp-inspector/releases/latest)
[![License](https://img.shields.io/github/license/michtio/ddev-mcp-inspector)](LICENSE)
[![Sponsor](https://img.shields.io/github/sponsors/michtio?label=sponsor)](https://github.com/sponsors/michtio)

The [Model Context Protocol Inspector](https://github.com/modelcontextprotocol/inspector) running as a service inside your DDEV project. Test stdio, SSE, and Streamable HTTP MCP servers from any framework — Craft CMS, Laravel, Drupal, Node, Python, anything you build inside DDEV — without installing Node on the host.

> **Why this exists.** When you're building or debugging an MCP server, you need a client that speaks every transport, lets you inspect tool/resource/prompt registries, and runs requests against your server. The official Inspector does exactly that. This add-on packages it as a turnkey DDEV service so it shares your project's network, hostnames, and TLS — no port juggling, no host Node, no `npx` race conditions.

## Install

```bash
ddev add-on get michtio/ddev-mcp-inspector
ddev restart
```

The first `ddev restart` builds the image and pre-installs the Inspector — about 30 seconds. Every subsequent `ddev start` brings it up in roughly five.

## Open the UI

```bash
ddev mcp-inspector
```

Opens the client UI at `https://<project>.ddev.site:6275`.

## Connect to an MCP server

Open the client UI, pick a transport, and connect. Below are working snippets for the common cases.

### Craft CMS plugin (e.g. cortex)

In the Inspector UI: **Transport: STDIO** → **Command:**
```
docker exec -i ddev-<project>-web craft cortex/serve
```

If the Inspector is in the same DDEV project as your Craft install, this also works:
```
craft cortex/serve
```

### Laravel (Boost or any Artisan-driven MCP)

```
docker exec -i ddev-<project>-web php artisan boost:mcp
```

### Drupal (drush-mcp or a custom Drush command)

```
docker exec -i ddev-<project>-web drush mcp:serve
```

### Node MCP server in your project

```
docker exec -i ddev-<project>-web node /var/www/html/path/to/server.mjs
```

### Python MCP server in your project

```
docker exec -i ddev-<project>-web python /var/www/html/path/to/server.py
```

### Streamable HTTP / SSE servers

In the Inspector UI: **Transport: Streamable HTTP** (or **SSE**) and enter the URL — typically your project's HTTPS endpoint plus the route the server listens on. From inside DDEV containers, the Inspector reaches services on the project's internal Docker network.

## Commands

```bash
ddev mcp-inspector              # open the client UI in your browser (default)
ddev mcp-inspector status       # is the inspector running and reachable?
ddev mcp-inspector logs         # tail the inspector container logs
ddev mcp-inspector urls         # print all client/proxy URLs
ddev mcp-inspector version      # show the pinned MCP Inspector version
```

## Endpoints

| What | URL |
|---|---|
| Client UI (browser) | `https://<project>.ddev.site:6275` (HTTP fallback `:6274`) |
| Proxy server | `https://<project>.ddev.site:6277` |
| From other DDEV containers | `http://mcp-inspector:6274` (UI), `http://mcp-inspector:6277` (proxy) |

The proxy is HTTPS-only externally — modern browsers refuse mixed-content fetches from an HTTPS UI to an HTTP proxy.

## Configuration

Environment variables on the `mcp-inspector` service in `.ddev/docker-compose.mcp-inspector.yaml`:

| Variable | Default | Purpose |
|---|---|---|
| `MCP_SERVER_REQUEST_TIMEOUT` | `10000` | Per-request timeout (ms) |
| `MCP_REQUEST_TIMEOUT_RESET_ON_PROGRESS` | `true` | Reset timeout when the server reports progress |
| `MCP_REQUEST_MAX_TOTAL_TIMEOUT` | `60000` | Hard ceiling per request (ms) |
| `DANGEROUSLY_OMIT_AUTH` | `true` | Skips Inspector auth — fine for DDEV-local, do not expose publicly |

To pin a different Inspector version, edit `.ddev/mcp-inspector-build/Dockerfile` and change `MCP_INSPECTOR_VERSION`, then `ddev restart`.

## Removing

```bash
ddev add-on remove mcp-inspector
ddev restart
```

This removes the docker-compose service, the build context, and the host command. The DDEV-built image will be cleaned up by `ddev delete -O` or `docker image prune`.

## Requirements

- DDEV `>= v1.24.10`
- Docker

## Migrating from `craftpulse/ddev-mcp-inspector`

This add-on used to live under `craftpulse/`. It moved to `michtio/` for a clean rebuild. To migrate an existing project:

```bash
ddev add-on remove mcp-inspector
ddev add-on get michtio/ddev-mcp-inspector
ddev restart
```

## Sponsoring

If this add-on saves you time on MCP development, consider [sponsoring on GitHub](https://github.com/sponsors/michtio) or [Buy Me a Coffee](https://www.buymeacoffee.com/michtio). Sponsors keep this maintained and the daily upstream-regression CI running.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup, test instructions, and PR guidelines.

## License

MIT — see [LICENSE](LICENSE).

## Credits

- [Model Context Protocol](https://modelcontextprotocol.io/) — Anthropic et al.
- [MCP Inspector](https://github.com/modelcontextprotocol/inspector) — upstream tool this add-on packages.
- [DDEV](https://ddev.com/) — local-development platform this add-on extends.
