# nix-lefthook-linter-coverage

[![CI](https://github.com/pr0d1r2/nix-lefthook-linter-coverage/actions/workflows/ci.yml/badge.svg)](https://github.com/pr0d1r2/nix-lefthook-linter-coverage/actions/workflows/ci.yml)

> This code is LLM-generated and validated through an automated integration process using [lefthook](https://github.com/evilmartians/lefthook) git hooks, [bats](https://github.com/bats-core/bats-core) unit tests, and GitHub Actions CI.

Lefthook-compatible linter coverage checker, packaged as a Nix flake.

Verifies that every file extension tracked in a git repository is listed in a linter coverage markdown document. Catches "added a new file type without wiring a linter" regressions.

## Coverage document format

The tool expects a markdown file with a table where the first column contains backtick-quoted extensions:

```markdown
| Extension | Linter | Notes |
|-----------|--------|-------|
| `.rb` | RuboCop | Ruby source |
| `.js` | ESLint | JavaScript |
| `Gemfile` | bundler-audit | Bare filename |
```

## Usage

### Option A: Lefthook remote (recommended)

Add to your `lefthook.yml` - no flake input needed, just the wrapper binary in your devShell:

```yaml
remotes:
  - git_url: https://github.com/pr0d1r2/nix-lefthook-linter-coverage
    ref: main
    configs:
      - lefthook-remote.yml
```

### Option B: Flake input

Add as a flake input:

```nix
inputs.nix-lefthook-linter-coverage = {
  url = "github:pr0d1r2/nix-lefthook-linter-coverage";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Add to your devShell:

```nix
nix-lefthook-linter-coverage.packages.${pkgs.stdenv.hostPlatform.system}.default
```

Add to `lefthook.yml`:

```yaml
pre-push:
  commands:
    linter-coverage:
      run: timeout ${LEFTHOOK_LINTER_COVERAGE_TIMEOUT:-30} lefthook-linter-coverage
```

### Configuring doc path

Override the coverage document path via environment variable:

```bash
export LEFTHOOK_LINTER_COVERAGE_DOC=docs/linters.md
```

### Configuring timeout

The default timeout is 30 seconds. Override per-repo via environment variable:

```bash
export LEFTHOOK_LINTER_COVERAGE_TIMEOUT=60
```

## Development

The repo includes an `.envrc` for [direnv](https://direnv.net/) - entering the directory automatically loads the devShell with all dependencies:

```bash
cd nix-lefthook-linter-coverage  # direnv loads the flake
bats tests/unit/
```

If not using direnv, enter the shell manually:

```bash
nix develop
bats tests/unit/
```

## License

MIT
