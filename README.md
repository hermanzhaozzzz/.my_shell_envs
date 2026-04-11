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

- `~/.zprofile`：放你自己的机器相关变量、PATH、代理参数
- `~/.zshrc`：由本仓库统一管理公共交互逻辑；`mse deploy` 时会把仓库里的 `zshrc` 软链接到 `~/.zshrc`

不要在自己的 `~/.zprofile` 里重新定义仓库已经提供的命令，尤其是 `proxy.on` / `proxy.off`。这些命令现在统一由仓库里的 `zsh/zshrc` 提供。

zsh 常见加载顺序：

```text
.zshenv -> .zprofile -> .zshrc -> .zlogin -> .zlogout
```

各文件职责：

- `~/.zshenv`：所有 zsh 进程都会读，尽量少放东西
- `~/.zprofile`：登录 shell 会先读，适合放 PATH、代理端口、主机相关变量
- `~/.zshrc`：交互式 shell 会读，你平时开终端最常接触的是它；这个文件在 deploy 时会链接到仓库里的 `zsh/zshrc`
- `~/.zlogin`：登录 shell 的收尾阶段才读，大多数时候用不上
- `~/.zlogout`：退出登录 shell 时才读

- 机器相关、个人相关的设置放 `~/.zprofile`
- 公共 alias、函数、插件和交互逻辑放仓库里的 `zsh/zshrc`

不推荐直接改 `~/.zshrc` 或仓库里的 `zsh/zshrc` 来做个人定制。这套工作流好用的前提，就是把个人配置和公共配置分开。

如果你觉得某个改动通用性很强，值得长期保留，比较合适的做法是提一个 PR，把它加进本仓库。

### 可选变量示例

下面这些都不是必须项。只有在你想覆盖默认行为时，才需要写进 `~/.zprofile`。

如果你什么都不写，大多数功能也能正常工作，默认值已经在仓库里的 `zsh/zshrc` 中提供。

```shell
export MSE_ZSH_THEME="fino"
export MSE_ZSH_PLUGINS="git z zsh-syntax-highlighting zsh-autosuggestions"
export MSE_MAMBA_AUTO_ACTIVATE_BASE=false
export MSE_SLURM_NODE_PROXY_AUTO_ENABLE=false
export MSE_PROXY_MODE=clash
export MSE_PROXY_PORT=8234
```

变量说明：

- `MSE_ZSH_THEME`：覆盖默认 Oh My Zsh 主题
- `MSE_ZSH_PLUGINS`：整体覆盖默认插件列表
- `MSE_MAMBA_AUTO_ACTIVATE_BASE=true|false`：是否在新 shell 中自动 `micromamba activate base`
- `MSE_SLURM_NODE_PROXY_AUTO_ENABLE=true|false`：是否在 Slurm 计算节点加载 `zshrc` 时自动尝试启用代理
- `MSE_PROXY_MODE=clash|direct-egress`：代理工作模式；国内默认 `clash`，国外可切到 `direct-egress`
- `MSE_PROXY_PORT=<port>`：代理端口，默认是 `8234`
- `MSE_PROXY_HOST=<host>`：默认 `127.0.0.1`
- `MSE_PROXY_DIRECT_HOSTS="<host1> <host2>"`：额外按 login/direct 处理的主机名
- `MSE_PROXY_UPSTREAM_HOST=<host>`：在计算节点无法自动推断上游 login 节点时手动指定

### 一个最小可用的 `~/.zprofile`

```shell
# 自己补充的 PATH
export PATH="$HOME/.local/bin:$PATH"

# 默认编辑器
export EDITOR="nvim"

# 新 shell 不自动 activate base
export MSE_MAMBA_AUTO_ACTIVATE_BASE=false

# 计算节点登录后不自动开代理
export MSE_SLURM_NODE_PROXY_AUTO_ENABLE=false

# 代理模式：国内一般用 clash，国外可以改成 direct-egress
export MSE_PROXY_MODE=clash

# login 节点上的代理端口
export MSE_PROXY_PORT=8234

# 这些主机按 login/direct 处理
export MSE_PROXY_DIRECT_HOSTS="c55b01n08"
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

这一节是给 Slurm 集群用户准备的一个小 trick：compute 节点本身不联网，但你还想继续用 `curl`、`git`、`codex`、`claude` 这些需要网络的工具。

`cluster_proxy_tools` step 会接入：

- `autossh`
- `proxychains-ng`
- `proxy.on`
- `proxy.off`
- `proxy.status`
- `proxy.test`
- `proxy.exec`

`mse deploy --fast` 默认会启用这个 step，也默认按中国用户处理。`mse deploy --interactive` 会问你是否在中国；如果回答是，会提醒你先打开 Clash，并确认它监听的端口。`mse update` 会复用 `.mse-install.env` 里保存的结果。

### 中国用户

前提：

- login 节点本身能联网
- login 节点上已经打开 Clash
- 你知道 Clash 正在监听哪个端口

仓库只负责把请求接到 login 节点上的 Clash。`baidu`、`google`、`gpt`、`claude` 这些请求最后怎么走，全部由 Clash 的规则决定；这个仓库不负责流量分流。

Linux / WSL 上，`cluster_proxy_tools` 会把仓库里的 `tools/clash/clash` 接到 `bin/clash`。macOS 不会链接这个二进制，默认假设你已经自己装好了 Clash。

如果你的 Clash 端口不是 `8234`，就在 `~/.zprofile` 里写：

```shell
export MSE_PROXY_PORT=7890
```

最短例子：

```shell
# login 节点：先看状态
proxy.status

# login 节点：把当前 shell 接到本地 Clash
proxy.on

# login 节点：测国内外站点
proxy.test
curl -I https://www.baidu.com
curl -I https://www.google.com
curl -I https://api.openai.com
curl -I https://api.anthropic.com

# login 节点：关掉当前 shell 的代理变量
proxy.off
```

```shell
# compute 节点：先看仓库判断你现在是什么角色
proxy.status

# compute 节点：把本地端口转回 login 节点上的 Clash
proxy.on

# compute 节点：测网络
proxy.test
curl -I https://www.baidu.com
curl -I https://www.google.com
curl -I https://api.openai.com
curl -I https://api.anthropic.com
```

流量路径是：

```text
compute 上的命令
-> compute 本地 127.0.0.1:${MSE_PROXY_PORT}
-> autossh 隧道
-> login 本地 127.0.0.1:${MSE_PROXY_PORT}
-> Clash
-> Clash 规则决定直连还是代理
```

### 国外用户

前提：

- login 节点本身能联网
- 你不需要 Clash

这时把模式切到 `direct-egress`。compute 节点会用 `autossh -D` 在本地开一个 SOCKS5 端口，然后直接借 login 节点出网。

长期设置可以写进 `~/.zprofile`：

```shell
export MSE_PROXY_MODE=direct-egress
export MSE_PROXY_PORT=8234
```

最短例子：

```shell
# compute 节点：看当前模式和节点角色
proxy.status

# compute 节点：开动态 SOCKS 隧道
proxy.on

# compute 节点：测常见外网服务
proxy.test
proxy.exec curl -I https://www.google.com
proxy.exec curl -I https://api.openai.com
proxy.exec curl -I https://api.anthropic.com
```

在这个模式下，`proxy.exec` 会更稳一些，因为它直接用 `proxychains-ng` 套住命令。

### `proxy.exec` 怎么用

很多程序在 `proxy.on` 之后就能直接用，因为它们会读：

- `http_proxy`
- `https_proxy`
- `all_proxy`

有些程序不认这些环境变量，或者你只是想强制它走代理，这时就用 `proxy.exec`。

```shell
# curl
proxy.exec curl -I https://www.google.com

# git
proxy.exec git ls-remote https://github.com/rofl0r/proxychains-ng.git

# codex
proxy.exec codex

# claude
proxy.exec claude
```

### 常用变量

```shell
# 代理模式：clash 或 direct-egress
export MSE_PROXY_MODE=clash

# login / compute 共用的代理端口
export MSE_PROXY_PORT=8234

# 本地代理 host
export MSE_PROXY_HOST=127.0.0.1

# 这些主机按 login/direct 处理
export MSE_PROXY_DIRECT_HOSTS="c55b01n08"

# 手动指定 compute 节点回连到哪个 login 节点
export MSE_PROXY_UPSTREAM_HOST=login03
```

当前自动判断规则：

- `login*` 按 login/direct 处理
- 其他 `c*b*n*` 按 compute 处理
- `MSE_PROXY_DIRECT_HOSTS` 里的主机名也按 login/direct 处理

补充说明：

- `zsh` 侧默认端口是 `8234`
- WSL 如果走 Clash for Windows 的常见默认设置，就在 `~/.zprofile` 里写 `MSE_PROXY_PORT=7890`
- Windows PowerShell profile 默认端口仍然是 `7890`
- `MSE_PROXY_DIRECT_HOSTS` 用空格分隔多个主机名

临时覆盖时，直接在命令前带变量：

```shell
# 只对这一次把 c55b01n08 当成 direct
MSE_PROXY_DIRECT_HOSTS="c55b01n08" proxy.status
MSE_PROXY_DIRECT_HOSTS="c55b01n08" proxy.on

# 只对这一次手动指定上游 login 节点
MSE_PROXY_UPSTREAM_HOST=login03 proxy.on
```

### 自动启用

默认情况下，compute 节点加载 `zshrc` 时会尝试自动执行 `proxy.on`。如果你不想要这个行为，就在 `~/.zprofile` 里写：

```shell
export MSE_SLURM_NODE_PROXY_AUTO_ENABLE=false
```

### 限制

- `proxychains-ng` 只适用于 TCP，不覆盖 UDP / ICMP
- `scancel` 掉 compute 节点后，节点上的 `autossh`、`sshd`、shell 和代理状态会一起结束
- 换新节点后，要重新进入节点，再重新执行 `proxy.on`

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
