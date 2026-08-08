#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
exec "${SCRIPT_DIR}/mse-deploy.sh" "$@"

