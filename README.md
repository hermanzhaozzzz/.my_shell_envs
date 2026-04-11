# My Shell Env (MSE)

[简体中文](README.md) | [English](docs/README.en.md)

这个仓库用来快速搭一套顺手的终端环境，主要包括：

- 部署一套可直接用的 `zsh` / `vim` / `neovim` / `micromamba` 环境
- 管理常用 CLI 工具和若干辅助脚本
- 在 Slurm 集群上提供一套可复用的代理工作流

平时最常用的命令只有两个：

```shell
./mse deploy
./mse update
```

## 快速开始

### 前置依赖

在 Linux / macOS / WSL 上，运行 `./mse deploy` 之前请先确认系统里已经有：

- `git`
- `zsh`
- 基本的 C 编译环境

例如在常见 Debian / Ubuntu 环境中：

```shell
sudo apt update
sudo apt install -y git zsh build-essential pkg-config
```

`mse deploy` 会继续处理这些内容：

- `oh-my-zsh`
- 常用 zsh 插件
- `micromamba`
- `vim` / `neovim`
- repo-managed CLI：`eza`、`bat`、`rg`
- 可选的 cluster proxy 工具：`autossh`、`proxychains-ng`

### Linux / macOS / WSL

普通使用：

```shell
cd "$HOME"
git clone https://github.com/hermanzhaozzzz/.my_shell_envs.git
cd ~/.my_shell_envs
./mse deploy
```

如果你要交互式选择步骤：

```shell
./mse deploy --interactive
```

如果你就是想直接用仓库里的 demo `zprofile`：

```shell
./mse deploy --use-zprofile-template
```

如果你是仓库维护者，或者希望相关仓库都走 SSH：

```shell
cd "$HOME"
git clone git@github.com:hermanzhaozzzz/.my_shell_envs.git
cd ~/.my_shell_envs
./mse deploy --ssh
```

`fast` 和 `interactive` 的区别很简单：

- `fast`：按默认 step 直接部署，适合新机器或你已经接受默认配置
- `interactive`：逐步选择模块，适合你只想装一部分内容

`--use-zprofile-template` 只在你明确想直接使用仓库里的 demo `zprofile` 时再加。`mse` 默认不会改你的 `~/.zprofile`。

### Windows

Windows 的主路径是 PowerShell 配合 `git-bash`：

```powershell
cd $HOME
git clone https://github.com/hermanzhaozzzz/.my_shell_envs.git
cd ~/.my_shell_envs
git-bash ./mse deploy
```

后续更新：

```powershell
git-bash ./mse update
```

## `mse` 怎么工作

### `deploy`

`./mse deploy` 会在当前机器上安装或接入默认工具，并把公共 shell 配置链接到这个仓库。常见动作包括：

- 链接 `~/.zshrc`
- 安装或接入 `oh-my-zsh` 和插件
- 安装 `micromamba`
- 处理 `vim` / `neovim`
- 构建 repo-managed CLI 工具
- 按 step 安装额外模块

部署过程中会尝试 `chsh -s "$(which zsh)"`。如果你不想现在改默认 shell，可以在密码提示时直接回车并跳过。

### `update`

`./mse update` 会先更新仓库，再按你上一次保存的配置重新执行部署。它不会再次要求你修改默认 shell。

### `.mse-install.env`

仓库根目录下的 `.mse-install.env` 会记录最近一次成功执行的部署参数和 step 开关，例如：

```shell
MSE_GIT_METHOD='ssh'
MSE_DEPLOY_MODE='fast'
MSE_USE_ZPROFILE_TEMPLATE='false'
MSE_STEP_NVIM='true'
MSE_STEP_CODE_NOTIFY='true'
MSE_STEP_CLUSTER_PROXY_TOOLS='true'
```

`mse update` 会优先复用 `.mse-install.env` 里已经保存的选择，所以它和一次全新的 `mse deploy --fast` 可能不完全一样。

你有两种方式改默认行为：

- 重新执行 `mse deploy --interactive`
- 直接修改 `.mse-install.env`

## 个人配置

### `~/.zprofile` 和 `~/.zshrc`

这两个文件分工如下：

- `~/.zprofile`：放你自己的机器相关变量、PATH、代理参数、私有 token
- `~/.zshrc`：由本仓库统一管理公共交互逻辑

不要在自己的 `~/.zprofile` 里重新定义仓库已经提供的命令，尤其是 `proxy.on` / `proxy.off`。这些命令现在统一由仓库里的 `zsh/zshrc` 提供。

zsh 常见加载顺序：

```text
.zshenv -> .zprofile -> .zshrc -> .zlogin -> .zlogout
```

各文件职责：

- `~/.zshenv`：所有 zsh 进程都会读，尽量少放东西
- `~/.zprofile`：登录 shell 会先读，适合放 PATH、代理端口、主机相关变量
- `~/.zshrc`：交互式 shell 会读，你平时开终端最常接触的是它
- `~/.zlogin`：登录 shell 的收尾阶段才读，大多数时候用不上
- `~/.zlogout`：退出登录 shell 时才读

- 机器相关、个人相关的设置放 `~/.zprofile`
- 公共 alias、函数、插件和交互逻辑放仓库里的 `zsh/zshrc`

### 可选变量示例

下面这些都不是必须项。只有在你想覆盖默认行为时，才需要写进 `~/.zprofile`。

如果你什么都不写，大多数功能也能正常工作，默认值已经在仓库里的 `zsh/zshrc` 中提供。

```shell
export MSE_ZSH_THEME="fino"
export MSE_ZSH_PLUGINS="git z zsh-syntax-highlighting zsh-autosuggestions"
export MSE_MAMBA_AUTO_ACTIVATE_BASE=false
export MSE_SLURM_NODE_PROXY_AUTO_ENABLE=false
export MSE_PROXY_PORT=8234
```

变量说明：

- `MSE_ZSH_THEME`：覆盖默认 Oh My Zsh 主题
- `MSE_ZSH_PLUGINS`：整体覆盖默认插件列表
- `MSE_MAMBA_AUTO_ACTIVATE_BASE=true|false`：是否在新 shell 中自动 `micromamba activate base`
- `MSE_SLURM_NODE_PROXY_AUTO_ENABLE=true|false`：是否在 Slurm 计算节点加载 `zshrc` 时自动尝试启用代理
- `MSE_PROXY_PORT=<port>`：代理端口，默认是 `8234`
- `MSE_PROXY_HOST=<host>`：默认 `127.0.0.1`
- `MSE_PROXY_DIRECT_HOSTS="<host1> <host2>"`：额外按 login/direct 处理的主机名
- `MSE_PROXY_FORCE_MODE=compute|direct`：手动覆盖代理模式判断
- `MSE_PROXY_UPSTREAM_HOST=<host>`：在计算节点无法自动推断上游 login 节点时手动指定

### 一个最小可用的 `~/.zprofile`

```shell
export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export MSE_MAMBA_AUTO_ACTIVATE_BASE=false
export MSE_SLURM_NODE_PROXY_AUTO_ENABLE=false
export MSE_PROXY_PORT=8234
export MSE_PROXY_DIRECT_HOSTS="c55b01n08"

[ -f "$HOME/.zprofile.private" ] && source "$HOME/.zprofile.private"
```

如果你在 WSL 里仍然通过 Clash for Windows 暴露 `7890` 端口，不需要再找旧的 WSL 特例逻辑，直接在 `~/.zprofile` 中写：

```shell
export MSE_PROXY_PORT=7890
```

当前仓库里，WSL 和其它平台统一通过 `MSE_PROXY_PORT` 控制代理端口。

## 主要功能

### micromamba

这个仓库默认使用 `micromamba`，并把 `conda` / `mamba` alias 到 `micromamba`。部署完成后，你可以直接使用 `conda` 命令管理环境。

### Vim / Neovim

- Vim 配置参考 [vim-for-coding](https://github.com/Leptune/vim-for-coding)
- Neovim 配置参考 [MyLazyVim](https://github.com/hermanzhaozzzz/MyLazyVim)

### Zsh

默认会配置：

- Oh My Zsh
- `git`
- `z`
- `zsh-syntax-highlighting`
- `zsh-autosuggestions`

### jcat

用于在终端中快速查看 `ipynb` 内容。参考项目：[jcat](https://github.com/zhifanzhu/jcat)

### wd

终端词典工具。参考项目：[Wudao-dict](https://github.com/ChestnutHeng/Wudao-dict)

### code-notify

这是一个 macOS 终端通知工具。参考项目：[code-notify](https://github.com/mylee04/code-notify)

如果你在 macOS 上启用了 `code_notify` step，`mse` 会完成对应接入；Linux 和 Windows 上会跳过这一步。

## Cluster Proxy

这一节主要解决一件事：计算节点本身不联网，但你又想在节点里继续用 `curl`、`git`、`codex`、`claude` 之类需要联网的工具。

前提假设：

- 你的 login 节点本身能联网
- login 节点上已经开着 Clash
- Clash 正在监听某个本地端口
- 本仓库默认使用 `127.0.0.1:8234`

如果你的 Clash 不在 `8234`，就在自己的 `~/.zprofile` 里改：

```shell
export MSE_PROXY_PORT=7890
```

这个仓库只负责把网络请求接到 login 节点上的 Clash。
国内外分流、PAC、规则匹配这些事情都由 Clash 完成；仓库本身不负责流量派发。

`cluster_proxy_tools` step 会接入：

- `autossh`
- `proxychains-ng`
- `proxy.on`
- `proxy.off`
- `proxy.status`
- `proxy.test`
- `proxy.exec`

`mse deploy --fast` 默认会启用这个 step，`mse update` 会沿用 `.mse-install.env` 里的 step 选择。

### login 节点

login 节点是“本来就有网”的那台机器。这里不需要 SSH 隧道，直接让当前 shell 使用本地 Clash 即可。

最短用法：

```shell
# 看当前状态
proxy.status

# 打开代理环境
proxy.on

# 测试网络
proxy.test
curl -I https://www.baidu.com
curl -I https://www.google.com
curl -I https://api.openai.com
curl -I https://api.anthropic.com

# 关闭代理环境
proxy.off
```

这里的实际效果是：

- `baidu`、`google`、`gpt`、`claude` 这些请求都会先交给 login 节点上的 Clash
- 是否直连、是否走代理、走哪条规则，都由 Clash 决定

### compute 节点

compute 节点是“本身没网”的计算节点。

这里的做法是：

- 在 compute 节点本地开一个和 login 节点相同端口的代理入口
- 用 `autossh` 把它转发回 login 节点上的 Clash
- 然后把当前 shell 的 `http_proxy` / `https_proxy` / `all_proxy` 指到这个本地入口

流量路径如下：

```text
command on compute
-> 127.0.0.1:${MSE_PROXY_PORT} on compute
-> autossh tunnel
-> 127.0.0.1:${MSE_PROXY_PORT} on login
-> Clash on login
-> Clash rules / PAC / 分流
```

最短用法：

```shell
# 先看仓库判断你现在是 login 还是 compute
proxy.status

# 在 compute 节点打开代理
proxy.on

# 测试是否已经能联网
proxy.test
curl -I https://www.baidu.com
curl -I https://www.google.com
curl -I https://api.openai.com
curl -I https://api.anthropic.com

# 用完后关闭
proxy.off
```

如果上游 login 节点没有自动识别成功，就手动指定：

```shell
# 指定 compute 节点要回连到哪个 login 节点
export MSE_PROXY_UPSTREAM_HOST=login03
proxy.on
```

当前仓库里的自动识别规则：

- `login*` 视为 login/direct
- 其他 `c*b*n*` 视为 compute
- `MSE_PROXY_DIRECT_HOSTS` 里的主机名也会按 login/direct 处理
- `MSE_PROXY_FORCE_MODE=compute|direct` 可以手动覆盖

如果你不希望在计算节点登录后自动执行 `proxy.on`，就在自己的 `~/.zprofile` 里加：

```shell
# 关闭计算节点自动代理
export MSE_SLURM_NODE_PROXY_AUTO_ENABLE=false
```

### `proxychains-ng`

大多数命令只要 `proxy.on` 之后就够了，因为它们本身会读取：

- `http_proxy`
- `https_proxy`
- `all_proxy`

但有些程序不认这些环境变量，这时就用 `proxy.exec`。它会用 `proxychains-ng` 来执行这条命令。

最短例子：

```shell
# 给 curl 强制套代理
proxy.exec curl -I https://www.google.com

# 给 git 强制套代理
proxy.exec git ls-remote https://github.com/rofl0r/proxychains-ng.git

# 给 codex 强制套代理
proxy.exec codex

# 给 claude 强制套代理
proxy.exec claude
```

适合 `proxy.exec` 的场景：

```shell
# 程序本身不认 http_proxy / https_proxy / all_proxy
proxy.exec <cmd>

# 你怀疑命令没走代理，想强制让它走代理
proxy.exec <cmd>
```

### 常用变量

```shell
# login / compute 共用的代理端口
export MSE_PROXY_PORT=8234

# 本地代理 host
export MSE_PROXY_HOST=127.0.0.1

# 额外按 login/direct 处理的主机名
export MSE_PROXY_DIRECT_HOSTS="c55b01n08"

# 手动指定 compute 节点要连回哪个 login 节点
export MSE_PROXY_UPSTREAM_HOST=login03
```

补充说明：

- `zsh` 侧默认端口是 `8234`
- 如果你的 WSL 代理入口是 `7890`，就在 `~/.zprofile` 里设 `MSE_PROXY_PORT=7890`
- Windows PowerShell profile 默认仍然是 `7890`，这是为了兼容 Clash for Windows 的常见默认设置
- `MSE_PROXY_DIRECT_HOSTS` 用空格分隔多个主机名

### 限制

- `proxychains-ng` 只适用于 TCP，不覆盖 UDP / ICMP
- 这不是系统级透明代理，前提仍然是 login 节点上的 Clash 正常工作
- 如果你 `scancel` 了 compute 节点，对应的 `autossh`、`sshd`、shell 和代理状态都会一起结束
- 换新节点后，需要重新进入节点并重新执行 `proxy.on`

## 贡献

欢迎提交 Issue 和 Pull Request。

如果你想贡献代码，最简单的路径是：

```shell
cd "$HOME"
git clone git@github.com:<your-github-name>/.my_shell_envs.git
cd ~/.my_shell_envs
./mse deploy
```

确认本地能正常使用后，再提交你的修改。

## 许可证

自由使用，按需修改。
