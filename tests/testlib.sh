#!/usr/bin/env bash

TESTS_RUN=0
TESTS_FAILED=0

fail_test() {
    printf '    %s\n' "$*" >&2
    exit 1
}

assert_eq() {
    local expected="$1"
    local actual="$2"
    local message="${3:-values differ}"

    [ "$expected" = "$actual" ] || fail_test "$message: expected '$expected', got '$actual'"
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-text does not contain expected value}"

    case "$haystack" in
        *"$needle"*) return 0 ;;
        *) fail_test "$message: missing '$needle'" ;;
    esac
}

assert_file_contains() {
    local path="$1"
    local needle="$2"
    local message="${3:-file does not contain expected value}"

    /usr/bin/grep -Fq -- "$needle" "$path" || fail_test "$message: $path is missing '$needle'"
}

run_test() {
    local name="$1"
    shift

    TESTS_RUN=$((TESTS_RUN + 1))
    if ("$@"); then
        printf '  ok %s\n' "$name"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        printf '  not ok %s\n' "$name" >&2
    fi
}

finish_tests() {
    if [ "$TESTS_FAILED" -gt 0 ]; then
        printf '%s: %s/%s failed\n' "$(basename "$0")" "$TESTS_FAILED" "$TESTS_RUN" >&2
        return 1
    fi
    printf '%s: %s passed\n' "$(basename "$0")" "$TESTS_RUN"
}
