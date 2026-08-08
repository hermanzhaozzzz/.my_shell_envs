#!/usr/bin/env bash

printf '%s\n' \
    'clashctl is managed by ~/.my_shell_envs and cannot uninstall its own source tree.' \
    'Run proxy.off first. Mutable data is under tools/clashctl/state and tools/clashctl/cache.' >&2
exit 1

