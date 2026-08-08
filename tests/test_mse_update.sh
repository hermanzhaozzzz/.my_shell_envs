#!/usr/bin/env bash
set -u

TEST_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$TEST_DIR/.." && pwd)"
. "$TEST_DIR/testlib.sh"

load_mse_update_fixture() {
    MSE_TEST_SOURCE_ONLY=1 MSE_SCRIPT_PATH_OVERRIDE="$REPO_ROOT/mse" . "$REPO_ROOT/mse"
    UPDATE_TMP="$(mktemp -d "${TMPDIR:-/tmp}/mse-update.XXXXXX")" || return 1
    export UPDATE_TMP
    REPO_PATH="$UPDATE_TMP/repo"
    GIT_CALLS="$UPDATE_TMP/git.calls"
    export GIT_CALLS
    mkdir -p "$REPO_PATH"
    : >"$GIT_CALLS"
    persisted_default_branch=main
}

install_fake_git() {
    FAKE_ORIGIN_URL=$1
    export FAKE_ORIGIN_URL
    git() {
        printf '%s\n' "$*" >>"$GIT_CALLS"
        case "$*" in
            *" status --porcelain") return 0 ;;
            *" remote get-url origin") printf '%s\n' "$FAKE_ORIGIN_URL" ;;
            *" branch --show-current") printf '%s\n' main ;;
            *" fetch "*|*" rebase FETCH_HEAD") return 0 ;;
            *) return 1 ;;
        esac
    }
}

test_https_update_converts_ssh_origin() {
    load_mse_update_fixture
    trap 'rm -rf "$UPDATE_TMP"' EXIT
    install_fake_git 'git@github.com:example/mse.git'
    update_git_method=https
    update_source_from_git >/dev/null
    assert_file_contains "$GIT_CALLS" "fetch https://github.com/example/mse.git main" "HTTPS update must not reuse an SSH origin"
}

test_ssh_update_converts_https_origin() {
    load_mse_update_fixture
    trap 'rm -rf "$UPDATE_TMP"' EXIT
    install_fake_git 'https://github.com/example/mse.git'
    update_git_method=ssh
    update_source_from_git >/dev/null
    assert_file_contains "$GIT_CALLS" "fetch git@github.com:example/mse.git main" "SSH update must not reuse an HTTPS origin"
}

test_unconvertible_origin_fails_closed() {
    load_mse_update_fixture
    trap 'rm -rf "$UPDATE_TMP"' EXIT
    install_fake_git 'file:///tmp/mse.git'
    update_git_method=https
    if (update_source_from_git >/dev/null 2>&1); then
        fail_test "an origin that cannot honor the requested method must fail closed"
        return 1
    fi
}

run_test "HTTPS update converts an SSH GitHub origin" test_https_update_converts_ssh_origin
run_test "SSH update converts an HTTPS GitHub origin" test_ssh_update_converts_https_origin
run_test "unconvertible update origins fail closed" test_unconvertible_origin_fails_closed
finish_tests
