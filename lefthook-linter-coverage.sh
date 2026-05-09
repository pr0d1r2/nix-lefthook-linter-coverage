# shellcheck shell=bash
# Lefthook-compatible linter coverage checker.
# Verifies every file extension tracked in git is listed in a linter
# coverage markdown doc. The doc must have a markdown table where the
# first column contains backtick-quoted extensions.
# Config: LEFTHOOK_LINTER_COVERAGE_DOC (default: docs/linter-coverage.md)
# Usage: lefthook-linter-coverage [ignored — runs on full repo]
# NOTE: sourced by writeShellApplication — no shebang or set needed.

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

DOC="${LEFTHOOK_LINTER_COVERAGE_DOC:-docs/linter-coverage.md}"
if [ ! -f "$DOC" ]; then
    echo "linter-coverage: $DOC missing -- cannot verify coverage" >&2
    exit 1
fi

AWK_PROGRAM='
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
'

declare -A listed=()
while IFS= read -r tok; do
    [ -z "$tok" ] && continue
    listed["$tok"]=1
done < <(awk "$AWK_PROGRAM" -- "$DOC")

mapfile -t exts < <(
    git ls-files | awk -F/ '{print $NF}' | sed -n 's/.*\.//p' | sort -u
)

mapfile -t bare < <(
    git ls-files | awk -F/ '{print $NF}' | grep -v '\.' | sort -u
)

missing=()
for ext in "${exts[@]}"; do
    [ -z "$ext" ] && continue
    if [ -z "${listed[$ext]:-}" ]; then
        missing+=(".$ext")
    fi
done

for name in "${bare[@]}"; do
    [ -z "$name" ] && continue
    if [ -z "${listed[$name]:-}" ]; then
        missing+=("$name")
    fi
done

if [ "${#missing[@]}" -gt 0 ]; then
    {
        echo "linter-coverage: ${#missing[@]} extension(s) not listed in $DOC:"
        for item in "${missing[@]}"; do
            printf '  %s\n' "$item"
        done
        echo
        echo "Fix: add a row to the extension table in $DOC with an"
        echo "assigned linter or an explicit exempt reason."
    } >&2
    exit 1
fi
exit 0
