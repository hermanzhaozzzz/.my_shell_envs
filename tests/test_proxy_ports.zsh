#!/usr/bin/env zsh

TEST_DIR="${0:A:h}"
source "${TEST_DIR}/testlib.sh"
source "${TEST_DIR}/proxy_fixture.zsh"

test_distinct_ports_are_loaded() {
    make_proxy_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    write_runtime $'port: 7890\nsocks-port: 7891'
    load_proxy_helpers
    assert_eq "7890" "${MSE_PROXY_PORT}" "HTTP port should come from runtime"
    assert_eq "7891" "${MSE_PROXY_SOCKS_PORT}" "SOCKS port should come from runtime"
}

test_preconfigured_ports_are_overwritten() {
    make_proxy_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    export MSE_PROXY_PORT=7777
    export MSE_PROXY_SOCKS_PORT=7778
    write_runtime $'port: 7890\nsocks-port: 7891'
    load_proxy_helpers
    assert_eq "7890" "${MSE_PROXY_PORT}" "runtime must overwrite a preconfigured HTTP port"
    assert_eq "7891" "${MSE_PROXY_SOCKS_PORT}" "runtime must overwrite a preconfigured SOCKS port"
}

test_ports_refresh_after_runtime_change() {
    make_proxy_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    write_runtime $'port: 7890\nsocks-port: 7891'
    load_proxy_helpers
    write_runtime $'port: 8890\nsocks-port: 8891'
    _mse_proxy_sync_clashctl_ports
    assert_eq "8890" "${MSE_PROXY_PORT}" "HTTP port should refresh"
    assert_eq "8891" "${MSE_PROXY_SOCKS_PORT}" "SOCKS port should refresh"
}

test_post_load_override_is_overwritten() {
    make_proxy_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    write_runtime $'port: 7890\nsocks-port: 7891'
    load_proxy_helpers
    export MSE_PROXY_PORT=7777
    export MSE_PROXY_SOCKS_PORT=7778
    _mse_proxy_sync_clashctl_ports
    assert_eq "7890" "${MSE_PROXY_PORT}" "runtime must overwrite a current-shell HTTP override"
    assert_eq "7891" "${MSE_PROXY_SOCKS_PORT}" "runtime must overwrite a current-shell SOCKS override"
}

test_invalid_runtime_clears_stale_ports() {
    make_proxy_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    write_runtime $'port: 7890\nsocks-port: 7891'
    load_proxy_helpers
    write_runtime 'port: 8890'
    if _mse_proxy_sync_clashctl_ports; then
        fail_test "an incomplete runtime must fail synchronization"
        return 1
    fi
    assert_eq "" "${MSE_PROXY_PORT:-}" "failed synchronization must clear the stale HTTP port"
    assert_eq "" "${MSE_PROXY_SOCKS_PORT:-}" "failed synchronization must clear the stale SOCKS port"
}

test_mixed_port_drives_both_protocols() {
    make_proxy_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    write_runtime 'mixed-port: 7893'
    load_proxy_helpers
    assert_eq "7893" "${MSE_PROXY_PORT}" "mixed port should provide HTTP"
    assert_eq "7893" "${MSE_PROXY_SOCKS_PORT}" "mixed port should provide SOCKS"
}

test_http_only_runtime_is_not_ready() {
    make_proxy_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    write_runtime 'port: 7890'
    load_proxy_helpers
    if _mse_clashctl_runtime_ready; then
        fail_test "a plain HTTP port must not be reused as a SOCKS port"
        return 1
    fi
}

test_invalid_mode_does_not_fall_back_to_clash() {
    make_proxy_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    export MSE_PROXY_MODE=unknown
    export MSE_PROXY_PORT=7777
    load_proxy_helpers
    local output=""
    if output="$(_func_proxy_on 2>&1)"; then
        fail_test "an invalid proxy mode must fail"
        return 1
    fi
    assert_contains "${output}" "unsupported MSE_PROXY_MODE=unknown" "invalid mode should be diagnosed"
}

run_test "runtime loads distinct HTTP and SOCKS ports" test_distinct_ports_are_loaded
run_test "runtime overwrites preconfigured ports" test_preconfigured_ports_are_overwritten
run_test "ports refresh with runtime" test_ports_refresh_after_runtime_change
run_test "runtime overwrites post-load port changes" test_post_load_override_is_overwritten
run_test "invalid runtime clears stale ports" test_invalid_runtime_clears_stale_ports
run_test "mixed-port supplies both protocols" test_mixed_port_drives_both_protocols
run_test "HTTP-only runtime is rejected" test_http_only_runtime_is_not_ready
run_test "invalid mode has no clash fallback" test_invalid_mode_does_not_fall_back_to_clash
finish_tests
