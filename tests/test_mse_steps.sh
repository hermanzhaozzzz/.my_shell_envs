#!/usr/bin/env bash
set -u

TEST_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$TEST_DIR/.." && pwd)"
. "$TEST_DIR/testlib.sh"

load_mse() {
    MSE_TEST_SOURCE_ONLY=1 MSE_SCRIPT_PATH_OVERRIDE="$REPO_ROOT/mse" . "$REPO_ROOT/mse"
    AVAILABLE_STEPS="clashctl"
    platform="Linux"
    platform_family="Linux"
    internal_update_mode=0
    deploy_mode="interactive"
    SELECTED_STEPS=""
}

test_interactive_enter_enables_clashctl() {
    load_mse
    choose_steps <<< "" >/dev/null
    assert_eq "clashctl" "$SELECTED_STEPS" "Enter must enable clashctl on native Linux"
}

test_interactive_n_skips_clashctl() {
    load_mse
    choose_steps <<< "n" >/dev/null
    assert_eq "" "$SELECTED_STEPS" "n must skip clashctl"
}

test_fast_enables_clashctl() {
    load_mse
    deploy_mode="fast"
    choose_steps >/dev/null
    assert_eq "clashctl" "$SELECTED_STEPS" "fast mode must enable clashctl"
}

test_clashctl_not_offered_on_macos() {
    load_mse
    platform="MacOS/arm64"
    platform_family="MacOS"
    choose_steps </dev/null >/dev/null
    assert_eq "" "$SELECTED_STEPS" "macOS must not offer clashctl"
}

test_clashctl_not_offered_on_wsl() {
    load_mse
    grep() { return 0; }
    choose_steps </dev/null >/dev/null
    assert_eq "" "$SELECTED_STEPS" "WSL must not offer clashctl"
}

test_no_only_clashctl_argument() {
    load_mse
    local output=""
    if output="$(parse_deploy_args --only clashctl 2>&1)"; then
        fail_test "--only clashctl must remain unsupported"
        return 1
    fi
    assert_contains "$output" "unknown argument" "unsupported --only should be explicit"
}

test_metadata_records_default_selection() {
    load_mse
    local temp_dir=""
    temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/mse-steps.XXXXXX")" || return 1
    trap "rm -rf '$temp_dir'" EXIT
    METADATA_FILE="$temp_dir/install.env"
    REPO_PATH="$temp_dir"
    choose_steps <<< "" >/dev/null
    persist_deploy_settings >/dev/null
    assert_file_contains "$METADATA_FILE" "MSE_STEP_CLASHCTL='true'"
}

test_metadata_records_explicit_skip() {
    load_mse
    local temp_dir=""
    temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/mse-steps.XXXXXX")" || return 1
    trap "rm -rf '$temp_dir'" EXIT
    METADATA_FILE="$temp_dir/install.env"
    REPO_PATH="$temp_dir"
    choose_steps <<< "n" >/dev/null
    persist_deploy_settings >/dev/null
    assert_file_contains "$METADATA_FILE" "MSE_STEP_CLASHCTL='false'"
}

run_test "interactive Enter defaults clashctl to enabled" test_interactive_enter_enables_clashctl
run_test "interactive n skips clashctl" test_interactive_n_skips_clashctl
run_test "fast deploy enables clashctl" test_fast_enables_clashctl
run_test "macOS does not offer clashctl" test_clashctl_not_offered_on_macos
run_test "WSL does not offer clashctl" test_clashctl_not_offered_on_wsl
run_test "deploy has no --only clashctl mode" test_no_only_clashctl_argument
run_test "metadata persists default clashctl selection" test_metadata_records_default_selection
run_test "metadata persists clashctl skip" test_metadata_records_explicit_skip
finish_tests
