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

test_deploy_orders_bootstrap_and_cleanup_safely() {
    local clash_line core_line cleanup_line persist_line
    clash_line="$(grep -n 'run_step "clashctl" step_clashctl' "$REPO_ROOT/mse" | tail -1 | cut -d: -f1)"
    core_line="$(grep -n '^[[:space:]]*ensure_non_windows_zsh_core ||' "$REPO_ROOT/mse" | tail -1 | cut -d: -f1)"
    cleanup_line="$(grep -n '^[[:space:]]*sync_optional_bin_entries$' "$REPO_ROOT/mse" | tail -1 | cut -d: -f1)"
    persist_line="$(grep -n '^[[:space:]]*persist_deploy_settings$' "$REPO_ROOT/mse" | tail -1 | cut -d: -f1)"
    [ "$clash_line" -lt "$core_line" ] || fail_test "clashctl must deploy before network-dependent shell setup"
    [ "$cleanup_line" -lt "$persist_line" ] || fail_test "managed bin cleanup must finish before metadata is committed"
    [ "$cleanup_line" -gt "$core_line" ] || fail_test "managed bin cleanup must wait until deploy work succeeds"
}

test_clashctl_has_a_cron_safe_repo_wrapper() {
    [ -x "$REPO_ROOT/tools/clashctl/clashctl" ] || fail_test "repo clashctl wrapper must be executable"
    assert_file_contains "$REPO_ROOT/tools/clashctl/mse-deploy.sh" 'ln -s "${CLASHCTL_SRC}/clashctl" "${CLASHCTL_BIN_DIR}/clashctl"'
    assert_file_contains "$REPO_ROOT/tools/clashctl/scripts/cmd/sub.sh" '"${BIN_BASE_DIR}/clashctl" "$CLASHCTL_CRON_TAG"'
}

test_clashctl_canonicalizes_repo_identity() {
    local fixture=""
    local expected_home=""
    fixture="$(mktemp -d "${TMPDIR:-/tmp}/mse-clash-home.XXXXXX")" || return 1
    export CLASH_HOME_FIXTURE="$fixture"
    trap 'rm -rf "$CLASH_HOME_FIXTURE"' EXIT
    ln -s "$REPO_ROOT/tools/clashctl" "$fixture/clashctl-link"
    CLASHCTL_HOME="$fixture/clashctl-link"
    # shellcheck disable=SC1090
    . "$CLASHCTL_HOME/scripts/cmd/clashctl.sh"
    expected_home="$(CDPATH= cd -- "$REPO_ROOT/tools/clashctl" && pwd -P)"
    assert_eq "$expected_home" "$CLASHCTL_HOME" \
        "clashctl must canonicalize a symlinked repository path before deriving pid identity"
}

run_test "proxy.test documentation matches implementation" test_proxy_test_docs_match_code
run_test "Windows unified proxy work remains marked TODO" test_windows_proxy_todo_is_explicit
run_test "deploy bootstrap and cleanup ordering is safe" test_deploy_orders_bootstrap_and_cleanup_safely
run_test "clashctl has a cron-safe repo wrapper" test_clashctl_has_a_cron_safe_repo_wrapper
run_test "clashctl canonicalizes repository identity" test_clashctl_canonicalizes_repo_identity
finish_tests
