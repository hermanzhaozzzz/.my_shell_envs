TEST_DIR="${0:A:h}"
REPO_ROOT="${TEST_DIR:h}"

make_proxy_fixture() {
    TEST_TMP="$(mktemp -d "${TMPDIR:-/tmp}/mse-proxy.XXXXXX")" || return 1
    export TEST_TMP
    export HOME="${TEST_TMP}/home"
    export MSE_REPO_ROOT="${TEST_TMP}/repo"
    export CLASHCTL_BIN_DIR="${MSE_REPO_ROOT}/bin"
    export PATH="${TEST_TMP}/commands:/usr/bin:/bin"
    export _OS="Linux"
    export MSE_PROXY_MODE="clash"
    export MSE_PROXY_HOST="127.0.0.1"
    export MSE_PROXY_DIRECT_HOSTS=""
    export MSE_SLURM_NODE_PROXY_AUTO_ENABLE="false"
    unset MSE_PROXY_PORT MSE_PROXY_SOCKS_PORT CLASH_CONFIG_RUNTIME
    unset MSE_PROXY_PROC_ROOT MSE_PROXY_UPSTREAM_HOST GIT_SSH_COMMAND
    unset SLURM_JOB_ID SLURM_SUBMIT_HOST SSH_CONNECTION SSH_CLIENT

    mkdir -p \
        "${HOME}" \
        "${TEST_TMP}/commands" \
        "${MSE_REPO_ROOT}/bin/subconverter" \
        "${MSE_REPO_ROOT}/tools/clashctl/scripts/cmd" \
        "${MSE_REPO_ROOT}/tools/clashctl/state"
    touch \
        "${MSE_REPO_ROOT}/bin/mihomo" \
        "${MSE_REPO_ROOT}/bin/yq" \
        "${MSE_REPO_ROOT}/bin/subconverter/subconverter"
    chmod +x \
        "${MSE_REPO_ROOT}/bin/mihomo" \
        "${MSE_REPO_ROOT}/bin/yq" \
        "${MSE_REPO_ROOT}/bin/subconverter/subconverter"
    print -r -- 'CLASHCTL_KERNEL=mihomo' > "${MSE_REPO_ROOT}/tools/clashctl/state/env"
    print -r -- 'typeset -g CLASHCTL_KERNEL=mihomo' > "${MSE_REPO_ROOT}/tools/clashctl/scripts/cmd/clashctl.sh"
    print -r -- 'clashctl() { print -r -- "$*" >> "${TEST_TMP}/clashctl.calls"; }' >> "${MSE_REPO_ROOT}/tools/clashctl/scripts/cmd/clashctl.sh"
    print -r -- '#!/bin/sh' > "${TEST_TMP}/commands/hostname"
    print -r -- 'printf "%s\n" "${MSE_TEST_HOSTNAME:-test-host}"' >> "${TEST_TMP}/commands/hostname"
    chmod +x "${TEST_TMP}/commands/hostname"
}

write_runtime() {
    print -r -- "$@" > "${MSE_REPO_ROOT}/tools/clashctl/state/runtime.yaml"
}

load_proxy_helpers() {
    local helper_source="${TEST_TMP}/proxy-helpers.zsh"
    awk '
        /^# Proxy helpers$/ { capture=1 }
        /^# 自定义函数命令$/ { capture=0 }
        capture { print }
    ' "${REPO_ROOT}/zsh/zshrc" > "${helper_source}"
    source "${helper_source}"
}
