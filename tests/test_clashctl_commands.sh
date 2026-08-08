#!/usr/bin/env bash
set -u

TEST_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$TEST_DIR/.." && pwd)"
. "$TEST_DIR/testlib.sh"

setup_command_fixture() {
    export CLASHCTL_HOME="$REPO_ROOT/tools/clashctl"
    # shellcheck disable=SC1090
    . "$CLASHCTL_HOME/scripts/cmd/clashctl.sh"
    clashsub() {
        printf '%s\n' "$*"
    }
}

test_top_level_add_adds_and_uses_subscription() {
    setup_command_fixture
    local output=""
    output="$(clashctl add https://example.test/sub)"
    assert_eq "add --use https://example.test/sub" "$output" "top-level add must route to sub add --use"
}

test_top_level_subscription_aliases() {
    setup_command_fixture
    local output=""
    output="$(clashctl del 7)"
    assert_eq "del 7" "$output" "top-level del must route to sub del"
    output="$(clashctl update 7)"
    assert_eq "update 7" "$output" "top-level update must route to sub update"
    output="$(clashctl use 7)"
    assert_eq "use 7" "$output" "top-level use must route to sub use"
    output="$(clashctl ls)"
    assert_eq "ls" "$output" "top-level ls must route to sub ls"
}

test_help_documents_top_level_add_and_del() {
    setup_command_fixture
    local output=""
    output="$(clashctl help)"
    assert_contains "$output" "add <url>" "help must document top-level add"
    assert_contains "$output" "del <id>" "help must document top-level del"
}

test_default_subscription_ua_requests_modern_mihomo_profiles() {
    assert_file_contains \
        "$REPO_ROOT/tools/clashctl/.env" \
        'CLASHCTL_SUB_UA=${CLASHCTL_SUB_UA:-clash-verge/v2.3.1}' \
        "default subscription UA must request modern Mihomo protocols"
    assert_file_contains \
        "$REPO_ROOT/tools/clashctl/mse-deploy.sh" \
        'CLASHCTL_SUB_UA="${MSE_CLASHCTL_SUB_UA:-clash-verge/v2.3.1}"' \
        "deploy must persist the modern subscription UA"
    assert_file_contains \
        "$REPO_ROOT/tools/clashctl/mse-deploy.sh" \
        'INIT_TYPE=nohup\nCLASHCTL_SUB_UA=%s\n' \
        "deploy state must include the subscription UA"
}

test_deleting_active_subscription_stops_service_and_clears_runtime() {
    setup_command_fixture
    local fixture=""
    fixture="$(mktemp -d "${TMPDIR:-/tmp}/mse-command-delete.XXXXXX")" || return 1
    export COMMAND_DELETE_FIXTURE="$fixture"
    trap 'rm -rf "$COMMAND_DELETE_FIXTURE"' EXIT

    CLASH_PROFILES_META="$fixture/profiles.yaml"
    CLASH_PROFILES_LOG="$fixture/profiles.log"
    CLASH_CONFIG_BASE="$fixture/config.yaml"
    CLASH_CONFIG_RUNTIME="$fixture/runtime.yaml"
    CLASH_CONFIG_TEMP="$fixture/temp.yaml"
    BIN_YQ=fake_yq
    local fixture_profile="$fixture/1.yaml"
    : > "$CLASH_PROFILES_META"
    : > "$fixture_profile"
    : > "$CLASH_CONFIG_BASE"
    : > "$CLASH_CONFIG_RUNTIME"
    : > "$CLASH_CONFIG_TEMP"

    fake_yq() {
        case "${1:-}" in
            -i) return 0 ;;
            *) printf '1\n' ;;
        esac
    }
    _get_path_by_id() { printf '%s\n' "$fixture_profile"; }
    _get_url_by_id() { printf '%s\n' 'https://example.test/sub'; }
    service_stop() { : > "$fixture/service-stopped"; }
    service_is_active() { return 1; }
    _logging_sub() { :; }
    _okcat() { :; }
    _errorcat() { printf '%s\n' "$*" >&2; }

    _sub_del 1 || fail_test "active subscription deletion must succeed after stopping its service"
    [ -e "$fixture/service-stopped" ] || fail_test "active subscription deletion must stop the service"
    [ ! -e "$fixture_profile" ] || fail_test "active profile must be removed"
    [ ! -e "$CLASH_CONFIG_BASE" ] || fail_test "active base config must be removed"
    [ ! -e "$CLASH_CONFIG_RUNTIME" ] || fail_test "active runtime must be removed"
    [ ! -e "$CLASH_CONFIG_TEMP" ] || fail_test "active temporary config must be removed"
}

test_free_proxy_ports_are_a_successful_detection() {
    setup_command_fixture
    BIN_YQ=fake_port_yq
    fake_port_yq() { printf '7890|7890|7891\n'; }
    _is_port_used() { return 1; }
    service_is_active() { return 1; }
    _detect_proxy_port || fail_test "free configured ports must not prevent service startup"
}

test_service_only_off_succeeds_without_proxy_environment() {
    setup_command_fixture
    off_service_only() { return 0; }
    unset http_proxy
    clashoff --service-only || fail_test "successful service stop must return zero when proxy env is unset"
}

test_failed_subscription_switch_restores_previous_runtime() {
    setup_command_fixture
    local fixture=""
    fixture="$(mktemp -d "${TMPDIR:-/tmp}/mse-command-switch.XXXXXX")" || return 1
    export COMMAND_SWITCH_FIXTURE="$fixture"
    trap 'rm -rf "$COMMAND_SWITCH_FIXTURE"' EXIT

    CLASH_RESOURCES_DIR="$fixture"
    CLASH_PROFILES_META="$fixture/profiles.yaml"
    CLASH_PROFILES_LOG="$fixture/profiles.log"
    CLASH_CONFIG_BASE="$fixture/config.yaml"
    CLASH_CONFIG_RUNTIME="$fixture/runtime.yaml"
    BIN_YQ=fake_switch_yq
    local fixture_profile="$fixture/2.yaml"
    printf 'use: 1\n' >"$CLASH_PROFILES_META"
    printf 'old-base\n' >"$CLASH_CONFIG_BASE"
    printf 'old-runtime\n' >"$CLASH_CONFIG_RUNTIME"
    printf 'new-profile\n' >"$fixture_profile"

    fake_switch_yq() { return 0; }
    _get_path_by_id() { printf '%s\n' "$fixture_profile"; }
    _get_url_by_id() { printf '%s\n' 'https://example.test/new'; }
    service_is_active() { return 0; }
    service_stop() { return 0; }
    service_start() { return 0; }
    service_sudo_stop() { return 0; }
    service_sudo_start() { return 0; }
    clashctl_wait_proxy_ports() { return 0; }
    tunstatus() { return 1; }
    _is_tun_enabled() { return 1; }
    _merge_config_restart() {
        printf 'broken-runtime\n' >"$CLASH_CONFIG_RUNTIME"
        return 1
    }
    _logging_sub() { :; }
    _okcat() { :; }
    _errorcat() { return 1; }

    if _sub_use 2 >/dev/null 2>&1; then
        fail_test "a failed runtime restart must reject the subscription switch"
        return 1
    fi
    assert_file_contains "$CLASH_CONFIG_BASE" "old-base" "failed switch must restore the previous base config"
    assert_file_contains "$CLASH_CONFIG_RUNTIME" "old-runtime" "failed switch must restore the previous runtime"
    assert_file_contains "$CLASH_PROFILES_META" "use: 1" "failed switch must preserve the previous active subscription"
}

test_active_subscription_update_restores_profile_on_switch_failure() {
    setup_command_fixture
    local fixture=""
    fixture="$(mktemp -d "${TMPDIR:-/tmp}/mse-command-update.XXXXXX")" || return 1
    export COMMAND_UPDATE_FIXTURE="$fixture"
    trap 'rm -rf "$COMMAND_UPDATE_FIXTURE"' EXIT

    CLASH_RESOURCES_DIR="$fixture"
    CLASH_PROFILES_META="$fixture/profiles.yaml"
    CLASH_PROFILES_LOG="$fixture/profiles.log"
    CLASH_CONFIG_TEMP="$fixture/temp.yaml"
    BIN_YQ=fake_update_yq
    local fixture_profile="$fixture/1.yaml"
    printf 'use: 1\n' >"$CLASH_PROFILES_META"
    printf 'old-profile\n' >"$fixture_profile"

    fake_update_yq() { printf '1\n'; }
    _get_path_by_id() { printf '%s\n' "$fixture_profile"; }
    _get_url_by_id() { printf '%s\n' 'https://example.test/sub'; }
    _download_config() { printf 'new-profile\n' >"$CLASH_CONFIG_TEMP"; }
    _valid_config() { return 0; }
    _sub_use() { return 1; }
    _logging_sub() { :; }
    _okcat() { :; }
    _errorcat() { return 1; }

    if _sub_update 1 >/dev/null 2>&1; then
        fail_test "an active update must fail when the new runtime cannot be activated"
        return 1
    fi
    assert_file_contains "$fixture_profile" "old-profile" "failed active update must restore the previous profile"
}

run_test "top-level add adds and uses a subscription" test_top_level_add_adds_and_uses_subscription
run_test "top-level subscription aliases dispatch correctly" test_top_level_subscription_aliases
run_test "help documents top-level subscription commands" test_help_documents_top_level_add_and_del
run_test "default subscription UA requests modern Mihomo profiles" test_default_subscription_ua_requests_modern_mihomo_profiles
run_test "deleting the active subscription clears its runtime" test_deleting_active_subscription_stops_service_and_clears_runtime
run_test "free proxy ports allow service startup" test_free_proxy_ports_are_a_successful_detection
run_test "service-only stop returns success without proxy env" test_service_only_off_succeeds_without_proxy_environment
run_test "failed subscription switch restores old runtime" test_failed_subscription_switch_restores_previous_runtime
run_test "failed active update restores old profile" test_active_subscription_update_restores_profile_on_switch_failure
finish_tests
