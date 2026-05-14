# shellcheck shell=bash
# Parses a linter coverage markdown doc and prints listed extensions/names.
# Usage: bash parse-coverage-doc.sh <doc-path>
# Prints one extension or bare filename per line (without leading dot).
# NOTE: sourced by writeShellApplication — no shebang or set needed.

doc="$1"

# shellcheck disable=SC2016
awk '
/^\|/ {
    col = $0
    sub(/^\|/, "", col)
    end = index(col, "|")
    if (end == 0) next
    col = substr(col, 1, end - 1)
    while (match(col, /`[^`]+`/)) {
        tok = substr(col, RSTART + 1, RLENGTH - 2)
        sub(/^\./, "", tok)
        print tok
        col = substr(col, RSTART + RLENGTH)
    }
}
' "$doc"
