#!/usr/bin/env bash
set -u

TEST_DIR="$(CDPATH='' cd -- "$(dirname "$0")" && pwd)"
REPO_ROOT="$(CDPATH='' cd -- "$TEST_DIR/.." && pwd)"
CLI_PATH="$REPO_ROOT/bin/macupdatectl"

# shellcheck disable=SC1090,SC1091
. "$TEST_DIR/testlib.sh"
# shellcheck disable=SC1090
. "$CLI_PATH"

make_temp_file() {
    /usr/bin/mktemp /private/tmp/macupdatectl.test.XXXXXX
}

remove_temp_files() {
    local path

    for path in "$@"; do
        case "$path" in
            /private/tmp/macupdatectl.test.*)
                [ ! -L "$path" ] && /bin/rm -f -- "$path"
                ;;
        esac
    done
}

test_script_is_valid_and_executable() {
    [ -x "$CLI_PATH" ] || fail_test "macupdatectl must be executable"
    /bin/bash -n "$CLI_PATH" || fail_test "macupdatectl must pass bash syntax validation"
}

test_graphical_menu_is_the_default_interface() {
    assert_file_contains "$CLI_PATH" 'choose from list options with title "macOS 更新控制器"' \
        "default invocation must show a native choice dialog"
    assert_file_contains "$CLI_PATH" 'display dialog (item 1 of argv)' \
        "graphical operations must show a completion dialog"
    assert_file_contains "$CLI_PATH" 'if (( $# == 0 )); then' \
        "no-argument invocation must enter the graphical path"
}

test_graphical_menu_exposes_all_supported_modes() {
    assert_file_contains "$CLI_PATH" '🔒 屏蔽所有系统更新' "menu must expose full blocking"
    assert_file_contains "$CLI_PATH" '🔓 恢复检查与手动更新（黑苹果推荐）' \
        "menu must expose the safe recovery mode"
    assert_file_contains "$CLI_PATH" '🧹 清除更新小红点' "menu must expose badge cleanup"
    assert_file_contains "$CLI_PATH" '🔎 查看当前状态' "menu must expose status"
    if /usr/bin/grep -Fq '⚙️ 保留检查和安全更新，关闭自动安装 macOS' "$CLI_PATH"; then
        fail_test "the graphical menu must not expose a duplicate recovery mode"
    fi
}

test_cli_version() {
    local output

    output="$($CLI_PATH --version)"
    assert_eq "macupdatectl $PROGRAM_VERSION" "$output" "version output"
}

test_legacy_hosts_are_migrated_and_blocking_is_idempotent() {
    local input_path
    local first_path
    local second_path
    local host
    local count

    input_path="$(make_temp_file)"
    first_path="$(make_temp_file)"
    second_path="$(make_temp_file)"
    trap 'remove_temp_files "$input_path" "$first_path" "$second_path"' EXIT

    {
        printf '127.0.0.1 localhost\n'
        printf '10.0.0.1 internal.example\n'
        printf '%s\n' "$LEGACY_HOSTS_MARKER"
        printf '127.0.0.1 swscan.apple.com\n'
        printf '127.0.0.1 swscan.apple.com\n'
        printf '127.0.0.1 updates.cdn-apple.com\n'
    } > "$input_path"

    render_hosts_with_block "$input_path" "$first_path"
    validate_rendered_hosts "$first_path" block
    render_hosts_with_block "$first_path" "$second_path"
    validate_rendered_hosts "$second_path" block

    /usr/bin/cmp -s "$first_path" "$second_path" \
        || fail_test "repeated blocking must produce identical hosts content"
    /usr/bin/grep -Fq '10.0.0.1 internal.example' "$second_path" \
        || fail_test "unrelated hosts entries must be preserved"
    for host in "${UPDATE_HOSTS[@]}"; do
        count="$(/usr/bin/awk -v host="$host" \
            'NF == 2 && $1 == "127.0.0.1" && $2 == host { count++ } END { print count + 0 }' \
            "$second_path")"
        assert_eq "1" "$count" "managed host must appear exactly once: $host"
    done

    remove_temp_files "$input_path" "$first_path" "$second_path"
    trap - EXIT
}

test_restore_removes_new_and_legacy_entries_only() {
    local input_path
    local output_path

    input_path="$(make_temp_file)"
    output_path="$(make_temp_file)"
    trap 'remove_temp_files "$input_path" "$output_path"' EXIT

    {
        printf '127.0.0.1 localhost\n'
        printf '10.0.0.1 internal.example\n'
        printf '%s\n' "$LEGACY_HOSTS_MARKER"
        printf '127.0.0.1 swscan.apple.com\n'
        printf '%s\n' "$HOSTS_BLOCK_BEGIN"
        printf '127.0.0.1 swdist.apple.com\n'
        printf '127.0.0.1 swcdn.apple.com\n'
        printf '%s\n' "$HOSTS_BLOCK_END"
        printf '127.0.0.1 unrelated.example\n'
    } > "$input_path"

    render_hosts_without_managed_entries "$input_path" "$output_path"
    validate_rendered_hosts "$output_path" restore
    /usr/bin/grep -Fq '10.0.0.1 internal.example' "$output_path" \
        || fail_test "restore must preserve unrelated custom entries"
    /usr/bin/grep -Fq '127.0.0.1 unrelated.example' "$output_path" \
        || fail_test "restore must preserve unrelated loopback entries"

    remove_temp_files "$input_path" "$output_path"
    trap - EXIT
}

test_unmatched_hosts_markers_are_rejected() {
    local input_path
    local output_path

    input_path="$(make_temp_file)"
    output_path="$(make_temp_file)"
    trap 'remove_temp_files "$input_path" "$output_path"' EXIT
    {
        printf '127.0.0.1 localhost\n'
        printf '%s\n' "$HOSTS_BLOCK_BEGIN"
        printf '127.0.0.1 swscan.apple.com\n'
    } > "$input_path"

    if render_hosts_without_managed_entries "$input_path" "$output_path"; then
        fail_test "an unmatched managed block must abort instead of truncating hosts"
    fi

    remove_temp_files "$input_path" "$output_path"
    trap - EXIT
}

test_recovery_is_safe_for_manual_hackintosh_updates() {
    assert_file_contains "$CLI_PATH" 'update_hosts restore' \
        "restore must remove hosts blocking"
    assert_file_contains "$CLI_PATH" 'restore_system_update_daemon' \
        "restore must re-enable the system update daemon"
    assert_file_contains "$CLI_PATH" 'AutomaticallyInstallMacOSUpdates -bool false' \
        "restore must not enable unattended macOS installation"
    assert_file_contains "$CLI_PATH" 'ConfigDataInstall -bool true' \
        "restore must enable configuration data updates"
    assert_file_contains "$CLI_PATH" 'CriticalUpdateInstall -bool true' \
        "restore must enable critical security updates"
}

test_dangerous_upstream_behaviour_is_removed() {
    if /usr/bin/grep -Fq 'exec /usr/bin/sudo "$0" "$@"' "$CLI_PATH"; then
        fail_test "the entire graphical script must not run as root"
    fi
    if /usr/bin/grep -Fq 'rm -rf /Library/Updates' "$CLI_PATH"; then
        fail_test "blocking must not delete downloaded updates"
    fi
    if /usr/bin/grep -Fq '/private/var/db/com.apple.softwareupdate' "$CLI_PATH"; then
        fail_test "badge cleanup must not delete the system update database"
    fi
    assert_file_contains "$CLI_PATH" 'HOSTS_BACKUP_DIR="/var/backups/macupdatectl"' \
        "hosts changes must have a recovery backup"
}

run_test "script is valid and executable" test_script_is_valid_and_executable
run_test "graphical menu is default" test_graphical_menu_is_the_default_interface
run_test "graphical menu exposes all modes" test_graphical_menu_exposes_all_supported_modes
run_test "CLI version output" test_cli_version
run_test "legacy hosts migration and idempotency" test_legacy_hosts_are_migrated_and_blocking_is_idempotent
run_test "restore removes only managed hosts" test_restore_removes_new_and_legacy_entries_only
run_test "unmatched hosts markers are rejected" test_unmatched_hosts_markers_are_rejected
run_test "safe recovery for Hackintosh updates" test_recovery_is_safe_for_manual_hackintosh_updates
run_test "dangerous upstream behaviour removed" test_dangerous_upstream_behaviour_is_removed
finish_tests
