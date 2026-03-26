#!/usr/bin/env sh

set -eu

REPO_URL="https://github.com/hermanzhaozzzz/.my_shell_envs.git"
BRANCH="main"
ARCHIVE_URL="https://codeload.github.com/hermanzhaozzzz/.my_shell_envs/tar.gz/refs/heads/${BRANCH}"
TARGET_DIR="${HOME}/.my_shell_envs"
GLOBAL_BIN_DIR="${HOME}/.local/bin"
GLOBAL_WRAPPER="${GLOBAL_BIN_DIR}/mse"

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "Error: command '$1' is required" >&2
        exit 1
    }
}

uses_zprofile_template=0

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
    echo "This installer will write files under your home directory."
    echo "Expected paths:"
    echo "  - ${TARGET_DIR}"
    echo "  - ${GLOBAL_WRAPPER}"
    echo "  - non-Windows mandatory base setup such as ~/.zshrc, ~/.oh-my-zsh, required Zsh plugins, and your default shell via chsh"
    echo "  - deployment-managed files such as ~/.condarc, ~/.pip/pip.conf, ~/.vim, ~/.vimrc, ~/.config/nvim, ~/.Wudao-dict, and ~/.local/bin tools"
    if [ "${uses_zprofile_template}" -eq 1 ]; then
        echo "  - ~/.zprofile"
    fi
    echo "Existing files are backed up to *_bak or *.backup.* when possible."
    echo
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

    echo "Downloading ${REPO_URL} (${BRANCH}) ..."
    curl -fsSL "${ARCHIVE_URL}" -o "${ARCHIVE_FILE}"

    mkdir -p "${EXTRACT_ROOT}"
    tar -xzf "${ARCHIVE_FILE}" -C "${EXTRACT_ROOT}"
    SOURCE_DIR="$(find "${EXTRACT_ROOT}" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
    [ -n "${SOURCE_DIR}" ] || {
        echo "Error: extracted source directory not found" >&2
        exit 1
    }

    if [ -e "${TARGET_DIR}" ]; then
        BACKUP_PATH="${TARGET_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
        echo "Backing up existing install to ${BACKUP_PATH}"
        mv "${TARGET_DIR}" "${BACKUP_PATH}"
    fi

    mkdir -p "$(dirname "${TARGET_DIR}")"
    cp -R "${SOURCE_DIR}" "${TARGET_DIR}"

    cat >"${TARGET_DIR}/.mse-install.env" <<EOF
INSTALL_MODE="archive"
MSE_REPO_URL="${REPO_URL}"
MSE_DEFAULT_BRANCH="${BRANCH}"
EOF

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
            echo "Tips: add ${GLOBAL_BIN_DIR} to PATH to use 'mse' globally."
            ;;
    esac

    echo "Running initial deployment ..."
    exec "${TARGET_DIR}/mse" deploy "$@"
}

main "$@"
