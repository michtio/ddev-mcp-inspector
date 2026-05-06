#!/usr/bin/env bats

# DDEV MCP Inspector — Bats test suite
#
# Run locally:
#   bats ./tests/test.bats
#
# CI runs this via ddev/github-action-add-on-test@v2.

setup() {
  set -eu -o pipefail

  export GITHUB_REPO=michtio/ddev-mcp-inspector

  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support

  export DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." && pwd)"
  export PROJNAME="test-$(basename "${GITHUB_REPO}")"
  export TESTDIR="$(mktemp -d "${HOME}/tmp/${PROJNAME}.XXXXXX")"
  export DDEV_NONINTERACTIVE=true

  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true

  cd "${TESTDIR}"
  ddev config --project-name="${PROJNAME}" --project-type=php --docroot=. >/dev/null
  ddev start -y >/dev/null
}

teardown() {
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true
  [ -n "${TESTDIR:-}" ] && rm -rf "${TESTDIR}"
}

# -----------------------------------------------------------------------------
# Install / lifecycle
# -----------------------------------------------------------------------------

@test "install from local directory succeeds" {
  run ddev add-on get "${DIR}"
  assert_success
  assert_output --partial "docker-compose.mcp-inspector.yaml"
  assert_output --partial "mcp-inspector-build/Dockerfile"
  assert_output --partial "commands/host/mcp-inspector"
}

@test "ddev restart brings up the inspector container" {
  ddev add-on get "${DIR}" >/dev/null
  run ddev restart -y
  assert_success
  run docker inspect -f '{{.State.Running}}' "ddev-${PROJNAME}-mcp-inspector"
  assert_output "true"
}

# -----------------------------------------------------------------------------
# Health
# -----------------------------------------------------------------------------

@test "client UI responds 200 on HTTPS:6275" {
  ddev add-on get "${DIR}" >/dev/null
  ddev restart -y >/dev/null

  # Wait up to 60s for the UI to come up (image is pre-built but the inspector
  # process still needs a moment after container start).
  local attempt=0
  while [ "${attempt}" -lt 30 ]; do
    if curl -k -s -o /dev/null -w '%{http_code}' --max-time 3 \
        "https://${PROJNAME}.ddev.site:6275/" | grep -q '^200$'; then
      break
    fi
    sleep 2
    attempt=$((attempt + 1))
  done

  run curl -k -s -o /dev/null -w '%{http_code}' --max-time 5 \
    "https://${PROJNAME}.ddev.site:6275/"
  assert_output "200"
}

@test "proxy /health returns 200 with CORS header on HTTPS:6277" {
  ddev add-on get "${DIR}" >/dev/null
  ddev restart -y >/dev/null

  local attempt=0
  while [ "${attempt}" -lt 30 ]; do
    if curl -k -s -o /dev/null -w '%{http_code}' --max-time 3 \
        "https://${PROJNAME}.ddev.site:6277/health" | grep -q '^200$'; then
      break
    fi
    sleep 2
    attempt=$((attempt + 1))
  done

  # /health must return 200 — the inspector client polls it before connecting.
  run curl -k -s -o /dev/null -w '%{http_code}' --max-time 5 \
    "https://${PROJNAME}.ddev.site:6277/health"
  assert_output "200"

  # CORS header must be present so the browser-side UI on :6275 can fetch it.
  run curl -k -s -i --max-time 5 \
    -H "Origin: https://${PROJNAME}.ddev.site:6275" \
    "https://${PROJNAME}.ddev.site:6277/health"
  assert_output --partial "access-control-allow-origin"
}

# -----------------------------------------------------------------------------
# Host command
# -----------------------------------------------------------------------------

@test "ddev mcp-inspector urls prints both client and proxy URLs" {
  ddev add-on get "${DIR}" >/dev/null
  ddev restart -y >/dev/null
  run ddev mcp-inspector urls
  assert_success
  assert_output --partial "Client UI"
  assert_output --partial ":6275"
  assert_output --partial "Proxy"
  assert_output --partial ":6277"
}

@test "ddev mcp-inspector status reports running once UI is reachable" {
  ddev add-on get "${DIR}" >/dev/null
  ddev restart -y >/dev/null

  local attempt=0
  while [ "${attempt}" -lt 30 ]; do
    if ddev mcp-inspector status 2>/dev/null | grep -q "running"; then
      break
    fi
    sleep 2
    attempt=$((attempt + 1))
  done

  run ddev mcp-inspector status
  assert_success
  assert_output --partial "MCP Inspector is running."
}

# -----------------------------------------------------------------------------
# Removal
# -----------------------------------------------------------------------------

@test "ddev add-on remove cleans up generated files" {
  ddev add-on get "${DIR}" >/dev/null
  ddev restart -y >/dev/null

  run ddev add-on remove mcp-inspector
  assert_success

  assert_not_exists "${TESTDIR}/.ddev/docker-compose.mcp-inspector.yaml"
  assert_not_exists "${TESTDIR}/.ddev/mcp-inspector-build/Dockerfile"
  assert_not_exists "${TESTDIR}/.ddev/commands/host/mcp-inspector"
}
