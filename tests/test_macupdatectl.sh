#!/usr/bin/env bash
set -u

TEST_DIR="$(CDPATH='' cd -- "$(dirname "$0")" && pwd)"
REPO_ROOT="$(CDPATH='' cd -- "$TEST_DIR/.." && pwd)"
CLI_PATH="$REPO_ROOT/bin/macupdatectl"

# shellcheck disable=SC1090,SC1091
. "$TEST_DIR/testlib.sh"

test_script_is_valid_and_executable() {
    [ -x "$CLI_PATH" ] || fail_test "macupdatectl must be executable"
    /bin/bash -n "$CLI_PATH" || fail_test "macupdatectl must pass bash syntax validation"
}

test_non_root_execution_elevates_automatically() {
    assert_file_contains "$CLI_PATH" 'exec /usr/bin/sudo "$0" "$@"' \
        "non-root execution must prompt for administrator privileges automatically"
}

test_graphical_menu_exposes_all_modes() {
    assert_file_contains "$CLI_PATH" '🔒 一键屏蔽所有系统更新' "menu must expose full blocking"
    assert_file_contains "$CLI_PATH" '🔓 一键恢复系统更新' "menu must expose recovery"
    assert_file_contains "$CLI_PATH" '🧹 清除更新小红点' "menu must expose badge cleanup"
    assert_file_contains "$CLI_PATH" '⚙️ 只屏蔽大版本，保留安全更新' \
        "menu must expose major-upgrade blocking"
}

test_full_blocking_uses_service_and_network_layers() {
    assert_file_contains "$CLI_PATH" \
        'launchctl disable system/com.apple.softwareupdated' \
        "full blocking must disable softwareupdated"
    assert_file_contains "$CLI_PATH" '127.0.0.1 swscan.apple.com' \
        "full blocking must block the macOS update catalogue"
    assert_file_contains "$CLI_PATH" '127.0.0.1 swdownload.apple.com' \
        "full blocking must block update downloads"
}

test_recovery_reenables_updates() {
    assert_file_contains "$CLI_PATH" 'softwareupdate --schedule on' \
        "recovery must re-enable scheduled checks"
    assert_file_contains "$CLI_PATH" \
        'launchctl enable system/com.apple.softwareupdated' \
        "recovery must re-enable softwareupdated"
}

test_badge_cleanup_targets_system_settings() {
    assert_file_contains "$CLI_PATH" \
        'defaults write com.apple.systempreferences AttentionPrefBundleIDs 0' \
        "badge cleanup must target System Settings attention state"
}

test_major_only_mode_keeps_security_preferences_enabled() {
    assert_file_contains "$CLI_PATH" 'ConfigDataInstall -bool TRUE' \
        "major-only mode must retain configuration data updates"
    assert_file_contains "$CLI_PATH" 'CriticalUpdateInstall -bool TRUE' \
        "major-only mode must retain critical updates"
}

run_test "script is valid and executable" test_script_is_valid_and_executable
run_test "non-root execution elevates automatically" test_non_root_execution_elevates_automatically
run_test "graphical menu exposes all modes" test_graphical_menu_exposes_all_modes
run_test "full blocking uses service and network layers" test_full_blocking_uses_service_and_network_layers
run_test "recovery re-enables updates" test_recovery_reenables_updates
run_test "badge cleanup targets System Settings" test_badge_cleanup_targets_system_settings
run_test "major-only mode keeps security preferences enabled" test_major_only_mode_keeps_security_preferences_enabled
finish_tests
