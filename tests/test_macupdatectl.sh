#!/usr/bin/env bash
set -u

TEST_DIR="$(CDPATH='' cd -- "$(dirname "$0")" && pwd)"
REPO_ROOT="$(CDPATH='' cd -- "$TEST_DIR/.." && pwd)"
CLI_PATH="$REPO_ROOT/bin/macupdatectl"

# shellcheck disable=SC1090,SC1091
. "$TEST_DIR/testlib.sh"
# shellcheck disable=SC1090
. "$CLI_PATH"

assert_macos_profile() {
    local major="$1"
    local minor="$2"
    local expected_name="$3"
    local expected_profile="$4"

    # shellcheck disable=SC2034
    MACOS_MAJOR="$major"
    # shellcheck disable=SC2034
    MACOS_MINOR="$minor"
    MACOS_NAME=""
    MACOS_PROFILE=""
    select_macos_name_and_profile

    assert_eq "$expected_name" "$MACOS_NAME" "macOS name for $major.$minor"
    assert_eq "$expected_profile" "$MACOS_PROFILE" "compatibility profile for $major.$minor"
}

test_known_macos_versions() {
    assert_macos_profile 10 15 Catalina legacy
    assert_macos_profile 11 0 "Big Sur" legacy
    assert_macos_profile 12 0 Monterey legacy
    assert_macos_profile 13 0 Ventura modern
    assert_macos_profile 14 0 Sonoma modern
    assert_macos_profile 15 0 Sequoia modern
    assert_macos_profile 26 0 Tahoe modern
}

test_future_macos_uses_capability_detection() {
    assert_macos_profile 27 0 "未来或未识别版本" capability
}

test_cli_version() {
    local output
    output="$($CLI_PATH --version)"
    assert_eq "macupdatectl $PROGRAM_VERSION" "$output" "version output"
}

test_chinese_locale_variable_boundaries() {
    local output

    output="$(
        LC_ALL=zh_CN.UTF-8 bash -c '
            . "$1"
            MACOS_VERSION="15.2"
            MACOS_BUILD="24C101"
            MACOS_NAME="Sequoia"
            MACOS_PROFILE="modern"
            MACOS_ARCH="x86_64"
            MACOS_ARCH_NAME="Intel"
            print_platform
        ' _ "$CLI_PATH" 2>&1
    )"

    assert_contains "$output" "系统：macOS 15.2 Sequoia（24C101）" \
        "Chinese locale must not extend shell variable names"
}

test_default_mode_is_off() {
    local selected_mode=""

    # shellcheck disable=SC2329
    disable_updates() {
        selected_mode="off"
    }

    main
    assert_eq "off" "$selected_mode" "default mode must remain off"
}

test_restore_flag_routes_to_restore() {
    local selected_mode=""

    # shellcheck disable=SC2329
    restore_updates() {
        selected_mode="restore"
    }

    main -r
    assert_eq "restore" "$selected_mode" "-r must select restore mode"
}

test_system_daemon_guard_is_symmetric() {
    assert_file_contains "$CLI_PATH" \
        "for_each_system_update_daemon disable_system_update_daemon" \
        "off mode must disable system update daemons"
    assert_file_contains "$CLI_PATH" \
        "for_each_system_update_daemon restore_system_update_daemon" \
        "restore mode must re-enable system update daemons"
}

run_test "known macOS version profiles" test_known_macos_versions
run_test "future macOS capability profile" test_future_macos_uses_capability_detection
run_test "CLI version output" test_cli_version
run_test "Chinese locale variable boundaries" test_chinese_locale_variable_boundaries
run_test "default mode is off" test_default_mode_is_off
run_test "restore flag routing" test_restore_flag_routes_to_restore
run_test "system daemon guard symmetry" test_system_daemon_guard_is_symmetric
finish_tests
