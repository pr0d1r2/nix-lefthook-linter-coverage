#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    TMP="$BATS_TEST_TMPDIR/repo-$$"
    mkdir -p "$TMP"
    git init "$TMP" >/dev/null 2>&1
    cd "$TMP" || return
    git config user.email "test@test.com"
    git config user.name "Test"

    mkdir -p docs
}

@test "missing doc file fails" {
    echo "x" > file.txt
    git add file.txt
    git commit -m "init" >/dev/null 2>&1
    # shellcheck disable=SC2030,SC2031
    export LEFTHOOK_LINTER_COVERAGE_DOC="docs/linter-coverage.md"
    run lefthook-linter-coverage
    assert_failure
    assert_output --partial "missing"
}

@test "all extensions listed passes" {
    cat > docs/linter-coverage.md <<'MD'
| Extension | Linter |
|-----------|--------|
| `.md` | markdownlint |
| `.txt` | none |
| `.sh` | shellcheck |
MD
    echo "hello" > file.txt
    echo "#!/bin/bash" > script.sh
    git add .
    git commit -m "init" >/dev/null 2>&1
    # shellcheck disable=SC2030,SC2031
    export LEFTHOOK_LINTER_COVERAGE_DOC="docs/linter-coverage.md"
    run lefthook-linter-coverage
    assert_success
}

@test "missing extension fails" {
    cat > docs/linter-coverage.md <<'MD'
| Extension | Linter |
|-----------|--------|
| `.txt` | none |
MD
    echo "hello" > file.txt
    echo "data" > file.json
    git add .
    git commit -m "init" >/dev/null 2>&1
    # shellcheck disable=SC2030,SC2031
    export LEFTHOOK_LINTER_COVERAGE_DOC="docs/linter-coverage.md"
    run lefthook-linter-coverage
    assert_failure
    assert_output --partial ".json"
}

@test "bare filename listed passes" {
    cat > docs/linter-coverage.md <<'MD'
| Extension | Linter |
|-----------|--------|
| `.md` | markdownlint |
| `Makefile` | make lint |
MD
    echo "all:" > Makefile
    git add .
    git commit -m "init" >/dev/null 2>&1
    # shellcheck disable=SC2030,SC2031
    export LEFTHOOK_LINTER_COVERAGE_DOC="docs/linter-coverage.md"
    run lefthook-linter-coverage
    assert_success
}

@test "custom doc path via env var" {
    mkdir -p custom
    cat > custom/linters.md <<'MD'
| Extension | Linter |
|-----------|--------|
| `.md` | markdownlint |
| `.txt` | none |
MD
    echo "hello" > file.txt
    git add .
    git commit -m "init" >/dev/null 2>&1
    # shellcheck disable=SC2030,SC2031
    export LEFTHOOK_LINTER_COVERAGE_DOC="custom/linters.md"
    run lefthook-linter-coverage
    assert_success
}
