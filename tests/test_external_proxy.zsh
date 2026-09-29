#!/usr/bin/env zsh

TEST_DIR="${0:A:h}"
source "${TEST_DIR}/testlib.sh"
source "${TEST_DIR}/proxy_fixture.zsh"

external_fixture() {
    make_proxy_fixture
    load_proxy_helpers
    export _OS=macOS
    export MSE_PROXY_QUIET=1
    _mse_proxy_external_candidates() { print -r -- "$CANDIDATES"; }
    _mse_proxy_external_probe() {
        print -r -- "$*" >> "$TEST_TMP/probes"
        [[ "|${GOOD_ENDPOINTS}|" == *"|$1 $2 $3|"* ]]
    }
}

test_macos_system_and_client_parsers() {
    external_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    scutil() {
        print -r -- $'<dictionary> {\n  HTTPEnable : 1\n  HTTPProxy : 127.0.0.1\n  HTTPPort : 6152\n  HTTPSEnable : 1\n  HTTPSProxy : 127.0.0.1\n  HTTPSPort : 6152\n  SOCKSEnable : 0\n  SOCKSProxy : 127.0.0.1\n  SOCKSPort : 6153\n  __SCOPED__ : <dictionary> {\n    HTTPPort : 9999\n  }\n}'
    }
    lsof() {
        print -r -- $'p11\ncSurge\nn127.0.0.1:6152\nn127.0.0.1:6153\np12\ncClashX\nn*:7890\np13\ncFlClash\nn[::1]:8890\np14\ncmihomo\nn*:8891\np15\ncweb-server\nn*:9090'
    }
    local actual="$(_mse_proxy_macos_candidates)"
    assert_contains "$actual" 'macOS-system|127.0.0.1|6152'
    assert_contains "$actual" 'macOS-process-Surge-11|127.0.0.1|6153'
    assert_contains "$actual" 'macOS-process-ClashX-12|127.0.0.1|7890'
    assert_contains "$actual" 'macOS-process-FlClash-13|[::1]|8890'
    assert_contains "$actual" 'macOS-process-mihomo-14|127.0.0.1|8891'
    [[ "$actual" != *9999* && "$actual" != *9090* ]] || fail_test 'scoped settings and web servers must not become candidates'
    [[ "$actual" != *'macOS-system|127.0.0.1|6153'* ]] || fail_test 'disabled SOCKS setting must be ignored'
}

test_system_precedence_and_http_only() {
    external_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    CANDIDATES=$'macOS-system|127.0.0.1|6152\nmacOS-process-ClashX-1|127.0.0.1|7890'
    GOOD_ENDPOINTS='http 127.0.0.1 6152|http 127.0.0.1 7890|socks 127.0.0.1 7890'
    export MSE_PROXY_PORT=9999 MSE_PROXY_SOCKS_PORT=9998 MSE_PROXY_HOST=old-host
    export MSE_PROXY_AUTH=stale-credentials
    _func_proxy_on || fail_test 'HTTP-only proxy must work'
    assert_eq 'macOS-system' "$MSE_PROXY_SOURCE"
    assert_eq 'http://127.0.0.1:6152' "$http_proxy"
    assert_eq "$http_proxy" "$all_proxy" 'HTTP port must not be presented as SOCKS'
    assert_eq "$all_proxy" "$ALL_PROXY" 'uppercase proxy must match lowercase'
    assert_eq '' "$MSE_PROXY_SOCKS_PORT"
    assert_file_contains "$(_mse_proxy_runtime_proxychains_conf)" 'http 127.0.0.1 6152'
    [[ ! -e "$TEST_TMP/clashctl.calls" ]] || fail_test 'external clients must not call clashctl'
}

test_mixed_port() {
    external_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    CANDIDATES='macOS-process-FlClash-1|127.0.0.1|8890'
    GOOD_ENDPOINTS='http 127.0.0.1 8890|socks 127.0.0.1 8890'
    _func_proxy_on || fail_test 'mixed port must work'
    assert_eq 'http://127.0.0.1:8890' "$https_proxy"
    assert_eq 'socks5h://127.0.0.1:8890' "$all_proxy"
}

test_ipv6_endpoint() {
    external_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    CANDIDATES='macOS-process-FlClash-1|[::1]|8890'
    GOOD_ENDPOINTS='http [::1] 8890|socks [::1] 8890'
    _func_proxy_on || fail_test 'IPv6 loopback must work'
    assert_eq 'http://[::1]:8890' "$https_proxy"
    assert_eq 'socks5h://[::1]:8890' "$all_proxy"
    assert_file_contains "$(_mse_proxy_runtime_proxychains_conf)" 'socks5 ::1 8890'
}

test_separate_protocol_hosts() {
    external_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    CANDIDATES=$'macOS-system|127.0.0.1|6152\nmacOS-system|192.0.2.1|6153'
    GOOD_ENDPOINTS='http 127.0.0.1 6152|socks 192.0.2.1 6153'
    _func_proxy_on || fail_test 'separate endpoints must work'
    assert_eq 'http://127.0.0.1:6152' "$https_proxy"
    assert_eq 'socks5h://192.0.2.1:6153' "$all_proxy"
    assert_file_contains "$(_mse_proxy_runtime_proxychains_conf)" 'socks5 192.0.2.1 6153'
}

test_socks_only() {
    external_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    CANDIDATES='macOS-process-Surge-2|127.0.0.1|6153'
    GOOD_ENDPOINTS='socks 127.0.0.1 6153'
    _func_proxy_on || fail_test 'SOCKS-only client must work'
    assert_eq 'socks5h://127.0.0.1:6153' "$http_proxy"
    assert_eq "$http_proxy" "$all_proxy"
    assert_eq '' "$MSE_PROXY_PORT"
    assert_file_contains "$(_mse_proxy_runtime_proxychains_conf)" 'socks5 127.0.0.1 6153'
}

test_wsl_nat_gateway() {
    external_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    export _OS=WSL
    ip() { print -r -- 'default via 172.28.32.1 dev eth0'; }
    CANDIDATES='Windows-system|127.0.0.1|7890'
    GOOD_ENDPOINTS='http 172.28.32.1 7890|socks 172.28.32.1 7890'
    _func_proxy_on || fail_test 'WSL must try Windows gateway'
    assert_eq '172.28.32.1' "$MSE_PROXY_HOST"
    assert_eq 'socks5h://172.28.32.1:7890' "$all_proxy"
}

test_wsl_mirrored_prefers_loopback() {
    external_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    export _OS=WSL
    ip() { print -r -- 'default via 172.28.32.1 dev eth0'; }
    CANDIDATES='Windows-system|localhost|7890'
    GOOD_ENDPOINTS='http 127.0.0.1 7890|socks 127.0.0.1 7890|http 172.28.32.1 7890'
    _func_proxy_on || fail_test 'mirrored mode must work'
    assert_eq '127.0.0.1' "$MSE_PROXY_HOST"
}

test_invalid_and_stale_endpoints() {
    external_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    CANDIDATES=$'macOS-system|127.0.0.1|0\nmacOS-system|127.0.0.1|65536\nmacOS-system|127.0.0.1|bad\nmacOS-system|127.0.0.1/path|80'
    GOOD_ENDPOINTS=''
    export MSE_PROXY_PORT=7777 MSE_PROXY_SOCKS_PORT=7778
    export http_proxy=http://old:7777 all_proxy=socks5h://old:7778
    if _func_proxy_on >/dev/null 2>&1; then fail_test 'invalid endpoints must fail'; fi
    [[ ! -e "$TEST_TMP/probes" ]] || fail_test 'invalid candidates must never be probed'
    assert_eq '' "${MSE_PROXY_PORT:-}"
    assert_eq '' "${http_proxy:-}"
    assert_eq '' "${all_proxy:-}"
}

test_process_fallback_and_no_cross_client_pairing() {
    external_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    CANDIDATES=$'macOS-system|127.0.0.1|9999\nmacOS-process-Surge-2|127.0.0.1|6152\nmacOS-process-ClashX-3|127.0.0.1|7891'
    GOOD_ENDPOINTS='http 127.0.0.1 6152|socks 127.0.0.1 7891'
    _func_proxy_on || fail_test 'client fallback must work'
    assert_eq 'macOS-process-Surge-2' "$MSE_PROXY_SOURCE"
    assert_eq '' "$MSE_PROXY_SOCKS_PORT" 'do not combine unrelated clients'
}

test_refresh_and_external_off() {
    external_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    CANDIDATES='macOS-system|127.0.0.1|6152'
    GOOD_ENDPOINTS='http 127.0.0.1 6152'
    _func_proxy_on || fail_test 'first detection must work'
    CANDIDATES='macOS-system|127.0.0.1|8890'
    GOOD_ENDPOINTS='http 127.0.0.1 8890'
    _func_proxy_on || fail_test 'updated detection must work'
    assert_eq 'http://127.0.0.1:8890' "$https_proxy"
    _func_proxy_off || fail_test 'off must work'
    assert_eq '' "${https_proxy:-}"
    [[ ! -e "$TEST_TMP/clashctl.calls" ]] || fail_test 'off must leave external client alone'
}

test_status_reports_source_without_enabling_proxy() {
    external_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    CANDIDATES='macOS-process-Surge-2|127.0.0.1|6152'
    GOOD_ENDPOINTS='http 127.0.0.1 6152'
    unset http_proxy https_proxy all_proxy
    local actual="$(_func_proxy_status)"
    assert_contains "$actual" 'proxy discovery: macOS-process-Surge-2'
    assert_contains "$actual" 'proxy HTTP endpoint: http://127.0.0.1:6152'
    assert_contains "$actual" 'proxy SOCKS endpoint: <unavailable>'
    assert_contains "$actual" 'proxy env http: <unset>'
    assert_eq '' "${http_proxy:-}" 'status must not enable proxy variables'
}

test_external_exec_avoids_nested_proxy() {
    external_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    CANDIDATES='macOS-system|127.0.0.1|6152'
    GOOD_ENDPOINTS='http 127.0.0.1 6152'
    export http_proxy=http://old:9999 HTTPS_PROXY=http://old:9999 ALL_PROXY=socks5h://old:9998
    cat > "$TEST_TMP/commands/proxychains4" <<'EOF'
#!/bin/sh
test -z "${http_proxy:-}${HTTPS_PROXY:-}${ALL_PROXY:-}" || exit 23
test "$1" = -f || exit 24
grep -q 'http 127.0.0.1 6152' "$2" || exit 25
shift 2
exec "$@"
EOF
    chmod +x "$TEST_TMP/commands/proxychains4"
    local actual="$(_func_proxy_exec printf 'command reached')" || fail_test 'proxy.exec must clear inherited proxy variables for the child'
    assert_eq 'command reached' "$actual"
    assert_eq 'http://old:9999' "$http_proxy" 'exec must not mutate parent proxy environment'
}

test_startup_does_not_discover() {
    external_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    _mse_proxy_external_candidates() { fail_test 'startup must not discover'; }
    _mse_proxy_auto_init >/dev/null || fail_test 'startup must return immediately'
}

test_probe_requires_correct_protocol() {
    external_fixture
    trap 'rm -rf "$TEST_TMP"' EXIT
    source "$REPO_ROOT/zsh/proxy_external.zsh"
    curl() {
        print -r -- "$*" >> "$TEST_TMP/curl.args"
        print -rn -- "$CURL_CODE"
        return "${CURL_RC:-0}"
    }
    CURL_CODE=200 CURL_RC=0
    _mse_proxy_external_probe http 127.0.0.1 6152 || fail_test 'CONNECT 200 must pass'
    assert_file_contains "$TEST_TMP/curl.args" '%{http_connect}'
    assert_file_contains "$TEST_TMP/curl.args" '--noproxy  --proxy http://127.0.0.1:6152'
    CURL_CODE=407
    if _mse_proxy_external_probe http 127.0.0.1 6152; then fail_test 'auth-required proxy must not pass'; fi
    CURL_CODE=000
    if _mse_proxy_external_probe http 127.0.0.1 6152; then fail_test 'web dashboard must not pass CONNECT'; fi
    CURL_CODE=200 CURL_RC=7
    if _mse_proxy_external_probe socks 127.0.0.1 6153; then fail_test 'failed SOCKS negotiation must not pass'; fi
    CURL_CODE=403 CURL_RC=0
    _mse_proxy_external_probe socks 127.0.0.1 6153 || fail_test 'HTTP denial still proves SOCKS transport'
}

run_test 'macOS system settings and Surge/ClashX/FlClash parsing' test_macos_system_and_client_parsers
run_test 'system settings take precedence and HTTP-only works' test_system_precedence_and_http_only
run_test 'mixed proxy supports both protocols' test_mixed_port
run_test 'IPv6 URLs and proxychains addresses are formatted correctly' test_ipv6_endpoint
run_test 'separate protocol hosts are preserved' test_separate_protocol_hosts
run_test 'SOCKS-only proxy uses remote DNS' test_socks_only
run_test 'WSL NAT tries Windows host gateway' test_wsl_nat_gateway
run_test 'WSL mirrored mode prefers localhost' test_wsl_mirrored_prefers_loopback
run_test 'invalid discovery clears stale settings' test_invalid_and_stale_endpoints
run_test 'fallback does not mix unrelated clients' test_process_fallback_and_no_cross_client_pairing
run_test 'ports refresh and off preserves external clients' test_refresh_and_external_off
run_test 'status reports discovery without enabling proxy' test_status_reports_source_without_enabling_proxy
run_test 'proxy.exec avoids nesting environment proxies' test_external_exec_avoids_nested_proxy
run_test 'shell startup performs no discovery' test_startup_does_not_discover
run_test 'probes validate protocol and ignore inherited bypass' test_probe_requires_correct_protocol
finish_tests
