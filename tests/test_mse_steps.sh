#!/usr/bin/env bash
set -u

TEST_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$TEST_DIR/.." && pwd)"
. "$TEST_DIR/testlib.sh"

load_mse() {
    MSE_TEST_SOURCE_ONLY=1 MSE_SCRIPT_PATH_OVERRIDE="$REPO_ROOT/mse" . "$REPO_ROOT/mse"
    AVAILABLE_STEPS="clashctl"
    platform="Linux"
    platform_family="Linux"
    internal_update_mode=0
    deploy_mode="interactive"
    SELECTED_STEPS=""
}

test_interactive_enter_enables_clashctl() {
    load_mse
    choose_steps <<< "" >/dev/null
    assert_eq "clashctl" "$SELECTED_STEPS" "Enter must enable clashctl on native Linux"
}

test_interactive_n_skips_clashctl() {
    load_mse
    choose_steps <<< "n" >/dev/null
    assert_eq "" "$SELECTED_STEPS" "n must skip clashctl"
}

test_fast_enables_clashctl() {
    load_mse
    deploy_mode="fast"
    choose_steps >/dev/null
    assert_eq "clashctl" "$SELECTED_STEPS" "fast mode must enable clashctl"
}

test_clashctl_not_offered_on_macos() {
    load_mse
    platform="MacOS/arm64"
    platform_family="MacOS"
    choose_steps </dev/null >/dev/null
    assert_eq "" "$SELECTED_STEPS" "macOS must not offer clashctl"
}

test_clashctl_not_offered_on_wsl() {
    load_mse
    grep() { return 0; }
    choose_steps </dev/null >/dev/null
    assert_eq "" "$SELECTED_STEPS" "WSL must not offer clashctl"
}

test_no_only_clashctl_argument() {
    load_mse
    local output=""
    if output="$(parse_deploy_args --only clashctl 2>&1)"; then
        fail_test "--only clashctl must remain unsupported"
        return 1
    fi
    assert_contains "$output" "unknown argument" "unsupported --only should be explicit"
}

test_metadata_records_default_selection() {
    load_mse
    local temp_dir=""
    temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/mse-steps.XXXXXX")" || return 1
    trap "rm -rf '$temp_dir'" EXIT
    METADATA_FILE="$temp_dir/install.env"
    REPO_PATH="$temp_dir"
    choose_steps <<< "" >/dev/null
    persist_deploy_settings >/dev/null
    assert_file_contains "$METADATA_FILE" "MSE_STEP_CLASHCTL='true'"
}

test_metadata_records_explicit_skip() {
    load_mse
    local temp_dir=""
    temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/mse-steps.XXXXXX")" || return 1
    trap "rm -rf '$temp_dir'" EXIT
    METADATA_FILE="$temp_dir/install.env"
    REPO_PATH="$temp_dir"
    choose_steps <<< "n" >/dev/null
    persist_deploy_settings >/dev/null
    assert_file_contains "$METADATA_FILE" "MSE_STEP_CLASHCTL='false'"
}

test_failed_step_stops_deploy() {
    load_mse
    SELECTED_STEPS="clashctl"
    broken_step() { return 23; }
    if (run_step clashctl broken_step >/dev/null 2>&1); then
        fail_test "a failed deploy step must stop the deployment"
        return 1
    fi
}

test_ready_clashctl_bootstraps_remaining_deploy() {
    load_mse
    SELECTED_STEPS="clashctl"
    load_repo_clashctl_control_plane() { return 0; }
    clashctl_require_runtime_ready() { return 0; }
    clashctl() { printf '%s\n' "$*" >"$TEST_CLASHCTL_CALL"; }
    TEST_CLASHCTL_CALL="$(mktemp "${TMPDIR:-/tmp}/mse-clash-bootstrap.XXXXXX")" || return 1
    export TEST_CLASHCTL_CALL
    trap 'rm -f "$TEST_CLASHCTL_CALL"' EXIT
    bootstrap_linux_clashctl_proxy >/dev/null
    assert_file_contains "$TEST_CLASHCTL_CALL" "on" "ready clashctl must be enabled before network setup"
}

test_offline_cold_start_stops_before_network_setup() {
    load_mse
    SELECTED_STEPS="clashctl"
    BIN_PATH="/repo/bin"
    load_repo_clashctl_control_plane() { return 0; }
    clashctl_require_runtime_ready() { return 1; }
    deployment_network_ready() { return 1; }
    can_prompt_user() { return 1; }
    if (bootstrap_linux_clashctl_proxy >/dev/null 2>&1); then
        fail_test "non-interactive offline deploy must stop with an actionable clashctl bootstrap"
        return 1
    fi
}

test_offline_first_install_stops_before_clashctl_download() {
    load_mse
    SELECTED_STEPS="clashctl"
    load_repo_clashctl_control_plane() { return 1; }
    clashctl_install_archives_ready() { return 1; }
    deployment_network_ready() { return 1; }
    can_prompt_user() { return 1; }
    if (preflight_linux_clashctl_install >/dev/null 2>&1); then
        fail_test "an offline first install must stop before clashctl attempts a download"
        return 1
    fi
}

test_complete_clashctl_cache_allows_offline_install() {
    load_mse
    SELECTED_STEPS="clashctl"
    load_repo_clashctl_control_plane() { return 1; }
    clashctl_install_archives_ready() { return 0; }
    deployment_network_ready() { return 1; }
    preflight_linux_clashctl_install >/dev/null \
        || fail_test "a complete local clashctl cache must not require bootstrap network"
}

test_dirty_external_repo_is_preserved_without_pull() {
    load_mse
    local fixture=""
    fixture="$(mktemp -d "${TMPDIR:-/tmp}/mse-dirty-nvim.XXXXXX")" || return 1
    export DIRTY_REPO_FIXTURE="$fixture"
    trap 'rm -rf "$DIRTY_REPO_FIXTURE"' EXIT
    mkdir -p "$fixture/home/.config/nvim/.git"
    HOME="$fixture/home"
    local git_calls="$fixture/git.calls"
    git() {
        printf '%s\n' "$*" >>"$git_calls"
        case "$*" in
            *" status --porcelain") printf '%s\n' ' M lazy-lock.json'; return 0 ;;
            *) return 99 ;;
        esac
    }
    step_nvim >/dev/null || fail_test "dirty external nvim config should be preserved, not fail deployment"
    if /usr/bin/grep -Eq ' fetch| pull' "$git_calls"; then
        fail_test "dirty external nvim config must not be fetched or pulled"
    fi
}

test_legacy_code_notify_stop_hook_is_removed() {
    load_mse
    local fixture=""
    fixture="$(mktemp -d "${TMPDIR:-/tmp}/mse-code-notify.XXXXXX")" || return 1
    trap "/bin/rm -rf '$fixture'" EXIT
    mkdir -p "$fixture/.codex"
    cat >"$fixture/.codex/hooks.json" <<'EOF'
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/usr/local/opt/code-notify/lib/code-notify/core/notifier.sh stop claude"
          }
        ]
      }
    ]
  }
}
EOF
    cat >"$fixture/.codex/config.toml" <<EOF
model = "test"

[hooks.state."$fixture/.codex/hooks.json:stop:0:0"]
trusted_hash = "sha256:test"
enabled = true
EOF
    MSE_CODEX_HOME_OVERRIDE="$fixture/.codex" remove_legacy_code_notify_codex_stop_hook >/dev/null
    [ ! -e "$fixture/.codex/hooks.json" ] \
        || fail_test "legacy Code-Notify-only hooks.json must be removed"
    if /usr/bin/grep -q 'hooks.json:stop' "$fixture/.codex/config.toml"; then
        fail_test "stale trusted hook state must be removed"
    fi
    find "$fixture/.codex" -name 'hooks.json.mse-backup-*' -type f | /usr/bin/grep -q . \
        || fail_test "legacy hook cleanup must create a recovery backup"
}

test_legacy_cleanup_preserves_unrelated_stop_hooks() {
    load_mse
    local fixture=""
    fixture="$(mktemp -d "${TMPDIR:-/tmp}/mse-code-notify-preserve.XXXXXX")" || return 1
    trap "/bin/rm -rf '$fixture'" EXIT
    mkdir -p "$fixture/.codex"
    cat >"$fixture/.codex/hooks.json" <<'EOF'
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/usr/local/opt/code-notify/lib/code-notify/core/notifier.sh stop claude"
          },
          {
            "type": "command",
            "command": "/usr/local/bin/keep-me"
          }
        ]
      }
    ]
  }
}
EOF
    MSE_CODEX_HOME_OVERRIDE="$fixture/.codex" remove_legacy_code_notify_codex_stop_hook >/dev/null
    assert_file_contains "$fixture/.codex/hooks.json" "/usr/local/bin/keep-me"
    if /usr/bin/grep -q 'notifier.sh stop claude' "$fixture/.codex/hooks.json"; then
        fail_test "legacy Code-Notify hook must be removed while unrelated hooks remain"
    fi
}

test_codex_notify_owner_distinguishes_existing_integrations() {
    load_mse
    local fixture=""
    fixture="$(mktemp -d "${TMPDIR:-/tmp}/mse-code-notify-owner.XXXXXX")" || return 1
    trap "/bin/rm -rf '$fixture'" EXIT
    mkdir -p "$fixture/.codex"
    cat >"$fixture/.codex/config.toml" <<'EOF'
model = "test"
notify = ["/Applications/Other.app/notifier", "turn-ended"]

[projects."/tmp"]
trust_level = "trusted"
EOF
    assert_eq "other" "$(MSE_CODEX_HOME_OVERRIDE="$fixture/.codex" codex_notify_owner)" \
        "an unrelated Codex notify command must not be mistaken for Code-Notify"
}

run_test "interactive Enter defaults clashctl to enabled" test_interactive_enter_enables_clashctl
run_test "interactive n skips clashctl" test_interactive_n_skips_clashctl
run_test "fast deploy enables clashctl" test_fast_enables_clashctl
run_test "macOS does not offer clashctl" test_clashctl_not_offered_on_macos
run_test "WSL does not offer clashctl" test_clashctl_not_offered_on_wsl
run_test "deploy has no --only clashctl mode" test_no_only_clashctl_argument
run_test "metadata persists default clashctl selection" test_metadata_records_default_selection
run_test "metadata persists clashctl skip" test_metadata_records_explicit_skip
run_test "failed deploy steps stop immediately" test_failed_step_stops_deploy
run_test "ready clashctl bootstraps remaining deploy" test_ready_clashctl_bootstraps_remaining_deploy
run_test "offline cold start stops before network setup" test_offline_cold_start_stops_before_network_setup
run_test "offline first install stops before downloads" test_offline_first_install_stops_before_clashctl_download
run_test "complete clashctl cache installs offline" test_complete_clashctl_cache_allows_offline_install
run_test "dirty external repo is preserved" test_dirty_external_repo_is_preserved_without_pull
run_test "legacy Code-Notify Stop hook is removed safely" test_legacy_code_notify_stop_hook_is_removed
run_test "legacy cleanup preserves unrelated Stop hooks" test_legacy_cleanup_preserves_unrelated_stop_hooks
run_test "Codex notify ownership is detected" test_codex_notify_owner_distinguishes_existing_integrations
finish_tests
