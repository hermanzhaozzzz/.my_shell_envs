#!/usr/bin/env bash
set -u

TEST_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$TEST_DIR/.." && pwd)"
. "$TEST_DIR/testlib.sh"

setup_readiness_fixture() {
    READINESS_TMP="$(mktemp -d "${TMPDIR:-/tmp}/mse-readiness.XXXXXX")" || return 1
    export READINESS_TMP
    export CLASHCTL_HOME="$READINESS_TMP/clashctl"
    export CLASHCTL_STATE_DIR="$CLASHCTL_HOME/state"
    export CLASHCTL_BIN_DIR="$READINESS_TMP/bin"
    export CLASHCTL_KERNEL="mihomo"
    export FAKE_YQ_OUTPUT="7890|7891"
    mkdir -p "$CLASHCTL_STATE_DIR" "$CLASHCTL_BIN_DIR"
    cp "$TEST_DIR/fixtures/fake-yq.sh" "$CLASHCTL_BIN_DIR/yq"
    cp "$TEST_DIR/fixtures/fake-kernel.sh" "$CLASHCTL_BIN_DIR/mihomo"
    mkdir -p "$CLASHCTL_BIN_DIR/subconverter"
    cp "$TEST_DIR/fixtures/fake-kernel.sh" "$CLASHCTL_BIN_DIR/subconverter/subconverter"
    chmod +x "$CLASHCTL_BIN_DIR/yq" "$CLASHCTL_BIN_DIR/mihomo" "$CLASHCTL_BIN_DIR/subconverter/subconverter"
    _failcat() { printf '%s\n' "$*"; }
    . "$REPO_ROOT/tools/clashctl/scripts/lib/common.sh"
}

test_missing_state_env_is_not_installed() {
    setup_readiness_fixture
    trap 'rm -rf "$READINESS_TMP"' EXIT
    local output=""
    if output="$(clashctl_require_install_ready 2>&1)"; then
        fail_test "state/env must be required even when binaries exist"
        return 1
    fi
    assert_contains "$output" "env 不存在" "missing deploy state should be diagnosed"
}

test_missing_runtime_is_not_ready() {
    setup_readiness_fixture
    trap 'rm -rf "$READINESS_TMP"' EXIT
    printf 'CLASHCTL_KERNEL=mihomo\n' > "$CLASHCTL_STATE_DIR/env"
    local output=""
    if output="$(clashctl_require_runtime_ready 2>&1)"; then
        fail_test "runtime.yaml must be required"
        return 1
    fi
    assert_contains "$output" "runtime.yaml 不存在" "missing runtime should include setup guidance"
}

test_missing_subconverter_is_not_installed() {
    setup_readiness_fixture
    trap 'rm -rf "$READINESS_TMP"' EXIT
    printf 'CLASHCTL_KERNEL=mihomo\n' > "$CLASHCTL_STATE_DIR/env"
    rm -f "$CLASHCTL_BIN_DIR/subconverter/subconverter"
    local output=""
    if output="$(clashctl_require_install_ready 2>&1)"; then
        fail_test "subconverter must be required for a complete clashctl install"
        return 1
    fi
    assert_contains "$output" "subconverter" "missing subconverter should be diagnosed"
}

test_runtime_requires_both_proxy_ports() {
    setup_readiness_fixture
    trap 'rm -rf "$READINESS_TMP"' EXIT
    printf 'CLASHCTL_KERNEL=mihomo\n' > "$CLASHCTL_STATE_DIR/env"
    printf 'port: 7890\nsocks-port: 7891\n' > "$CLASH_CONFIG_RUNTIME"
    export FAKE_YQ_OUTPUT="|7890|"
    if clashctl_require_runtime_ready >/dev/null 2>&1; then
        fail_test "HTTP-only output must not be ready"
        return 1
    fi
    export FAKE_YQ_OUTPUT="|7890|7891"
    clashctl_require_runtime_ready || fail_test "valid HTTP and SOCKS ports should be ready"
}

run_test "state/env is required for installation readiness" test_missing_state_env_is_not_installed
run_test "runtime.yaml is required for runtime readiness" test_missing_runtime_is_not_ready
run_test "subconverter is required for install readiness" test_missing_subconverter_is_not_installed
run_test "runtime readiness requires HTTP and SOCKS ports" test_runtime_requires_both_proxy_ports
finish_tests
