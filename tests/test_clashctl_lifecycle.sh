#!/usr/bin/env bash
set -u

TEST_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$TEST_DIR/.." && pwd)"
. "$TEST_DIR/testlib.sh"

setup_service_fixture() {
    SERVICE_TMP="$(mktemp -d "${TMPDIR:-/tmp}/mse-service.XXXXXX")" || return 1
    export SERVICE_TMP
    CLASHCTL_KERNEL="mihomo"
    CLASH_RESOURCES_DIR="$SERVICE_TMP/state"
    CLASH_CONFIG_RUNTIME="$CLASH_RESOURCES_DIR/runtime.yaml"
    BIN_KERNEL="$SERVICE_TMP/bin/mihomo"
    INIT_TYPE="nohup"
    mkdir -p "$CLASH_RESOURCES_DIR" "$(dirname "$BIN_KERNEL")"
    printf 'mixed-port: 7890\n' > "$CLASH_CONFIG_RUNTIME"
    _is_root() { return 1; }
    . "$REPO_ROOT/tools/clashctl/scripts/lib/service.sh"
}

write_long_running_kernel() {
    cp "$REPO_ROOT/tests/fixtures/fake-kernel.sh" "$BIN_KERNEL"
    chmod +x "$BIN_KERNEL"
}

test_start_active_stop_pidfile_lifecycle() {
    setup_service_fixture
    trap 'service_stop >/dev/null 2>&1 || true; rm -rf "$SERVICE_TMP"' EXIT
    write_long_running_kernel
    service_start
    local pid=""
    pid="$(service_pid_read)" || return 1
    service_is_active || fail_test "pidfile process should be active"
    service_stop >/dev/null 2>&1
    wait "$pid" 2>/dev/null || true
    service_is_active && fail_test "service should be inactive after stop"
    [ ! -e "$service_pid_path" ] || fail_test "pidfile should be removed after stop"
    ! kill -0 "$pid" >/dev/null 2>&1 || fail_test "kernel process should be stopped"
}

test_stale_pidfile_is_cleaned() {
    setup_service_fixture
    trap 'rm -rf "$SERVICE_TMP"' EXIT
    write_long_running_kernel
    detect_service_manager
    printf '99999999\n' > "$service_pid_path"
    service_is_active && fail_test "stale pidfile must not report active"
    service_stop
    [ ! -e "$service_pid_path" ] || fail_test "stale pidfile should be removed"
}

test_unrelated_process_is_not_killed() {
    setup_service_fixture
    trap 'kill "${unrelated_pid:-0}" >/dev/null 2>&1 || true; wait "${unrelated_pid:-0}" 2>/dev/null || true; rm -rf "$SERVICE_TMP"' EXIT
    local unrelated_kernel="$SERVICE_TMP/other/mihomo"
    mkdir -p "$(dirname "$unrelated_kernel")"
    cp "$REPO_ROOT/tests/fixtures/fake-kernel.sh" "$unrelated_kernel"
    chmod +x "$unrelated_kernel"
    "$unrelated_kernel" &
    unrelated_pid=$!
    detect_service_manager
    printf '%s\n' "$unrelated_pid" > "$service_pid_path"
    service_stop
    kill -0 "$unrelated_pid" >/dev/null 2>&1 || fail_test "unrelated same-name process must survive"
    [ ! -e "$service_pid_path" ] || fail_test "mismatched pidfile should be removed"
}

test_active_check_does_not_require_signal_permission() {
    setup_service_fixture
    trap 'command kill "${kernel_pid:-0}" >/dev/null 2>&1 || true; wait "${kernel_pid:-0}" 2>/dev/null || true; rm -rf "$SERVICE_TMP"' EXIT
    write_long_running_kernel
    "$BIN_KERNEL" -d "$CLASH_RESOURCES_DIR" -f "$CLASH_CONFIG_RUNTIME" &
    kernel_pid=$!
    detect_service_manager
    printf '%s\n' "$kernel_pid" > "$service_pid_path"
    kill() { return 1; }
    service_pid_matches "$kernel_pid" || fail_test "process identity should not depend on kill -0 permission"
}

test_running_process_without_ports_is_not_ready() {
    service_is_active() { return 0; }
    clashctl_require_runtime_ready() { return 0; }
    clashctl_wait_proxy_ports() { return 1; }
    _valid_config() { return 0; }
    _failcat() { printf '%s\n' "$*"; }
    _okcat() { printf '%s\n' "$*"; }
    CLASHCTL_KERNEL="mihomo"
    CLASH_CONFIG_RUNTIME="runtime.yaml"
    . "$REPO_ROOT/tools/clashctl/scripts/cmd/on.sh"
    local output=""
    if output="$(on_service_only 2>&1)"; then
        fail_test "a live process with closed proxy ports must not be ready"
        return 1
    fi
    assert_contains "$output" "代理端口未就绪" "fake readiness should explain the port failure"
}

run_test "nohup service uses a precise pidfile lifecycle" test_start_active_stop_pidfile_lifecycle
run_test "stale pidfile is rejected and cleaned" test_stale_pidfile_is_cleaned
run_test "unrelated same-name process is not killed" test_unrelated_process_is_not_killed
run_test "active check works without signal permission" test_active_check_does_not_require_signal_permission
run_test "running process without ports is rejected" test_running_process_without_ports_is_not_ready
finish_tests
