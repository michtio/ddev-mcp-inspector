# #ddev-generated
# DDEV MCP Inspector — pre-installed image.
#
# Pinning the inspector version here means restarts are instant: DDEV builds
# the image once on first start, then reuses it. No npm install on every
# `ddev start` (the legacy approach added 60–90s to every restart).
#
# To bump: change MCP_INSPECTOR_VERSION below, run `ddev restart` to rebuild.

FROM node:24-alpine

ARG MCP_INSPECTOR_VERSION=0.21.2

LABEL org.opencontainers.image.source="https://github.com/michtio/ddev-mcp-inspector"
LABEL org.opencontainers.image.description="MCP Inspector pre-installed for DDEV"
LABEL org.opencontainers.image.licenses="MIT"

RUN npm install -g "@modelcontextprotocol/inspector@${MCP_INSPECTOR_VERSION}" \
    && npm cache clean --force

WORKDIR /app

EXPOSE 6274 6277

CMD ["mcp-inspector"]
