# Author: Hua-nan Herman ZHAO
# E-Mail: hermanzhaozzzz@gmail.com
# Date  : 2025-09-18
# 需要保存为 UTF-8 with BOM!!!
# 暂时micromamba只支持64位windows系统，不支持arm windows系统，所以会报warning
# 自动刷新 PATH
# $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","User") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","Machine")
# ----------------------------------------------->
# 设置代理信息
# ----------------------------------------------->

$env:http_proxy = "http://127.0.0.1:7890"
$env:https_proxy = "http://127.0.0.1:7890"
git config --global http.proxy 'socks5://127.0.0.1:7890' 
git config --global https.proxy 'socks5://127.0.0.1:7890'

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

if (Check-Command -cmdname 'scoop') {
    Write-Host "[scoop] 已安装" -ForegroundColor Green
}
else {
    Write-Warning "[scoop] 未检测到，开始安装…"
    try {
        # 确保允许执行本地脚本（仅限当前用户）
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        # 安装 scoop（官方推荐）
        Invoke-RestMethod get.scoop.sh | Invoke-Expression
        Write-Host "[scoop] 安装完成" -ForegroundColor Green
		scoop bucket add extras
    }
    catch {
        Write-Error ("[scoop] 安装失败: {0}" -f $_.Exception.Message)
    }
}

# ----------------------------------------------->
# 检查git是否安装
# ----------------------------------------------->
if (Check-Command -cmdname 'git')
{}
else {
    "Find no git!"
    scoop install git
}

# ----------------------------------------------->
# 检查gow是否安装
# ----------------------------------------------->
if (Check-Command -cmdname 'gow')
{}
else {
    "Find no gow!"
    scoop install gow
}

# ----------------------------------------------->
# 检查subl是否安装
# ----------------------------------------------->
if (Check-Command -cmdname 'subl')
{}
else {
    "Find no subl!"
    scoop install sublime-text
}
Set-Alias opena subl
# ----------------------------------------------->
# 检查starship是否安装
#     https://github.com/starship/starship
# ----------------------------------------------->
if (Check-Command -cmdname 'starship')
{}
else {
    "Find no starship!"
    scoop install starship
}

Invoke-Expression (&starship init powershell)

# ----------------------------------------------->
# 检查micromamba是否安装
#     https://github.com/mamba-org/micromamba-releases
# ----------------------------------------------->
# 路径定义
$MambaHome          = Join-Path $HOME 'AppData\Local\micromamba'
$MambaExe           = Join-Path $MambaHome 'micromamba.exe'
$Env:MAMBA_ROOT_PREFIX = Join-Path $HOME 'micromamba'

# 目录幂等创建
foreach ($d in @($MambaHome, $Env:MAMBA_ROOT_PREFIX)) {
    if (-not (Test-Path -LiteralPath $d)) {
        New-Item -ItemType Directory -Path $d -Force | Out-Null
    }
}

# 将 micromamba 目录添加进当前会话 PATH（去重）
if ((($env:PATH -split ';') -notcontains $MambaHome)) {
    $env:PATH = ($env:PATH.TrimEnd(';')) + ';' + $MambaHome
}

function Invoke-MambaHook {
    try {
        # 用 --prefix 兼容性更好；捕获输出避免空串
        $hook = & $MambaExe 'shell' 'hook' '-s' 'powershell' '--prefix' $Env:MAMBA_ROOT_PREFIX 2>$null
        if ($LASTEXITCODE -eq 0 -and $hook -and $hook.Trim().Length -gt 0) {
            Invoke-Expression $hook
        } else {
            Write-Warning '[micromamba] shell hook 无输出或返回码非0，跳过初始化。'
        }
    } catch {
        Write-Warning ("[micromamba] 初始化异常: {0}" -f $_.Exception.Message)
    }
}

if (Test-Path -LiteralPath $MambaExe) {
    # 已安装：直接初始化
    Invoke-MambaHook
} else {
    Write-Host '[micromamba] 未找到，开始安装…' -ForegroundColor Yellow
    try {
        # 官方安装脚本
        iwr -UseBasicParsing 'https://micromamba.pfx.dev/install.ps1' | iex
    } catch {
        Write-Error ("[micromamba] 安装脚本执行失败: {0}" -f $_.Exception.Message)
        return
    }

    # 重新定位可执行文件（有些版本会放到同一路径）
    if (-not (Test-Path -LiteralPath $MambaExe)) {
        Start-Sleep -Seconds 1
    }
    if (Test-Path -LiteralPath $MambaExe) {
        # 可选：确保 base 有 python
        & $MambaExe create -y -n base python 2>$null | Out-Null
        Invoke-MambaHook
    } else {
        Write-Error "[micromamba] 安装后仍未找到: $MambaExe"
    }
}

# 方便习惯：别名
Set-Alias conda micromamba -Scope Global
Set-Alias mamba micromamba -Scope Global
# --- end micromamba block ---

# ----------------------------------------------->
# 引入Emacs快捷键设置
#        同MacOS中的终端快捷键
#        ctrl-d 退出PowerShell
#        ctrl-a 跳转到行首
#        ctrl-d 跳转到行末
#        powershell内置的PSReadline模块提供的功能
# ----------------------------------------------->
Set-PSReadLineOption -EditMode Emacs

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

# ----------------------------------------------->
# 创建ls命令（重新定义）
# ----------------------------------------------->
function getFileName { Get-ChildItem -Name }
Remove-Item alias:\ls
Set-Alias ls  getFileName

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





