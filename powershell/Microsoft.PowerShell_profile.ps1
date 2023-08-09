# Author: Hua-nan Herman ZHAO
# E-Mail: hermanzhaozzzz@gmail.com

# ----------------------------------------------->
# 设置代理信息
# ----------------------------------------------->

$env:http_proxy="http://127.0.0.1:1080"
$env:https_proxy="http://127.0.0.1:1080"
git config --global http.proxy 'socks5://127.0.0.1:1080' 
git config --global https.proxy 'socks5://127.0.0.1:1080'

# ----------------------------------------------->
# 下载 Powershell命令手册
#     man     帮助查询
#     help    帮助查询，同man
# ----------------------------------------------->
Update-Help Microsoft.PowerShell.*

# ----------------------------------------------->
# 检查scoop是否安装
# ----------------------------------------------->
function Check-Command($cmdname){return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)}

if (Check-Command -cmdname 'scoop')
{}
else
{
     "Find no scoop!"
}

# ----------------------------------------------->
# 检查git是否安装
# ----------------------------------------------->
if (Check-Command -cmdname 'git')
{}
else
{
	"Find no git!"
	scoop install git
}

# ----------------------------------------------->
# 检查gow是否安装
# ----------------------------------------------->
if (Check-Command -cmdname 'gow')
{}
else
{
	"Find no gow!"
	scoop install gow
}

# ----------------------------------------------->
# 检查subl是否安装
# ----------------------------------------------->
if (Check-Command -cmdname 'subl')
{}
else
{
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
else
{
	"Find no starship!"
	scoop install starship
}

Invoke-Expression (&starship init powershell)

# ----------------------------------------------->
# 检查micromamba是否安装
#     https://github.com/mamba-org/micromamba-releases
# ----------------------------------------------->
$Env:PATH += -Join(";", $HOME, "\AppData\Local\micromamba")

if (Check-Command -cmdname 'micromamba')
{
	#region mamba initialize
	# !! Contents within this block are managed by 'mamba shell init' !!
	$Env:MAMBA_ROOT_PREFIX = -Join($HOME, "\micromamba")
	$Env:MAMBA_EXE = -Join($HOME, "\AppData\Local\micromamba\micromamba.exe")
	$MambaModuleArgs = @{}
	(& $Env:MAMBA_EXE 'shell' 'hook' -s 'powershell' -p $Env:MAMBA_ROOT_PREFIX) | Out-String | Invoke-Expression
	#endregion
}
else
{
	"Find no micromamba!"
	Invoke-Expression ((Invoke-WebRequest -Uri https://micromamba.pfx.dev/install.ps1).Content)
}


Set-Alias conda micromamba
Set-Alias mamba micromamba

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
function getFileName{Get-ChildItem -Name}
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





# https://zhuanlan.zhihu.com/p/537991323
# https://zhuanlan.zhihu.com/p/137251716





