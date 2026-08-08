#!/usr/bin/env bash
set -u

TEST_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$TEST_DIR/.." && pwd)"
. "$TEST_DIR/testlib.sh"

test_proxy_test_docs_match_code() {
    local docs=""
    docs="$(sed -n '/`proxy.test` 会依次测试/,/每个 URL/p' "$REPO_ROOT/README.md")"
    case "$docs" in
        *z.ai*) fail_test "README must not claim proxy.test checks z.ai" ;;
    esac
    grep -Fq 'https://api.anthropic.com' "$REPO_ROOT/zsh/zshrc" || fail_test "proxy.test URL contract changed"
}

test_windows_proxy_todo_is_explicit() {
    assert_file_contains \
        "$REPO_ROOT/powershell/Microsoft.PowerShell_profile.ps1" \
        'TODO: replace this bootstrap-only global Git mutation with unified proxy.* ownership tracking.'
}

run_test "proxy.test documentation matches implementation" test_proxy_test_docs_match_code
run_test "Windows unified proxy work remains marked TODO" test_windows_proxy_todo_is_explicit
finish_tests
