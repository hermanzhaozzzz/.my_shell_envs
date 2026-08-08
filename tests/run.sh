#!/usr/bin/env bash
set -u

TEST_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
failed=0
test_file=""

for test_file in "$TEST_DIR"/test_*.sh "$TEST_DIR"/test_*.zsh; do
    [ -f "$test_file" ] || continue
    printf '\n==> %s\n' "$(basename "$test_file")"
    case "$test_file" in
        *.zsh) zsh "$test_file" || failed=$((failed + 1)) ;;
        *) bash "$test_file" || failed=$((failed + 1)) ;;
    esac
done

if [ "$failed" -gt 0 ]; then
    printf '\n%s test files failed\n' "$failed" >&2
    exit 1
fi

printf '\nall test files passed\n'
