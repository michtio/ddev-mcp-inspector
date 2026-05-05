# Contributing

Thanks for your interest. Issues and PRs are welcome.

## Development setup

Clone the repo, then install the add-on into a disposable DDEV project from your local checkout:

```bash
mkdir -p ~/tmp/mcp-inspector-dev
cd ~/tmp/mcp-inspector-dev
ddev config --project-name=mcp-inspector-dev --project-type=php --docroot=.
ddev start

# Install from your local clone
ddev add-on get /path/to/your/clone/of/ddev-mcp-inspector
ddev restart
```

Iterate, then re-install with the same command — `ddev add-on get` overwrites the project's copy of the add-on files.

## Tests

Tests use [Bats](https://bats-core.readthedocs.io/) with `bats-assert`, `bats-file`, and `bats-support`. Install via your package manager (e.g. `brew install bats-core` then install the libraries per Bats docs).

Run locally:

```bash
bats ./tests/test.bats
```

Each test boots a fresh DDEV project, installs the add-on from your working copy, asserts behaviour, then tears the project down. Plan for ~3 minutes wall time on the first run (image build) and ~1 minute on subsequent runs.

CI runs the same suite via `ddev/github-action-add-on-test@v2` against both the `stable` and `HEAD` channels of DDEV, plus a daily cron to catch upstream MCP Inspector regressions.

## Conventions

- Every generated file gets a `#ddev-generated` marker on its first line. Without it, DDEV treats the file as user-customised and won't update or remove it on add-on upgrades.
- Bash scripts: `set -eu -o pipefail`, `#!/usr/bin/env bash`.
- YAML: 2-space indentation.
- Conventional commits: `feat:`, `fix:`, `docs:`, `chore:`, `test:`, `ci:`.

## Releasing

Maintainer notes:

1. Bump the version in `CHANGELOG.md`. Add a section describing user-visible changes.
2. Tag the release: `git tag -a v1.x.y -m 'v1.x.y' && git push origin v1.x.y`.
3. The `tests.yml` workflow's `release` job creates the GitHub release on tag push (after CI passes).
4. Verify the release shows up in DDEV's add-on registry within a few minutes (the `ddev-get` topic on this repo plus a public release is what the registry indexes).

## Code of Conduct

Be civil. Critique work, not people.
