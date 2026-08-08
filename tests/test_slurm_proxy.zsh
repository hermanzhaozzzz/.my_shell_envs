#!/usr/bin/env zsh

TEST_DIR="${0:A:h}"
source "${TEST_DIR}/testlib.sh"
source "${TEST_DIR}/proxy_fixture.zsh"

write_fake_autossh_process() {
    local pid="$1"
    local command_line="$2"

    mkdir -p "${MSE_PROXY_PROC_ROOT}/${pid}"
    print -r -- 'autossh' > "${MSE_PROXY_PROC_ROOT}/${pid}/comm"
    printf '%s\0' "${command_line}" > "${MSE_PROXY_PROC_ROOT}/${pid}/cmdline"
}

test_compute_requires_runtime_without_calling_clashctl() {
    make_proxy_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    export SLURM_JOB_ID=123
    write_runtime $'port: 7890\nsocks-port: 7891'
    load_proxy_helpers
    _mse_proxy_require_clashctl_runtime || fail_test "compute clash mode must accept the shared runtime"
    _mse_proxy_sync_clashctl_ports || fail_test "compute clash mode must load shared runtime ports"
    _func_proxy_off >/dev/null
    [[ ! -s "${TEST_TMP}/clashctl.calls" ]] || fail_test "compute proxy.off must not call clashctl"
}

test_compute_rejects_missing_runtime_without_port_fallback() {
    make_proxy_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    export SLURM_JOB_ID=123
    export MSE_PROXY_PORT=7777
    export MSE_PROXY_SOCKS_PORT=7778
    load_proxy_helpers
    if _mse_proxy_require_clashctl_runtime >/dev/null 2>&1; then
        fail_test "compute clash mode must reject a missing runtime"
        return 1
    fi
    assert_eq "" "${MSE_PROXY_PORT:-}" "manual HTTP port must not survive in Linux clash mode"
    assert_eq "" "${MSE_PROXY_SOCKS_PORT:-}" "manual SOCKS port must not survive in Linux clash mode"
}

test_direct_linux_requires_runtime() {
    make_proxy_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    load_proxy_helpers
    local output=""
    if output="$(_mse_proxy_require_clashctl_runtime 2>&1)"; then
        fail_test "direct native Linux must require clashctl runtime"
        return 1
    fi
    assert_contains "$output" "runtime.yaml is missing" "missing runtime should be actionable"
}

test_login_hostname_stays_direct_in_slurm_context() {
    make_proxy_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    export MSE_TEST_HOSTNAME=login05
    export SLURM_JOB_ID=123
    load_proxy_helpers
    if _mse_proxy_is_compute_node; then
        fail_test "login hosts must remain direct even when Slurm variables are present"
    fi
}

test_direct_egress_keeps_its_independent_port() {
    make_proxy_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    export SLURM_JOB_ID=123
    export MSE_PROXY_MODE=direct-egress
    export MSE_PROXY_PORT=7788
    load_proxy_helpers
    _mse_proxy_require_clashctl_runtime || fail_test "direct-egress must not require clashctl runtime"
    _mse_proxy_require_port || fail_test "direct-egress must accept its explicit local SOCKS port"
    assert_eq "7788" "$(_mse_proxy_socks_port)" "direct-egress must use its configured SOCKS port"
}

test_direct_egress_is_compute_only() {
    make_proxy_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    export MSE_PROXY_MODE=direct-egress
    export MSE_PROXY_PORT=7788
    load_proxy_helpers
    _mse_proxy_required_ports_open() { return 0 }
    local output=""
    if output="$(_func_proxy_on 2>&1)"; then
        fail_test "native Linux must reject direct-egress even when its local port is listening"
        return 1
    fi
    assert_contains "${output}" "only supported on Slurm compute nodes" "direct-egress rejection should explain its compute-only scope"
}

test_openbsd_nc_is_supported() {
    make_proxy_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    export SLURM_JOB_ID=123
    write_runtime $'port: 7890\nsocks-port: 7891'
    mkdir -p "${TEST_TMP}/commands"
    print -r -- '#!/bin/sh' > "${TEST_TMP}/commands/nc"
    print -r -- 'echo "usage: nc [-X proxy_protocol] [-x proxy_address]" >&2' >> "${TEST_TMP}/commands/nc"
    chmod +x "${TEST_TMP}/commands/nc"
    export PATH="${TEST_TMP}/commands:/usr/bin:/bin"
    load_proxy_helpers
    assert_eq \
        'nc -x 127.0.0.1:7891 -X 5 %h %p' \
        "$(_mse_proxy_git_ssh_proxy_command)" \
        "OpenBSD nc should provide the Git SSH SOCKS command"
}

test_ncat_fallback_is_supported() {
    make_proxy_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    export SLURM_JOB_ID=123
    write_runtime $'port: 7890\nsocks-port: 7891'
    print -r -- '#!/bin/sh' > "${TEST_TMP}/commands/nc"
    print -r -- 'echo "usage: nc without SOCKS options" >&2' >> "${TEST_TMP}/commands/nc"
    print -r -- '#!/bin/sh' > "${TEST_TMP}/commands/ncat"
    chmod +x "${TEST_TMP}/commands/nc" "${TEST_TMP}/commands/ncat"
    load_proxy_helpers
    assert_eq \
        'ncat --proxy 127.0.0.1:7891 --proxy-type socks5 %h %p' \
        "$(_mse_proxy_git_ssh_proxy_command)" \
        "ncat should remain the fallback when nc lacks SOCKS support"
}

test_git_ssh_command_is_restored() {
    make_proxy_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    export SLURM_JOB_ID=123
    export GIT_SSH_COMMAND='ssh -i /tmp/user-key'
    write_runtime $'port: 7890\nsocks-port: 7891'
    mkdir -p "${TEST_TMP}/commands"
    print -r -- '#!/bin/sh' > "${TEST_TMP}/commands/nc"
    print -r -- 'echo "usage: nc [-X proxy_protocol] [-x proxy_address]" >&2' >> "${TEST_TMP}/commands/nc"
    chmod +x "${TEST_TMP}/commands/nc"
    export PATH="${TEST_TMP}/commands:/usr/bin:/bin"
    load_proxy_helpers
    _mse_proxy_enable_env >/dev/null
    assert_contains "$GIT_SSH_COMMAND" "ProxyCommand" "compute proxy should temporarily manage Git SSH"
    _mse_proxy_disable_env
    assert_eq 'ssh -i /tmp/user-key' "$GIT_SSH_COMMAND" "proxy.off should restore the user Git SSH command"
}

test_managed_scan_finds_old_ports_but_not_unrelated_autossh() {
    make_proxy_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    export SLURM_JOB_ID=123
    export MSE_PROXY_PROC_ROOT="${TEST_TMP}/proc"
    write_runtime $'port: 7890\nsocks-port: 7891'
    load_proxy_helpers
    write_fake_autossh_process 101 '/usr/bin/autossh -M 0 -f -N -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -o BatchMode=yes -o ConnectTimeout=5 -o ConnectionAttempts=1 -o NumberOfPasswordPrompts=0 -o StrictHostKeyChecking=no -L 127.0.0.1:7777:127.0.0.1:7777 login01'
    write_fake_autossh_process 102 '/usr/bin/autossh -M 0 -N -L 127.0.0.1:7000:127.0.0.1:7000 personal-host'
    local pids="$(_mse_proxy_all_tunnel_pids)"
    assert_contains "${pids}" "101" "legacy MSE tunnel must be found after a port change"
    [[ "${pids}" != *"102"* ]] || fail_test "an unrelated autossh tunnel must not be managed"
}

test_stale_tunnel_state_is_removed() {
    make_proxy_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    export SLURM_JOB_ID=123
    export MSE_PROXY_PROC_ROOT="${TEST_TMP}/proc"
    write_runtime $'port: 7890\nsocks-port: 7891'
    load_proxy_helpers
    mkdir -p "$(_mse_proxy_tunnel_state_dir)"
    print -r -- '104' > "$(_mse_proxy_tunnel_pid_file)"
    print -r -- 'stale command' > "$(_mse_proxy_tunnel_command_file)"
    write_fake_autossh_process 104 "/usr/bin/autossh -o HostKeyAlias=$(_mse_proxy_tunnel_marker) -N login01"
    if _mse_proxy_state_tunnel_pid >/dev/null 2>&1; then
        fail_test "mismatched tunnel state must be rejected"
        return 1
    fi
    [[ ! -e "$(_mse_proxy_tunnel_pid_file)" ]] || fail_test "stale PID state must be removed"
    [[ ! -e "$(_mse_proxy_tunnel_command_file)" ]] || fail_test "stale command state must be removed"
}

test_new_tunnel_is_recorded() {
    make_proxy_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    export SLURM_JOB_ID=123
    export MSE_PROXY_PROC_ROOT="${TEST_TMP}/proc"
    write_runtime $'port: 7890\nsocks-port: 7891'
    mkdir -p "${TEST_TMP}/commands"
    print -r -- '#!/bin/sh' > "${TEST_TMP}/commands/autossh"
    print -r -- 'mkdir -p "${MSE_PROXY_PROC_ROOT}/205"' >> "${TEST_TMP}/commands/autossh"
    print -r -- 'printf "%s\n" autossh > "${MSE_PROXY_PROC_ROOT}/205/comm"' >> "${TEST_TMP}/commands/autossh"
    print -r -- '{ printf "%s\0" "$0"; for arg in "$@"; do printf "%s\0" "$arg"; done; } > "${MSE_PROXY_PROC_ROOT}/205/cmdline"' >> "${TEST_TMP}/commands/autossh"
    print -r -- ': > "${TEST_TMP}/tunnel.started"' >> "${TEST_TMP}/commands/autossh"
    chmod +x "${TEST_TMP}/commands/autossh"
    export PATH="${TEST_TMP}/commands:/usr/bin:/bin"
    load_proxy_helpers
    _mse_proxy_required_ports_open() { [[ -e "${TEST_TMP}/tunnel.started" ]] }
    _mse_proxy_probe_local_proxy() { return 0 }
    sleep() { return 0 }
    _mse_proxy_start_tunnel login01 || fail_test "a marked fake tunnel should start"
    assert_eq "205" "$(_mse_proxy_state_tunnel_pid)" "new tunnel PID must be recorded"
    assert_file_contains "$(_mse_proxy_tunnel_command_file)" "HostKeyAlias=$(_mse_proxy_tunnel_marker)" "state must record the managed marker"
}

test_proxy_off_cleans_managed_state_and_legacy_tunnel() {
    make_proxy_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    export SLURM_JOB_ID=123
    export MSE_PROXY_PROC_ROOT="${TEST_TMP}/proc"
    write_runtime $'port: 7890\nsocks-port: 7891'
    load_proxy_helpers
    write_fake_autossh_process 301 '/usr/bin/autossh -M 0 -f -N -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -o BatchMode=yes -o ConnectTimeout=5 -o ConnectionAttempts=1 -o NumberOfPasswordPrompts=0 -o StrictHostKeyChecking=no -L 127.0.0.1:7777:127.0.0.1:7777 login01'
    write_fake_autossh_process 302 '/usr/bin/autossh -M 0 -N -L 127.0.0.1:7000:127.0.0.1:7000 personal-host'
    mkdir -p "$(_mse_proxy_tunnel_state_dir)"
    print -r -- '999' > "$(_mse_proxy_tunnel_pid_file)"
    print -r -- 'stale command' > "$(_mse_proxy_tunnel_command_file)"
    kill() { print -r -- "$*" >> "${TEST_TMP}/kill.calls" }
    sleep() { return 0 }
    _func_proxy_off >/dev/null
    assert_file_contains "${TEST_TMP}/kill.calls" "301" "proxy.off must stop a legacy MSE tunnel on an old port"
    if [[ -e "${TEST_TMP}/kill.calls" ]] && /usr/bin/grep -q '302' "${TEST_TMP}/kill.calls"; then
        fail_test "proxy.off must not stop unrelated autossh"
        return 1
    fi
    [[ ! -e "$(_mse_proxy_tunnel_pid_file)" ]] || fail_test "proxy.off must clear PID state"
    [[ ! -s "${TEST_TMP}/clashctl.calls" ]] || fail_test "compute proxy.off must not call clashctl"
}

run_test "compute clash mode consumes runtime without calling clashctl" test_compute_requires_runtime_without_calling_clashctl
run_test "compute clash mode has no manual port fallback" test_compute_rejects_missing_runtime_without_port_fallback
run_test "direct Linux requires clashctl runtime" test_direct_linux_requires_runtime
run_test "login hostname stays direct in Slurm context" test_login_hostname_stays_direct_in_slurm_context
run_test "direct-egress keeps its independent port" test_direct_egress_keeps_its_independent_port
run_test "direct-egress is compute-only" test_direct_egress_is_compute_only
run_test "OpenBSD nc supports Slurm Git SSH" test_openbsd_nc_is_supported
run_test "ncat remains the Slurm Git SSH fallback" test_ncat_fallback_is_supported
run_test "proxy.off restores user Git SSH command" test_git_ssh_command_is_restored
run_test "managed scan finds old ports only" test_managed_scan_finds_old_ports_but_not_unrelated_autossh
run_test "stale tunnel state is removed" test_stale_tunnel_state_is_removed
run_test "new tunnel state is recorded" test_new_tunnel_is_recorded
run_test "proxy.off cleans MSE tunnel residue" test_proxy_off_cleans_managed_state_and_legacy_tunnel
finish_tests
