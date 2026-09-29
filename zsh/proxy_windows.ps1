# Read-only discovery for WSL: emit group|host|port, with no credentials or URLs.
$ErrorActionPreference = 'SilentlyContinue'
$settings = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
if ($settings.ProxyEnable -eq 1 -and $settings.ProxyServer) {
    foreach ($entry in ($settings.ProxyServer -split ';')) {
        $endpoint = ($entry -replace '^\s*(http|https|socks)=', '').Trim()
        if ($endpoint -match '^(?:\w+://)?(\[[0-9a-fA-F:]+\]|[a-zA-Z0-9._-]+):(\d+)$') {
            'Windows-system|{0}|{1}' -f $Matches[1], $Matches[2]
        }
    }
}
$clients = @{}
Get-Process | Where-Object {
    $_.ProcessName -match 'clash|mihomo|surge|sing-box|singbox|v2ray|xray|shadowsocks|ss-local|trojan|hysteria|nekoray|naive'
} | ForEach-Object { $clients[$_.Id] = $_.ProcessName }
Get-NetTCPConnection -State Listen | Sort-Object OwningProcess, LocalPort | ForEach-Object {
    if ($clients.ContainsKey([int]$_.OwningProcess)) {
        $address = $_.LocalAddress
        if ($address -eq '0.0.0.0' -or $address -eq '::') { $address = '127.0.0.1' }
        elseif ($address.Contains(':')) { $address = '[' + $address + ']' }
        'Windows-process-{0}-{1}|{2}|{3}' -f $clients[[int]$_.OwningProcess], $_.OwningProcess, $address, $_.LocalPort
    }
}
