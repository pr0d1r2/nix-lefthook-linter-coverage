#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    TMP="$BATS_TEST_TMPDIR"
    SCRIPT="$BATS_TEST_DIRNAME/../../parse-coverage-doc.sh"
}

@test "script file exists" {
    [ -f "$SCRIPT" ]
}

@test "extracts dotted extensions from table" {
    cat > "$TMP/doc.md" <<'MD'
| Extension | Linter |
|-----------|--------|
| `.md` | markdownlint |
| `.sh` | shellcheck |
MD
    run bash "$SCRIPT" "$TMP/doc.md"
    assert_success
    assert_line "md"
    assert_line "sh"
}

@test "extracts bare filenames from table" {
    cat > "$TMP/doc.md" <<'MD'
| Extension | Linter |
|-----------|--------|
| `Makefile` | make lint |
| `Dockerfile` | hadolint |
MD
    run bash "$SCRIPT" "$TMP/doc.md"
    assert_success
    assert_line "Makefile"
    assert_line "Dockerfile"
}

@test "handles multiple extensions in one cell" {
    cat > "$TMP/doc.md" <<'MD'
| Extension | Linter |
|-----------|--------|
| `.ts`, `.tsx` | eslint |
MD
    run bash "$SCRIPT" "$TMP/doc.md"
    assert_success
    assert_line "ts"
    assert_line "tsx"
}

@test "ignores non-table lines" {
    cat > "$TMP/doc.md" <<'MD'
# Linter Coverage

Some text about `.json` files.

| Extension | Linter |
|-----------|--------|
| `.md` | markdownlint |
MD
    run bash "$SCRIPT" "$TMP/doc.md"
    assert_success
    assert_output "md"
}

@test "empty doc produces no output" {
    printf '' > "$TMP/empty.md"
    run bash "$SCRIPT" "$TMP/empty.md"
    assert_success
    assert_output ""
}
