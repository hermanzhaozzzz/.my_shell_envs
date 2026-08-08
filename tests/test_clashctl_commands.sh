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

run_test "top-level add adds and uses a subscription" test_top_level_add_adds_and_uses_subscription
run_test "top-level subscription aliases dispatch correctly" test_top_level_subscription_aliases
run_test "help documents top-level subscription commands" test_help_documents_top_level_add_and_del
run_test "default subscription UA requests modern Mihomo profiles" test_default_subscription_ua_requests_modern_mihomo_profiles
run_test "deleting the active subscription clears its runtime" test_deleting_active_subscription_stops_service_and_clears_runtime
finish_tests
