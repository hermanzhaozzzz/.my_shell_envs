#!/usr/bin/env sh

set -eu

REPO_URL="https://github.com/hermanzhaozzzz/.my_shell_envs.git"
BRANCH="main"
ARCHIVE_URL="https://codeload.github.com/hermanzhaozzzz/.my_shell_envs/tar.gz/refs/heads/${BRANCH}"
TARGET_DIR="${HOME}/.my_shell_envs"
GLOBAL_BIN_DIR="${HOME}/.local/bin"
GLOBAL_WRAPPER="${GLOBAL_BIN_DIR}/mse"
REPO_BIN_DIR="${TARGET_DIR}/bin"
REPO_BIN_MSE="${REPO_BIN_DIR}/mse"

setup_colors() {
    ESC="$(printf '\033')"
    COLOR_RESET=""
    COLOR_BOLD=""
    COLOR_BLUE=""
    COLOR_CYAN=""
    COLOR_GREEN=""
    COLOR_YELLOW=""
    COLOR_RED=""

    if [ -t 1 ] && [ "${TERM:-}" != "dumb" ]; then
        COLOR_RESET="${ESC}[0m"
        COLOR_BOLD="${ESC}[1m"
        COLOR_BLUE="${ESC}[34m"
        COLOR_CYAN="${ESC}[36m"
        COLOR_GREEN="${ESC}[32m"
        COLOR_YELLOW="${ESC}[33m"
        COLOR_RED="${ESC}[31m"
    fi
}

badge() {
    color="$1"
    text="$2"
    printf '%s[%s]%s' "${color}${COLOR_BOLD}" "$text" "$COLOR_RESET"
}

fmt_path() {
    printf '%s%s%s' "${COLOR_CYAN}" "$1" "$COLOR_RESET"
}

log_info() {
    printf '%s %s\n' "$(badge "$COLOR_BLUE" "INFO")" "$*"
}

log_ok() {
    printf '%s %s\n' "$(badge "$COLOR_GREEN" " OK ")" "$*"
}

log_warn() {
    printf '%s %s\n' "$(badge "$COLOR_YELLOW" "WARN")" "$*"
}

fail() {
    printf '%s %s\n' "$(badge "$COLOR_RED" "ERR")" "$*" >&2
    exit 1
}

print_section() {
    printf '\n%s==>%s %s\n' "${COLOR_BLUE}${COLOR_BOLD}" "${COLOR_RESET}" "$1"
}

print_path_item() {
    printf '  - %s\n' "$(fmt_path "$1")"
}

print_list_item() {
    printf '  - %s\n' "$1"
}

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        fail "command '$1' is required"
        exit 1
    }
}

uses_zprofile_template=0
setup_colors

parse_args() {
    for arg in "$@"; do
        case "$arg" in
            --use-zprofile-template)
                uses_zprofile_template=1
                ;;
        esac
    done
}

print_install_warning() {
    print_section "installer will modify these paths"
    print_path_item "${TARGET_DIR}"
    print_path_item "${REPO_BIN_MSE}"
    print_path_item "${GLOBAL_WRAPPER}"
    print_list_item "non-Windows setup such as ~/.zshrc, ~/.oh-my-zsh, required Zsh plugins, and your default shell via chsh (requires zsh already installed)"
    print_list_item "deployment-managed files such as ~/.condarc, ~/.pip/pip.conf, ~/.vim, ~/.vimrc, ~/.config/nvim, ~/.Wudao-dict, and ~/.local/bin tools"
    if [ "${uses_zprofile_template}" -eq 1 ]; then
        print_path_item "~/.zprofile"
    fi
    log_info "existing files are backed up to *_bak or *.backup.* when possible"
}

main() {
    TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/mse-install.XXXXXX")"
    ARCHIVE_FILE="${TMP_ROOT}/source.tar.gz"
    EXTRACT_ROOT="${TMP_ROOT}/extracted"
    BACKUP_PATH=""
    WRAPPER_BACKUP=""

    require_cmd curl
    require_cmd tar
    parse_args "$@"
    print_install_warning

    print_section "download source archive"
    log_info "downloading ${REPO_URL} (${BRANCH})"
    curl -fsSL "${ARCHIVE_URL}" -o "${ARCHIVE_FILE}"

    mkdir -p "${EXTRACT_ROOT}"
    tar -xzf "${ARCHIVE_FILE}" -C "${EXTRACT_ROOT}"
    SOURCE_DIR="$(find "${EXTRACT_ROOT}" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
    [ -n "${SOURCE_DIR}" ] || {
        fail "extracted source directory not found"
    }

    if [ -e "${TARGET_DIR}" ]; then
        BACKUP_PATH="${TARGET_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
        log_warn "backing up existing install to $(fmt_path "${BACKUP_PATH}")"
        mv "${TARGET_DIR}" "${BACKUP_PATH}"
    fi

    mkdir -p "$(dirname "${TARGET_DIR}")"
    cp -R "${SOURCE_DIR}" "${TARGET_DIR}"

    cat >"${TARGET_DIR}/.mse-install.env" <<EOF
INSTALL_MODE="archive"
MSE_REPO_URL="${REPO_URL}"
MSE_DEFAULT_BRANCH="${BRANCH}"
EOF

    mkdir -p "${REPO_BIN_DIR}"
    if [ -e "${REPO_BIN_MSE}" ] || [ -L "${REPO_BIN_MSE}" ]; then
        rm -f "${REPO_BIN_MSE}"
    fi
    ln -s "${TARGET_DIR}/mse" "${REPO_BIN_MSE}"
    log_ok "repo bin entry created: $(fmt_path "${REPO_BIN_MSE}") -> $(fmt_path "${TARGET_DIR}/mse")"

    mkdir -p "${GLOBAL_BIN_DIR}"
    if [ -e "${GLOBAL_WRAPPER}" ] || [ -L "${GLOBAL_WRAPPER}" ]; then
        if [ ! -L "${GLOBAL_WRAPPER}" ]; then
            WRAPPER_BACKUP="${GLOBAL_WRAPPER}.bak.$(date +%Y%m%d_%H%M%S)"
            cp -f "${GLOBAL_WRAPPER}" "${WRAPPER_BACKUP}" 2>/dev/null || true
        fi
        rm -f "${GLOBAL_WRAPPER}"
    fi
    cat >"${GLOBAL_WRAPPER}" <<EOF
#!/usr/bin/env sh
if [ ! -x "${TARGET_DIR}/mse" ]; then
    echo "mse is not installed at ${TARGET_DIR}" >&2
    exit 1
fi
exec "${TARGET_DIR}/mse" "\$@"
EOF
    chmod +x "${GLOBAL_WRAPPER}"

    case ":${PATH}:" in
        *":${GLOBAL_BIN_DIR}:"*)
            ;;
        *)
            log_warn "add ${GLOBAL_BIN_DIR} to PATH if you want the wrapper command 'mse' globally"
            ;;
    esac

    print_section "run initial deployment"
    exec "${TARGET_DIR}/mse" deploy "$@"
}

main "$@"
