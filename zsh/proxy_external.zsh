# External proxy discovery for macOS and WSL. No fixed ports or shell overrides.
_mse_proxy_is_external() {
    [[ "${_OS}" == macOS || "${_OS}" == WSL ]] &&
        [[ "$(_mse_proxy_mode_setting)" == clash ]]
}

# Records: group|host|port. Startup also retains the declared system protocol.
_mse_proxy_macos_candidates() {
    local system_records="" process_records=""
    system_records="$(scutil --proxy 2>/dev/null | awk -v startup="${1:-}" '
        /__SCOPED__|__SUPPLEMENTAL__/ { exit }
        $2 == ":" { values[$1]=$3 }
        END {
            split("HTTP HTTPS SOCKS", protocols, " ")
            for (i=1; i<=3; i++) {
                p=protocols[i]
                if (values[p "Enable"] == 1 && values[p "Proxy"] != "")
                    print "macOS-system|" values[p "Proxy"] "|" values[p "Port"] (startup == "system" ? "|" p : "")
            }
        }
        ')"
    process_records="$(lsof -nP -iTCP -sTCP:LISTEN -Fpcnt 2>/dev/null | awk '
        /^p/ { pid=substr($0,2); client=0; order++ }
        /^c/ { name=substr($0,2); client=(tolower(name) ~ /clash|mihomo|surge|sing-box|singbox|v2ray|xray|shadowsocks|ss-local|trojan|hysteria|nekoray|naive/) }
        /^t/ { family=substr($0,2) }
        /^n/ && client {
            endpoint=substr($0,2); port=endpoint; sub(/^.*:/,"",port)
            host=endpoint; sub(/:[^:]*$/,"",host)
            if (host == "*") host=(family == "IPv6" ? "[::1]" : "127.0.0.1")
            if (host == "0.0.0.0") host="127.0.0.1"
            if (host == "[::]" || host == "::") host="[::1]"
            print order "|macOS-process-" name "-" pid "|" host "|" port
        }' | sort -t '|' -k1,1n -k4,4n | cut -d '|' -f2-)"
    # Keep client order, but check lower ports before ephemeral helper listeners.
    # This avoids hitting Surge helper services first on every rediscovery.
    # Attribute system endpoints to their listener owner before pairing protocols.
    # Include the same process's other listeners even when only HTTP is enabled
    # in System Settings; never borrow SOCKS from a different running client.
    printf '%s\n' "$system_records" "$process_records" | awk -F'|' '
        function normalized(host) {
            gsub(/[][]/, "", host)
            return host == "localhost" ? "127.0.0.1" : host
        }
        NF >= 3 { rows[++count]=$0; groups[count]=$1; hosts[count]=$2; ports[count]=$3; protocols[count]=$4 }
        END {
            for (i=1; i<=count; i++) {
                if (groups[i] != "macOS-system") continue
                owner=""
                for (j=1; j<=count; j++) {
                    if (groups[j] == "macOS-system") continue
                    if (normalized(hosts[i]) == normalized(hosts[j]) && ports[i] == ports[j]) {
                        owner=groups[j]; hosts[i]=hosts[j]; break
                    }
                }
                group=owner
                if (group != "") sub(/^macOS-process-/, "macOS-system-", group)
                else group="macOS-system-" normalized(hosts[i]) "-" ports[i]
                print group "|" hosts[i] "|" ports[i] (protocols[i] != "" ? "|" protocols[i] : "")
                if (owner != "") system_groups[owner]=group
            }
            for (i=1; i<=count; i++) {
                if (groups[i] == "macOS-system") continue
                if (groups[i] in system_groups)
                    print system_groups[groups[i]] "|" hosts[i] "|" ports[i]
                print rows[i]
            }
        }'
}

_mse_proxy_windows_candidates() {
    local powershell="$(command -v powershell.exe 2>/dev/null)"
    local script="${MSE_REPO_ROOT}/zsh/proxy_windows.ps1"
    # Windows PATH import can be disabled while WSL interop remains available.
    if [[ -z "$powershell" && -x /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe ]]; then
        powershell=/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
    fi
    [[ -n "$powershell" ]] || return 1
    script="$(wslpath -w "$script" 2>/dev/null)" || return 1
    _mse_proxy_run_with_timeout 10 "$powershell" -NoLogo -NoProfile -NonInteractive \
        -ExecutionPolicy Bypass -File "$script" 2>/dev/null | tr -d '\r'
}

_mse_proxy_wsl_candidates() {
    _mse_proxy_windows_candidates
    # Also support clients running inside the WSL distribution.
    ss -H -ltnp 2>/dev/null | awk '
        /clash|mihomo|surge|sing-box|singbox|v2ray|xray|shadowsocks|ss-local|trojan|hysteria|nekoray|naive/ {
            endpoint=$4; port=endpoint; sub(/^.*:/,"",port)
            host=endpoint; sub(/:[^:]*$/,"",host)
            if (host == "*" || host == "0.0.0.0") host="127.0.0.1"
            if (host == "[::]") host="[::1]"
            process=$0; sub(/^.*users:\(\(/,"",process); sub(/,fd=.*$/,"",process)
            gsub(/[|[:space:]]/,"",process)
            print "WSL-process-" process "|" host "|" port
        }'
}

_mse_proxy_external_candidates() {
    case "${_OS}" in
        macOS) _mse_proxy_macos_candidates ;;
        WSL) _mse_proxy_wsl_candidates ;;
    esac
}

_mse_proxy_external_hosts() {
    local host="$1" group="$2" gateway=""
    if [[ "${_OS}" == WSL && "$group" == Windows-* ]]; then
        case "$host" in
            localhost|127.*|::1|'[::1]'|0.0.0.0|'*'|'[::]')
                printf '%s\n' 127.0.0.1 '[::1]'
                gateway="$(ip -4 route show default 2>/dev/null | awk '/default/ {print $3; exit}')"
                [[ -n "$gateway" ]] && printf '%s\n' "$gateway"
                return 0
                ;;
        esac
    fi
    case "$host" in
        localhost) printf '%s\n' 127.0.0.1 '[::1]' ;;
        0.0.0.0|'*') printf '%s\n' 127.0.0.1 ;;
        ::|'[::]') printf '%s\n' '[::1]' ;;
        *:*) printf '[%s]\n' "${${host#\[}%\]}" ;;
        *) printf '%s\n' "$host" ;;
    esac
}

_mse_proxy_external_probe() {
    local protocol="$1" host="$2" port="$3" code=""
    # Explicit --proxy and --noproxy prevent inherited settings bypassing the probe.
    # HTTP must accept CONNECT; a web dashboard returning 200 to GET is not a proxy.
    if [[ "$protocol" == http ]]; then
        code="$(curl -q -s -o /dev/null -w '%{http_connect} %{http_code}' --noproxy '' \
            --proxy "http://${host}:${port}" --connect-timeout 1 --max-time 2 \
            https://www.example.com/ 2>/dev/null)" || return 1
        [[ "$code" == 200\ [1-5][0-9][0-9] && "$code" != '200 407' ]]
    else
        code="$(curl -q -s -o /dev/null -w '%{http_code}' --noproxy '' \
            --proxy "socks5h://${host}:${port}" --connect-timeout 1 --max-time 2 \
            http://www.example.com/ 2>/dev/null)" || return 1
        [[ "$code" == [1-5][0-9][0-9] ]]
    fi
}

_mse_proxy_sync_external_ports() {
    local records="" record="" group="" host="" port="" candidate="" key=""
    local http_host="" http_port="" socks_host="" socks_port=""
    local startup="${1:-}" protocol=""
    local -a groups=() rows=() hosts=()
    local -A seen=()

    _mse_proxy_is_external || return 1
    unset MSE_PROXY_PORT MSE_PROXY_SOCKS_PORT MSE_PROXY_SOCKS_HOST MSE_PROXY_SOURCE
    export MSE_PROXY_HOST=127.0.0.1
    if [[ "$startup" == system ]]; then
        # macOS startup adopts explicit system settings without network traffic.
        records="$(_mse_proxy_macos_candidates system)"
    else
        command -v curl >/dev/null 2>&1 || {
            echo 'proxy: curl is required for automatic proxy detection' >&2
            return 1
        }
        records="$(_mse_proxy_external_candidates)"
    fi
    rows=("${(@f)records}")
    for record in "${rows[@]}"; do
        group="${record%%|*}"
        [[ -n "$group" && "${groups[(Ie)$group]}" == 0 ]] && groups+=("$group")
    done
    # Keep protocols within one system configuration or one client process.
    for group in "${groups[@]}"; do
        http_host="" http_port="" socks_host="" socks_port=""
        for record in "${rows[@]}"; do
            [[ "${record%%|*}" == "$group" ]] || continue
            record="${record#*|}"
            host="${record%%|*}" port="${record#*|}"
            protocol="${port#*|}" port="${port%%|*}"
            if [[ "$startup" == system && "$protocol" != (HTTP|HTTPS|SOCKS) ]]; then
                continue
            fi
            [[ "$port" == <-> && ${#port} -le 5 ]] || continue
            (( port > 0 && port <= 65535 )) || continue
            [[ -n "$host" && "$host" != *[^a-zA-Z0-9.:[\]_-]* ]] || continue
            if [[ "$startup" == system && "$host" == localhost ]]; then
                hosts=(localhost)
            else
                hosts=("${(@f)$(_mse_proxy_external_hosts "$host" "$group")}")
            fi
            for candidate in "${hosts[@]}"; do
                key="${group}|${candidate}|${port}|${startup:+$protocol}"
                [[ -n "${seen[$key]:-}" ]] && continue
                seen[$key]=1
                if [[ "$startup" == system ]]; then
                    case "$protocol" in
                        HTTP|HTTPS)
                            if [[ -z "$http_port" ]]; then
                                http_host="$candidate" http_port="$port"
                            fi
                            ;;
                        SOCKS)
                            if [[ -z "$socks_port" ]]; then
                                socks_host="$candidate" socks_port="$port"
                            fi
                            ;;
                    esac
                else
                    if [[ -z "$http_port" ]] && _mse_proxy_external_probe http "$candidate" "$port"; then
                        http_host="$candidate" http_port="$port"
                    fi
                    if [[ -z "$socks_port" ]] && _mse_proxy_external_probe socks "$candidate" "$port"; then
                        socks_host="$candidate" socks_port="$port"
                    fi
                fi
                [[ -n "$http_port" && -n "$socks_port" ]] && break
            done
            [[ -n "$http_port" && -n "$socks_port" ]] && break
        done
        if [[ -n "$http_port" || -n "$socks_port" ]]; then
            export MSE_PROXY_HOST="${http_host:-$socks_host}"
            export MSE_PROXY_PORT="$http_port"
            export MSE_PROXY_SOCKS_HOST="$socks_host"
            export MSE_PROXY_SOCKS_PORT="$socks_port"
            export MSE_PROXY_SOURCE="$group"
            return 0
        fi
    done
    [[ "$startup" == system ]] && return 1
    echo 'proxy: no reachable HTTP/SOCKS proxy detected; start the client and enable its system proxy or local proxy listener, then rerun proxy.on' >&2
    [[ "${_OS}" == WSL ]] && echo 'proxy: WSL NAT requires a Windows listener reachable from WSL (LAN access/firewall); mirrored networking can use localhost' >&2
    return 1
}
