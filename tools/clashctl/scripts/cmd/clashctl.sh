#!/usr/bin/env bash

_CLASHCTL_RESOLVED_HOME="$(CDPATH= cd -- "$CLASHCTL_HOME" && pwd -P)" || {
    printf 'clashctl: cannot resolve CLASHCTL_HOME: %s\n' "$CLASHCTL_HOME" >&2
    return 1 2>/dev/null || exit 1
}
export CLASHCTL_HOME="$_CLASHCTL_RESOLVED_HOME"
unset _CLASHCTL_RESOLVED_HOME

. "$CLASHCTL_HOME"/.env
[ -f "$CLASHCTL_HOME/state/env" ] && . "$CLASHCTL_HOME/state/env"

for lib_file in "$CLASHCTL_HOME"/scripts/lib/*.sh; do
    . "$lib_file"
done

for cmd_file in "$CLASHCTL_HOME"/scripts/cmd/*.sh; do
    case "$cmd_file" in *clashctl.*) continue ;; esac
    . "$cmd_file"
done

clashctl() {
    local sub_cmd
    sub_cmd=${1:-help}
    shift

    case $sub_cmd in
    -h | --help | help) sub_cmd=help ;;
    add)
        clashsub add --use "$@"
        return
        ;;
    del | delete)
        clashsub del "$@"
        return
        ;;
    ls | list | use | update)
        clashsub "$sub_cmd" "$@"
        return
        ;;
    esac

    local target="clash${sub_cmd}"
    declare -F "$target" >&/dev/null || {
        _failcat "Unknown subcommand: $target"
        _failcat "Use 'clashctl help' for usage information."
        return
    }
    "$target" "$@"
}
