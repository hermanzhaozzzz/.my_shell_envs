#!/usr/bin/env bash

clashsub() {
    case "$1" in
    add)
        shift
        sub_add "$@"
        ;;
    del | delete)
        shift
        _sub_del "$@"
        ;;
    list | ls | '')
        shift
        _sub_list "$@"
        ;;
    use)
        shift
        _sub_use "$@"
        ;;
    update)
        shift
        _sub_update "$@"
        ;;
    log)
        shift
        _sub_log "$@"
        ;;
    -h | --help | *)
        sub_help
        ;;
    esac
}

_get_path_by_id() {
    PROFILE_ID=$1 "$BIN_YQ" -e '.profiles[] | select((.id | tostring) == env(PROFILE_ID)) | .path' "$CLASH_PROFILES_META" 2>/dev/null
}

_get_url_by_id() {
    PROFILE_ID=$1 "$BIN_YQ" -e '.profiles[] | select((.id | tostring) == env(PROFILE_ID)) | .url' "$CLASH_PROFILES_META" 2>/dev/null
}

_get_id_by_url() {
    PROFILE_URL=$1 "$BIN_YQ" -e '.profiles[] | select(.url == env(PROFILE_URL)) | (.id | tostring)' "$CLASH_PROFILES_META" 2>/dev/null
}

_logging_sub() {
    printf '%s %s\n' "$(date +"%Y-%m-%d %H:%M:%S")" "$1" >>"$CLASH_PROFILES_LOG"
}

sub_add() {
    local use_after_add=false
    local url=

    while [ $# -gt 0 ]; do
        case "$1" in
        -h | --help)
            cat <<EOF

- 添加订阅
  clashctl sub add <url>

- 添加后立即使用该订阅
  clashctl sub add -u <url>
  clashctl sub add --use <url>

EOF
            return 0
            ;;
        -u | --use)
            use_after_add=true
            ;;
        --)
            shift
            break
            ;;
        -*)
            _errorcat "未知选项：$1"
            return 1
            ;;
        *)
            [ -n "$url" ] && { _errorcat "仅支持一个订阅链接"; return 1; }
            url=$1
            ;;
        esac
        shift
    done

    [ -z "$url" ] && [ $# -gt 0 ] && url=$1
    [ -z "$url" ] && {
        printf '%s' "$(_okcat '✈️ ' '请输入要添加的订阅链接：')"
        read -r url
        [ -z "$url" ] && { _errorcat "订阅链接不能为空"; return 1; }
    }

    local existing_id
    existing_id=$(_get_id_by_url "$url") && {
        [ "$use_after_add" = true ] || {
            _errorcat "该订阅链接已存在：[$existing_id] $url"
            return 1
        }
        _okcat '✈️ ' "订阅已存在，更新并使用：[$existing_id]"
        _sub_update "$existing_id" || return
        local current_id
        current_id=$("$BIN_YQ" '.use // "" | tostring' "$CLASH_PROFILES_META")
        [ "$current_id" = "$existing_id" ] || _sub_use "$existing_id"
        return
    }

    _download_config "$CLASH_CONFIG_TEMP" "$url"
    _valid_config "$CLASH_CONFIG_TEMP" || {
        _errorcat "订阅无效，请检查：
    原始订阅：${CLASH_CONFIG_TEMP}.raw
    转换订阅：$CLASH_CONFIG_TEMP
    转换日志：$BIN_SUBCONVERTER_LOG"
        return 1
    }

    local id
    id=$("$BIN_YQ" '.profiles // [] | (map(.id) | max) // 0 | . + 1' "$CLASH_PROFILES_META")
    local profile_path="${CLASH_PROFILES_DIR}/${id}.yaml"
    /bin/mv "$CLASH_CONFIG_TEMP" "$profile_path"

    PROFILE_ID=$id PROFILE_PATH=$profile_path PROFILE_URL=$url \
        "$BIN_YQ" -i '
            .profiles = (.profiles // []) +
            [{
              "id": (env(PROFILE_ID) | tonumber),
              "path": env(PROFILE_PATH),
              "url": env(PROFILE_URL)
            }]
        ' "$CLASH_PROFILES_META"

    _logging_sub "➕ 已添加订阅：[$id] $url"
    _okcat '🎉' "订阅已添加：[$id] $url"
    [ "$use_after_add" = true ] && _sub_use "$id"
}

_sub_del() {
    local id=$1
    [ -z "$id" ] && {
        printf '%s' "$(_okcat '✈️ ' '请输入要删除的订阅 id：')"
        read -r id
        [ -z "$id" ] && { _errorcat "订阅 id 不能为空"; return 1; }
    }

    local profile_path url use deleting_active=false
    profile_path=$(_get_path_by_id "$id") || _errorcat "订阅 id 不存在，请检查" || return
    url=$(_get_url_by_id "$id")
    use=$("$BIN_YQ" '.use // "" | tostring' "$CLASH_PROFILES_META")

    if [ "$use" = "$id" ]; then
        deleting_active=true
        service_stop || {
            _errorcat "删除失败：无法停止当前代理服务"
            return 1
        }
        service_is_active >/dev/null 2>&1 && {
            _errorcat "删除失败：当前代理服务仍在运行"
            return 1
        }
        unset_system_proxy
    fi

    if [ "$deleting_active" = true ]; then
        PROFILE_ID=$id "$BIN_YQ" -i '
          .use = null |
          del(.profiles[] | select((.id | tostring) == env(PROFILE_ID)))
        ' "$CLASH_PROFILES_META" || return 1
        /bin/rm -f "$CLASH_CONFIG_BASE" "$CLASH_CONFIG_RUNTIME" "$CLASH_CONFIG_TEMP"
    else
        PROFILE_ID=$id "$BIN_YQ" -i 'del(.profiles[] | select((.id | tostring) == env(PROFILE_ID)))' "$CLASH_PROFILES_META" || return 1
    fi
    /bin/rm -f "$profile_path"
    _logging_sub "➖ 已删除订阅：[$id] $url"
    _okcat '🎉' "订阅已删除：[$id] $url"
}

_sub_list() {
    "$BIN_YQ" "$CLASH_PROFILES_META"
}

_sub_snapshot_file() {
    local source_path=$1
    local snapshot_dir=$2
    local snapshot_name=$3

    if [ -e "$source_path" ]; then
        cp -p "$source_path" "$snapshot_dir/$snapshot_name" || return 1
    else
        : >"$snapshot_dir/$snapshot_name.absent" || return 1
    fi
}

_sub_restore_file() {
    local target_path=$1
    local snapshot_dir=$2
    local snapshot_name=$3

    /bin/rm -f "$target_path"
    [ -e "$snapshot_dir/$snapshot_name.absent" ] && return 0
    cp -p "$snapshot_dir/$snapshot_name" "$target_path"
}

_sub_restore_switch() {
    local snapshot_dir=$1
    local was_service_active=$2
    local was_tun_active=$3

    if _is_tun_enabled >/dev/null 2>&1; then
        service_sudo_stop >/dev/null 2>&1 || true
    else
        service_stop >/dev/null 2>&1 || true
    fi

    _sub_restore_file "$CLASH_CONFIG_BASE" "$snapshot_dir" config.yaml || return 1
    _sub_restore_file "$CLASH_CONFIG_RUNTIME" "$snapshot_dir" runtime.yaml || return 1
    _sub_restore_file "$CLASH_PROFILES_META" "$snapshot_dir" profiles.yaml || return 1

    [ "$was_service_active" = true ] || return 0
    if [ "$was_tun_active" = true ]; then
        service_sudo_start >/dev/null 2>&1 || return 1
    else
        service_start >/dev/null 2>&1 || return 1
    fi
    clashctl_wait_proxy_ports 50
}

_sub_use() {
    "$BIN_YQ" -e '.profiles // [] | length == 0' "$CLASH_PROFILES_META" >/dev/null 2>&1 && {
        _errorcat "当前无可用订阅，请先添加订阅"
        return 1
    }

    local id=$1
    [ -z "$id" ] && {
        _sub_list
        printf '%s' "$(_okcat '✈️ ' '请输入要使用的订阅 id：')"
        read -r id
        [ -z "$id" ] && { _errorcat "订阅 id 不能为空"; return 1; }
    }

    local profile_path url snapshot_dir
    local was_service_active=false
    local was_tun_active=false
    profile_path=$(_get_path_by_id "$id") || _errorcat "订阅 id 不存在，请检查" || return
    url=$(_get_url_by_id "$id")

    snapshot_dir=$(mktemp -d "${CLASH_RESOURCES_DIR}/.switch.XXXXXX") || {
        _errorcat "无法创建订阅切换快照"
        return 1
    }
    _sub_snapshot_file "$CLASH_CONFIG_BASE" "$snapshot_dir" config.yaml \
        && _sub_snapshot_file "$CLASH_CONFIG_RUNTIME" "$snapshot_dir" runtime.yaml \
        && _sub_snapshot_file "$CLASH_PROFILES_META" "$snapshot_dir" profiles.yaml || {
            /bin/rm -rf "$snapshot_dir"
            _errorcat "无法保存当前订阅状态"
            return 1
        }

    service_is_active >/dev/null 2>&1 && was_service_active=true
    tunstatus >/dev/null 2>&1 && was_tun_active=true

    if ! cat "$profile_path" >"$CLASH_CONFIG_BASE" \
        || ! _merge_config_restart \
        || ! service_is_active >/dev/null 2>&1 \
        || ! clashctl_wait_proxy_ports 50 \
        || ! PROFILE_ID=$id "$BIN_YQ" -i '.use = (env(PROFILE_ID) | tonumber)' "$CLASH_PROFILES_META"; then
        _sub_restore_switch "$snapshot_dir" "$was_service_active" "$was_tun_active" \
            || _errorcat "订阅切换失败，且旧运行状态未能自动恢复"
        /bin/rm -rf "$snapshot_dir"
        _errorcat "订阅切换失败，已恢复旧配置"
        return 1
    fi

    /bin/rm -rf "$snapshot_dir"
    _logging_sub "🔥 订阅已切换为：[$id] $url"
    _okcat '🔥' '订阅已生效'
}

_sub_update() {
    local arg is_convert=false
    for arg in "$@"; do
        case $arg in
        --auto)
            command -v crontab >/dev/null || _errorcat "未检测到 crontab 命令，请先安装 cron 服务" || return
            crontab -l 2>/dev/null | grep -Fqs "$CLASHCTL_CRON_TAG" || {
                {
                    crontab -l 2>/dev/null | grep -Fv "$CLASHCTL_CRON_TAG"
                    printf '0 0 */2 * * "%s" sub update %s\n' "${BIN_BASE_DIR}/clashctl" "$CLASHCTL_CRON_TAG"
                } | crontab -
            }
            _okcat "已设置定时更新订阅"
            return 0
            ;;
        --convert)
            is_convert=true
            ;;
        esac
    done

    local id=$1
    [ -z "$id" ] && id=$("$BIN_YQ" '.use // 1 | tostring' "$CLASH_PROFILES_META")

    local url profile_path use profile_backup
    url=$(_get_url_by_id "$id") || _errorcat "订阅 id 不存在，请检查" || return
    profile_path=$(_get_path_by_id "$id")
    _okcat "✈️ " "更新订阅：[$id] $url"

    if [ "$is_convert" = true ]; then
        _download_convert_config "$CLASH_CONFIG_TEMP" "$url"
    else
        _download_config "$CLASH_CONFIG_TEMP" "$url"
    fi

    _valid_config "$CLASH_CONFIG_TEMP" || {
        _logging_sub "❌ 订阅更新失败：[$id] $url"
        _errorcat "订阅无效：请检查：
    原始订阅：${CLASH_CONFIG_TEMP}.raw
    转换订阅：$CLASH_CONFIG_TEMP
    转换日志：$BIN_SUBCONVERTER_LOG"
        return 1
    }

    use=$("$BIN_YQ" '.use // "" | tostring' "$CLASH_PROFILES_META")
    if [ "$use" = "$id" ]; then
        profile_backup=$(mktemp "${CLASH_RESOURCES_DIR}/.profile.${id}.XXXXXX") || return 1
        cp -p "$profile_path" "$profile_backup" || {
            /bin/rm -f "$profile_backup"
            return 1
        }
        cat "$CLASH_CONFIG_TEMP" >"$profile_path" || {
            /bin/rm -f "$profile_backup"
            return 1
        }
        if ! _sub_use "$use"; then
            cp -p "$profile_backup" "$profile_path" || _errorcat "旧订阅文件恢复失败"
            /bin/rm -f "$profile_backup"
            _logging_sub "❌ 订阅更新后切换失败：[$id] $url"
            return 1
        fi
        /bin/rm -f "$profile_backup"
        _logging_sub "✅ 订阅更新成功：[$id] $url"
        return 0
    fi

    cat "$CLASH_CONFIG_TEMP" >"$profile_path" || return 1
    _logging_sub "✅ 订阅更新成功：[$id] $url"
    _okcat '订阅已更新'
}

_sub_log() {
    [ $# -gt 0 ] && {
        tail "$@" "$CLASH_PROFILES_LOG"
        return
    }
    tail "$CLASH_PROFILES_LOG"
}

sub_help() {
    cat <<EOF

clashctl sub - 订阅管理工具

Usage:
  clashctl sub COMMAND [OPTIONS]

Commands:
  add <url>       添加订阅
  ls              查看订阅
  del <id>        删除订阅
  use <id>        使用订阅
  update [id]     更新订阅
  log             订阅日志

Global Options:
  -h, --help      显示帮助信息

EOF
}
