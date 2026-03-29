# Author: Hua-nan Herman ZHAO
# E-Mail: hermanzhaozzzz@gmail.com
# Date  : 2025-09-18
# 需要保存为 UTF-8 with BOM!!!


# This repo-managed profile is linked into the user's PowerShell profile path.
if ($global:MsePowerShellProfileLoaded) {
    return
}
$global:MsePowerShellProfileLoaded = $true

# ----------------------------------------------->
# 设置代理信息
# ----------------------------------------------->
$script:MseBootstrapMode = $env:MSE_POWERSHELL_BOOTSTRAP -eq '1'
$script:MseHttpProxy = 'http://127.0.0.1:7890'
$script:MseGitProxy = 'socks5://127.0.0.1:7890'
$script:MseProxyEnabled = $false
# ----------------------------------------------->
# 设置 PATH
# ----------------------------------------------->
$CargoBin = Join-Path $env:USERPROFILE '.cargo\bin'
$MseRepoRoot = Join-Path $env:USERPROFILE '.my_shell_envs'
$env:STARSHIP_CONFIG = Join-Path $MseRepoRoot 'starship\starship.toml'
# ----------------------------------------------->
# 下载 Powershell命令手册
#     man     帮助查询
#     help    帮助查询，同man
# ----------------------------------------------->
# Update-Help Microsoft.PowerShell.*

# ----------------------------------------------->
# 检查scoop是否安装
# ----------------------------------------------->
function Check-Command($cmdname) { return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue) }

function Test-TcpEndpoint([string]$HostName, [int]$Port, [int]$TimeoutMs = 400) {
    $client = [System.Net.Sockets.TcpClient]::new()
    try {
        $asyncResult = $client.BeginConnect($HostName, $Port, $null, $null)
        if (-not $asyncResult.AsyncWaitHandle.WaitOne($TimeoutMs, $false)) {
            return $false
        }

        $null = $client.EndConnect($asyncResult)
        return $true
    }
    catch {
        return $false
    }
    finally {
        $client.Dispose()
    }
}

function Write-BootstrapInfo([string]$Message) {
    if ($script:MseBootstrapMode) {
        Write-Host $Message -ForegroundColor Green
    }
}

function Ensure-PathEntry([string]$PathEntry) {
    if ([string]::IsNullOrWhiteSpace($PathEntry)) {
        return
    }

    if ((($env:PATH -split ';') -notcontains $PathEntry)) {
        $env:PATH = ($env:PATH.TrimEnd(';')) + ';' + $PathEntry
    }
}

function Set-MseProxyEnvironment {
    $script:MseProxyEnabled = $false
    $env:http_proxy = $null
    $env:https_proxy = $null
    $env:HTTP_PROXY = $null
    $env:HTTPS_PROXY = $null

    try {
        $proxyUri = [System.Uri]$script:MseHttpProxy
    }
    catch {
        if ($script:MseBootstrapMode) {
            Write-Warning ("[proxy] 代理地址无效，跳过代理设置: {0}" -f $script:MseHttpProxy)
        }
        return
    }

    if (-not (Test-TcpEndpoint -HostName $proxyUri.Host -Port $proxyUri.Port)) {
        if ($script:MseBootstrapMode) {
            Write-Warning ("[proxy] 本地代理不可用，跳过代理设置: {0}" -f $script:MseHttpProxy)
        }
        return
    }

    $env:http_proxy = $script:MseHttpProxy
    $env:https_proxy = $script:MseHttpProxy
    $env:HTTP_PROXY = $script:MseHttpProxy
    $env:HTTPS_PROXY = $script:MseHttpProxy
    $script:MseProxyEnabled = $true
}

function Ensure-ScoopInstalled {
    if (Check-Command -cmdname 'scoop') {
        return $true
    }

    if (-not $script:MseBootstrapMode) {
        return $false
    }

    Write-Warning "[scoop] 未检测到，开始安装…"
    try {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-RestMethod get.scoop.sh | Invoke-Expression
        Write-BootstrapInfo "[scoop] 安装完成"
        return (Check-Command -cmdname 'scoop')
    }
    catch {
        Write-Warning ("[scoop] 安装失败: {0}" -f $_.Exception.Message)
        return $false
    }
}

function Ensure-ScoopBucket([string]$BucketName) {
    if ([string]::IsNullOrWhiteSpace($BucketName)) {
        return $true
    }

    if (-not (Ensure-ScoopInstalled)) {
        return $false
    }

    try {
        scoop bucket add $BucketName 2>$null | Out-Null
    }
    catch {
        Write-Warning ("[scoop] bucket {0} 准备失败: {1}" -f $BucketName, $_.Exception.Message)
        return $false
    }

    return $true
}

function Ensure-ScoopPackage([string]$CommandName, [string]$PackageName, [string]$BucketName = '') {
    if (Check-Command -cmdname $CommandName) {
        return $true
    }

    if (-not $script:MseBootstrapMode) {
        return $false
    }

    if (-not (Ensure-ScoopInstalled)) {
        return $false
    }

    if ($BucketName -and -not (Ensure-ScoopBucket -BucketName $BucketName)) {
        return $false
    }

    Write-Warning ("[{0}] 未检测到，开始安装…" -f $CommandName)
    try {
        scoop install $PackageName
    }
    catch {
        Write-Warning ("[{0}] 安装失败: {1}" -f $PackageName, $_.Exception.Message)
        return $false
    }

    if (-not (Check-Command -cmdname $CommandName)) {
        Write-Warning ("[{0}] 安装后仍未找到命令: {1}" -f $PackageName, $CommandName)
        return $false
    }

    Write-BootstrapInfo ("[{0}] 安装完成" -f $PackageName)
    return $true
}

function Set-GitProxyIfPossible {
    if (-not $script:MseBootstrapMode) {
        return
    }

    if (-not $script:MseProxyEnabled) {
        return
    }

    if (-not (Check-Command -cmdname 'git')) {
        return
    }

    try {
        $currentHttpProxy = & git config --global --get http.proxy 2>$null
        if ($currentHttpProxy -ne $script:MseGitProxy) {
            & git config --global http.proxy $script:MseGitProxy | Out-Null
        }

        $currentHttpsProxy = & git config --global --get https.proxy 2>$null
        if ($currentHttpsProxy -ne $script:MseGitProxy) {
            & git config --global https.proxy $script:MseGitProxy | Out-Null
        }
    }
    catch {
        Write-Warning ("[git] 代理设置跳过: {0}" -f $_.Exception.Message)
    }
}

# ----------------------------------------------->
# 检查micromamba是否安装
#     https://github.com/mamba-org/micromamba-releases
# ----------------------------------------------->
# 路径定义
$MambaHome          = Join-Path $HOME 'AppData\Local\micromamba'
$MambaExe           = Join-Path $MambaHome 'micromamba.exe'
$MseRepoMicromambaExe = Join-Path $MseRepoRoot 'tools\micromamba\Windows\micromamba-win-64.exe'
$MseBaseEnvFile = Join-Path $MseRepoRoot 'conda_local_env_settings\base.yml'
$Env:MAMBA_ROOT_PREFIX = Join-Path $HOME 'micromamba'

# 目录幂等创建
foreach ($d in @($MambaHome, $Env:MAMBA_ROOT_PREFIX)) {
    if (-not (Test-Path -LiteralPath $d)) {
        New-Item -ItemType Directory -Path $d -Force | Out-Null
    }
}

Set-MseProxyEnvironment
Ensure-PathEntry -PathEntry $CargoBin
Ensure-PathEntry -PathEntry $MambaHome
Set-GitProxyIfPossible

[void](Ensure-ScoopPackage -CommandName 'git' -PackageName 'git')
[void](Ensure-ScoopPackage -CommandName 'gow' -PackageName 'gow')
[void](Ensure-ScoopPackage -CommandName 'subl' -PackageName 'sublime-text' -BucketName 'extras')
[void](Ensure-ScoopPackage -CommandName 'starship' -PackageName 'starship')

if (Check-Command -cmdname 'subl') {
    Set-Alias opena subl
}

function Get-MambaHookScript {
    try {
        return (& $MambaExe shell hook -s powershell | Out-String)
    }
    catch {
        Write-Warning ("[micromamba] 初始化异常: {0}" -f $_.Exception.Message)
        return $null
    }
}

function Invoke-MseInstallScriptWithTlsFallback([string]$Url) {
    try {
        Invoke-WebRequest -UseBasicParsing $Url | Invoke-Expression
        return $true
    }
    catch {
        Write-Warning ("[network] 标准下载失败: {0}" -f $_.Exception.Message)
    }

    $invokeWebRequestCommand = Get-Command Invoke-WebRequest -ErrorAction SilentlyContinue
    if (-not $invokeWebRequestCommand -or -not $invokeWebRequestCommand.Parameters.ContainsKey('SkipCertificateCheck')) {
        return $false
    }

    try {
        Write-Warning "[network] 尝试使用 SkipCertificateCheck 重新下载…"
        Invoke-WebRequest -UseBasicParsing -SkipCertificateCheck $Url | Invoke-Expression
        return $true
    }
    catch {
        Write-Warning ("[network] SkipCertificateCheck 重试失败: {0}" -f $_.Exception.Message)
    }

    $savedHttpProxy = $env:http_proxy
    $savedHttpsProxy = $env:https_proxy

    try {
        Write-Warning "[network] 尝试绕过本地代理并重新下载…"
        $env:http_proxy = $null
        $env:https_proxy = $null
        Invoke-WebRequest -UseBasicParsing -SkipCertificateCheck $Url | Invoke-Expression
        return $true
    }
    catch {
        Write-Warning ("[network] 直连重试失败: {0}" -f $_.Exception.Message)
        return $false
    }
    finally {
        $env:http_proxy = $savedHttpProxy
        $env:https_proxy = $savedHttpsProxy
    }
}

function Install-MicromambaFromLocalExe([string]$SourceExe) {
    if ([string]::IsNullOrWhiteSpace($SourceExe)) {
        return $false
    }

    if (-not (Test-Path -LiteralPath $SourceExe)) {
        Write-Warning ("[micromamba] 本地二进制不存在: {0}" -f $SourceExe)
        return $false
    }

    try {
        Copy-Item -LiteralPath $SourceExe -Destination $MambaExe -Force
        return $true
    }
    catch {
        Write-Warning ("[micromamba] 复制本地二进制失败: {0}" -f $_.Exception.Message)
        return $false
    }
}

function Get-MseMicromambaExePath {
    if (-not [string]::IsNullOrWhiteSpace($env:MSE_MICROMAMBA_EXE_PATH)) {
        return $env:MSE_MICROMAMBA_EXE_PATH
    }

    $userConfiguredPath = [System.Environment]::GetEnvironmentVariable('MSE_MICROMAMBA_EXE_PATH', 'User')
    if (-not [string]::IsNullOrWhiteSpace($userConfiguredPath)) {
        return $userConfiguredPath
    }

    if (Test-Path -LiteralPath $MseRepoMicromambaExe) {
        return $MseRepoMicromambaExe
    }

    return $null
}

function Test-MambaBaseEnvironmentExists {
    return (Test-Path -LiteralPath (Join-Path $Env:MAMBA_ROOT_PREFIX 'conda-meta\history'))
}

function Ensure-MambaBaseEnvironment {
    if (Test-MambaBaseEnvironmentExists) {
        if (-not $script:MseBootstrapMode) {
            return $true
        }
    }

    if (-not $script:MseBootstrapMode) {
        return $false
    }

    if (Test-Path -LiteralPath $MseBaseEnvFile) {
        Write-Warning ("[micromamba] 使用仓库环境文件更新 base: {0}" -f $MseBaseEnvFile)
        Write-Warning ("[micromamba] 如需手动执行，请在 PowerShell 中运行: conda env update -n base -f '{0}' --prune" -f $MseBaseEnvFile)
        & $MambaExe env update -y --prune -r $Env:MAMBA_ROOT_PREFIX -n base -f $MseBaseEnvFile 2>$null | Out-Null
        if ($LASTEXITCODE -eq 0 -and (Test-MambaBaseEnvironmentExists)) {
            return $true
        }

        Write-Warning ("[micromamba] base.yml 更新失败，退出码: {0}" -f $LASTEXITCODE)
    }

    Write-Warning "[micromamba] 回退到最小 base 初始化（python）…"
    & $MambaExe install -y -r $Env:MAMBA_ROOT_PREFIX -n base python 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Warning ("[micromamba] base 环境准备失败，退出码: {0}" -f $LASTEXITCODE)
        return $false
    }

    if (Test-MambaBaseEnvironmentExists) {
        return $true
    }

    Write-Warning "[micromamba] base 环境初始化后仍不完整"
    return $false
}

function Install-Micromamba {
    if (-not $script:MseBootstrapMode) {
        return $false
    }

    if (Install-MicromambaFromLocalExe -SourceExe (Get-MseMicromambaExePath)) {
        Write-BootstrapInfo "[micromamba] 已从本地二进制完成安装"
        return $true
    }

    Write-Host '[micromamba] 未找到，开始安装…' -ForegroundColor Yellow
    if (-not (Invoke-MseInstallScriptWithTlsFallback -Url 'https://micromamba.pfx.dev/install.ps1')) {
        Write-Warning "[micromamba] 安装脚本执行失败，所有下载重试都未成功"
        Write-Warning ("[micromamba] 可手动下载 micromamba.exe 后设置环境变量 MSE_MICROMAMBA_EXE_PATH，或把仓库备份放到: {0}" -f $MseRepoMicromambaExe)
        Write-Warning ("[micromamba] 也可以直接放到最终安装位置: {0}" -f $MambaExe)
        return $false
    }

    if (-not (Test-Path -LiteralPath $MambaExe)) {
        Start-Sleep -Seconds 1
    }

    if (-not (Test-Path -LiteralPath $MambaExe)) {
        Write-Warning "[micromamba] 安装后仍未找到可执行文件"
        return $false
    }

    return (Ensure-MambaBaseEnvironment)
}

if ((Test-Path -LiteralPath $MambaExe) -or (Install-Micromamba)) {
    [void](Ensure-MambaBaseEnvironment)
    $mambaHookScript = Get-MambaHookScript
    if (-not [string]::IsNullOrWhiteSpace($mambaHookScript)) {
        Invoke-Expression $mambaHookScript
    }
}

# 方便习惯：别名
if (Test-Path -LiteralPath $MambaExe) {
    Set-Alias conda micromamba -Scope Global
    Set-Alias mamba micromamba -Scope Global
}
# --- end micromamba block ---

if (Check-Command -cmdname 'starship') {
    Invoke-Expression (& starship init powershell)
}

# ----------------------------------------------->
# 引入Emacs快捷键设置
#        同MacOS中的终端快捷键
#        ctrl-d 退出PowerShell
#        ctrl-a 跳转到行首
#        ctrl-d 跳转到行末
#        powershell内置的PSReadline模块提供的功能
# ----------------------------------------------->
if (-not $script:MseBootstrapMode -and (Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue)) {
    Set-PSReadLineOption -EditMode Emacs
    Set-PSReadLineKeyHandler -Chord Ctrl+a -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::BeginningOfLine() }
    Set-PSReadLineKeyHandler -Chord Ctrl+e -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine() }
    Set-PSReadLineKeyHandler -Chord Home -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::BeginningOfLine() }
    Set-PSReadLineKeyHandler -Chord End -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine() }

    # ----------------------------------------------->
    #  Tab           自动补全
    #        设置补全风格为菜单选择样式(按tab补全弹出菜单)
    # ----------------------------------------------->
    Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

    # ----------------------------------------------->
    #  历史自动补全
    #        - ↑                       历史自动补全，向上查找
    #        - ↓                       历史自动补全，向下查找
    # ----------------------------------------------->
    Set-PSReadLineKeyHandler -Key UpArrow -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::HistorySearchBackward()
        [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
    }
    Set-PSReadLineKeyHandler -Key DownArrow -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::HistorySearchForward()
        [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
    }
}

# ----------------------------------------------->
# 创建ls命令（重新定义）
# ----------------------------------------------->
function getFileName { Get-ChildItem -Name }
Set-Alias -Name ls -Value getFileName -Force -Option AllScope

# 因为ls是Windows PowerShell中的默认别名，因此必须先删除再创建，
# 所以先Remove-Item再Set-Alias或New-Alias。
# 以后每次在打开PowerShell会话框的时候其会先读取此文件中的内容。

# ----------------------------------------------->
# 创建ll命令
# ----------------------------------------------->
Set-Alias ll Get-ChildItem
# ----------------------------------------------->
# 创建open命令
# ----------------------------------------------->
Set-Alias open explorer


# ----------------------------------------------->
# ssh-copy-id
# ----------------------------------------------->
function ssh-copy-id([string]$userAtMachine, $args){   
    $publicKey = "$ENV:USERPROFILE" + "/.ssh/id_rsa.pub"
    if (!(Test-Path "$publicKey")){
        Write-Error "ERROR: failed to open ID file '$publicKey': No such file"            
    }
    else {
        & cat "$publicKey" | ssh $args $userAtMachine "umask 077; test -d .ssh || mkdir .ssh ; cat >> .ssh/authorized_keys || exit 1"      
    }
}



# https://zhuanlan.zhihu.com/p/537991323
# https://zhuanlan.zhihu.com/p/137251716





