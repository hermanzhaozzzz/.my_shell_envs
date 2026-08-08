#!/usr/bin/env bash

set -e

CLASHCTL_SRC="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
CLASHCTL_HOME="${CLASHCTL_SRC}"
CLASHCTL_KERNEL="${MSE_CLASHCTL_KERNEL:-mihomo}"
CLASHCTL_SUB_UA="${MSE_CLASHCTL_SUB_UA:-clash-verge/v2.3.1}"
CLASHCTL_BIN_DIR="${CLASHCTL_HOME}/../../bin"
CLASHCTL_STATE_DIR="${CLASHCTL_HOME}/state"
CLASHCTL_CACHE_DIR="${CLASHCTL_HOME}/cache"

case "${CLASHCTL_KERNEL}" in
    mihomo|clash) ;;
    *)
        printf 'unsupported MSE_CLASHCTL_KERNEL: %s\n' "${CLASHCTL_KERNEL}" >&2
        exit 1
        ;;
esac

# Load the vendored downloader after resolving the machine-local install path.
GH_PROXY="${MSE_CLASHCTL_GH_PROXY-${GH_PROXY-https://gh-proxy.org}}"
VERSION_MIHOMO="${MSE_CLASHCTL_MIHOMO_VERSION-${VERSION_MIHOMO:-}}"
VERSION_YQ="${MSE_CLASHCTL_YQ_VERSION-${VERSION_YQ:-}}"
VERSION_SUBCONVERTER="${MSE_CLASHCTL_SUBCONVERTER_VERSION-${VERSION_SUBCONVERTER:-}}"
. "${CLASHCTL_SRC}/scripts/preflight.sh"
valid_required

ARCHIVE_BASE_DIR="${CLASHCTL_CACHE_DIR}"
ZIP_BASE_DIR="${CLASHCTL_CACHE_DIR}"
ZIP_UI="${CLASHCTL_SRC}/archives/dist.zip"
CLASHCTL_CMD_DIR="${CLASHCTL_HOME}/scripts/cmd"

mkdir -p \
    "${CLASHCTL_BIN_DIR}" \
    "${CLASHCTL_STATE_DIR}/profiles" \
    "${CLASHCTL_CACHE_DIR}"

# Program files already live in the repository. Deploy only initializes state.
install -m 644 "${CLASHCTL_SRC}/resources/Country.mmdb" "${CLASHCTL_STATE_DIR}/Country.mmdb"
install -m 644 "${CLASHCTL_SRC}/resources/geosite.dat" "${CLASHCTL_STATE_DIR}/geosite.dat"

# Mutable config is initialized once and never overwritten by deploy.
[ -f "${CLASHCTL_STATE_DIR}/mixin.yaml" ] || \
    install -m 644 "${CLASHCTL_SRC}/resources/mixin.yaml" "${CLASHCTL_STATE_DIR}/mixin.yaml"
[ -f "${CLASHCTL_STATE_DIR}/profiles.yaml" ] || \
    install -m 644 "${CLASHCTL_SRC}/resources/profiles.yaml" "${CLASHCTL_STATE_DIR}/profiles.yaml"
[ -f "${CLASHCTL_STATE_DIR}/config.yaml" ] || : > "${CLASHCTL_STATE_DIR}/config.yaml"
printf 'CLASHCTL_KERNEL=%s\nINIT_TYPE=nohup\nCLASHCTL_SUB_UA=%s\n' \
    "${CLASHCTL_KERNEL}" "${CLASHCTL_SUB_UA}" > "${CLASHCTL_STATE_DIR}/env"

prepare_zip

printf 'CLASHCTL_HOME=%s\n' "${CLASHCTL_HOME}"
printf 'clashctl binaries installed in %s; runtime data preserved in %s\n' \
    "${CLASHCTL_BIN_DIR}" "${CLASHCTL_STATE_DIR}"
