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

在 Linux 上，`fast` 模式会默认启用所有受支持的可选 step，其中包括 `sqtop`。它是一个类似 `htop` / `nvitop` 的 Slurm 终端查看工具。

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

如果启用了 `sqtop` step，`mse` 会通过 `cargo install sqtop` 安装它，并把仓库里的 `bin/sqtop` 接到 `~/.cargo/bin/sqtop`。

部署过程中会尝试 `chsh -s "$(which zsh)"`。如果你不想现在改默认 shell，可以在密码提示时直接回车并跳过。

### `update`

`./mse update` 会先更新仓库，再按你上一次保存的配置重新执行部署。它不会再次要求你修改默认 shell。

更新仓库时，`--https` / `--ssh` 会把 GitHub origin 转换为对应协议后再 fetch；它们不是只影响后续 clone 的显示选项。无法安全转换协议的非 GitHub origin 会直接报错，不会悄悄退回另一种协议。

MSE 主仓库必须是干净工作树才能 update。Vim、Neovim、Wudao 这些由可选 step 管理的独立 Git 仓库如果含有本地修改，deploy 会明确警告、保留修改并跳过该独立仓库的 pull；不会替你 stash、回滚或覆盖。

### `.mse-install.env`

仓库根目录下的 `.mse-install.env` 会记录最近一次成功执行的部署参数和 step 开关，例如：

```shell
MSE_GIT_METHOD='ssh'
MSE_DEPLOY_MODE='fast'
MSE_USE_ZPROFILE_TEMPLATE='false'
MSE_STEP_NVIM='true'
MSE_STEP_SQTOP='true'
MSE_STEP_CODE_NOTIFY='true'
MSE_STEP_CLASHCTL='true'
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
```

变量说明：

- `MSE_ZSH_THEME`：覆盖默认 Oh My Zsh 主题
- `MSE_ZSH_PLUGINS`：整体覆盖默认插件列表
- `MSE_MAMBA_AUTO_ACTIVATE_BASE=true|false`：是否在新 shell 中自动 `micromamba activate base`
- `MSE_SLURM_NODE_PROXY_AUTO_ENABLE=true|false`：是否在 Slurm 计算节点加载 `zshrc` 时自动尝试启用代理
- `MSE_PROXY_MODE=clash|direct-egress`：代理工作模式；默认 `clash`。`direct-egress` 只用于 Slurm compute 节点，原生 Linux direct/login 节点强制由仓库内 `clashctl` 管理
- `MSE_PROXY_PORT=<port>`：macOS、WSL、Windows 外部代理客户端的 HTTP 端口，或 compute-only `direct-egress` 的本地 SOCKS 端口；Linux `clash` 模式忽略环境值，只读 `runtime.yaml`
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

# 代理模式：原生 Linux login/direct 固定使用 clashctl；direct-egress 仅供 Slurm compute 节点
export MSE_PROXY_MODE=clash

# 这些主机按 login/direct 处理
export MSE_PROXY_DIRECT_HOSTS="c55b01n08"
```

如果你在 WSL 里通过 Clash for Windows 暴露代理端口，不需要再找旧的 WSL 特例逻辑，直接在 `~/.zprofile` 中写：

```shell
export MSE_PROXY_PORT=<clash-for-windows-http-port>
```

WSL、macOS 和 Windows 通过 `MSE_PROXY_PORT` 指向外部代理客户端；原生 Linux `clash` 模式不使用这个配置入口。

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

### sqtop

Linux 上可选启用 `sqtop` step。它会通过 `cargo install sqtop` 安装一个面向 Slurm 的终端监控工具，使用体验更接近 `htop` / `nvitop` 这一类 TUI 工具，适合快速查看队列、节点和作业占用情况。

如果你执行 `mse deploy --fast`，并且当前平台支持这个 step，那么 `sqtop` 会默认安装；如果你执行 `mse deploy --interactive`，则可以在 step 选择阶段单独决定是否启用。

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

`mse deploy --fast` 默认会启用这个 step。原生 Linux 的 `mse deploy --interactive` 会以 `[Y/n]` 询问是否部署 `clashctl`，按 Enter 默认启用；明确选择 `n` 后仍可完成其它部署，但 Linux `clash` 模式的 `proxy.*` 会直接失败。interactive 不询问或保存代理端口；Linux `clash` 模式的 HTTP/SOCKS 端口唯一来自 `clashctl` 的 `runtime.yaml`。

### 中国用户

前提：

- login 节点本身能联网
- login 节点上已经打开 Clash
- `clashctl runtime.yaml` 中同时存在有效的 HTTP 和 SOCKS 端口

仓库只负责把请求接到 login 节点上的 Clash。`baidu`、`google`、`gpt`、`claude` 这些请求最后怎么走，全部由 Clash 的规则决定；这个仓库不负责流量分流。

原生 Linux 上，`mse deploy --fast` 会执行 `clashctl` step。控制脚本、Web UI 和基础资源放在仓库的 `tools/clashctl` 中；`mihomo`、`yq`、`subconverter` 会按当前 CPU 架构安装到仓库的 `bin` 中：

```shell
~/.my_shell_envs/bin/mihomo
~/.my_shell_envs/bin/yq
~/.my_shell_envs/bin/subconverter/subconverter
```

订阅、token、生成的 `runtime.yaml`、日志和下载缓存同样留在仓库目录内，但被 Git 忽略：

```shell
~/.my_shell_envs/tools/clashctl/state
~/.my_shell_envs/tools/clashctl/cache
```

deploy 不读取或兼容 `$HOME/clashctl` 等旧安装路径，也不会覆盖已经生成的 state。

Linux deploy 会先完成 clashctl，再执行需要 GitHub/Rust 网络的公共安装。已有有效 runtime 时，deploy 会先自动启用它，再更新 clashctl 程序并把代理用于后续步骤；本地安装归档完整时也可以离线重装。真正的首次部署既没有 runtime、没有完整归档、又无法直连外网时，交互模式会在任何下载之前暂停，提示你临时打开当前终端可用的外网；非交互模式会立即停止。clashctl 安装完成后，如果仍无订阅且无法访问外网，交互模式会再提示你在另一终端执行仓库 `bin/clashctl add '<subscription-url>'`。这两道预检都不会悄悄回退到其它 Linux 代理实现。

首次部署完成后添加订阅：

```shell
exec zsh
clashctl sub add --use '<subscription-url>'
proxy.on
```

`clashctl add '<subscription-url>'` 是“添加并立即使用”的快捷命令；同一 URL 已存在时会安全更新现有订阅。`clashctl del <id>` 可删除当前订阅，删除前会停止 Mihomo 并清理 runtime，不保留旧端口或配置 fallback。

订阅下载默认使用 `clash-verge/v2.3.1` User-Agent，以便服务商下发 AnyTLS 等现代 Mihomo 协议。deploy 会把该值写入 `tools/clashctl/state/env`；如服务商有特殊要求，可在部署时设置 `MSE_CLASHCTL_SUB_UA` 覆盖它。

macOS 不安装或控制 `clashctl`。本仓库只根据 `MSE_PROXY_HOST`、`MSE_PROXY_PORT` 和 `MSE_PROXY_SOCKS_PORT` 设置当前 shell 的代理变量，Clash、Surge 等客户端继续由系统侧管理。Windows 和 WSL 同样使用外部代理客户端提供的端口。

原生 Linux `clash` 模式下，`zsh/zshrc` 会从 `clashctl` 的 `runtime.yaml` 分别读取 HTTP 和 SOCKS 端口，并无条件覆盖同名环境变量。runtime 缺失、端口不完整或不可读时，`proxy.*` 直接失败，不使用手工端口。Slurm compute 节点读取共享仓库里的同一份 runtime，只把本地对应端口转发到 login 节点，不执行 `clashctl on/off`。

常用命令：

```shell
clashctl status   # 查看 Clash 内核状态
clashctl on       # 开启 Clash
clashctl off      # 关闭 Clash
clashctl ui       # 查看 Web 面板地址
```

`clashctl on` 会覆盖当前 shell 里的 `http_proxy`、`https_proxy`、`all_proxy`、`no_proxy` 及其大写版本。仓库的 `proxy.on` / `proxy.off` 管理同一组变量：`http_proxy` / `https_proxy` 指向 HTTP 端口，`all_proxy` 指向 SOCKS 端口。

`proxy.on` / `proxy.off` / `proxy.status` 是低门槛入口：

- direct/login 节点：`proxy.on` 等价于 `clashctl on` 加仓库自己的端口同步和环境变量整理
- direct/login 节点：`proxy.off` 等价于 `clashctl off -e` 加仓库自己的环境变量清理，不停止 Clash 服务
- compute 节点：`proxy.on` / `proxy.off` 仍然负责 autossh 隧道，不直接控制 Clash 服务
- `proxy.status` 保留仓库状态信息，并在 direct/login 节点附带 `clashctl status`

MSE 不读写全局 Git 代理配置。compute 节点的 `proxy.on` 只在当前 shell 临时设置 `GIT_SSH_COMMAND`；`proxy.off` 会恢复原值，而不是无条件删除用户已有配置。

`clashctl` 只负责在原生 Linux login/direct 节点上管理 Clash 本身；`proxy.on` / `proxy.off` / `proxy.status` 负责把当前 shell 或 compute 节点的流量接到这个 Clash 端口。Slurm compute 节点不会执行 `clashctl on/off`，仍然只管理到 login 节点的 autossh 隧道。

不要在原生 Linux `clash` 模式下配置 `MSE_PROXY_PORT` 或 `MSE_PROXY_SOCKS_PORT`；需要改变端口时修改 clashctl 配置并重新生成 runtime。Windows、WSL 和 macOS 不会自动加载 `clashctl`，仍由外部客户端端口驱动。

最短例子：

```shell
# login 节点：先看状态
proxy.status

# login 节点：按需手动开启代理；原生 Linux 强制走仓库内 clashctl on
proxy.on

# login 节点：测国内外站点
proxy.test

# login 节点：关掉当前 shell 的代理变量；不停止 Clash 服务
proxy.off
```

```shell
# compute 节点：自动开代理（默认行为）
# 加载 zshrc 时会自动执行 proxy.on

# compute 节点：测网络
proxy.test
```

`proxy.test` 会依次测试 `baidu.com`、`google.com.hk`、`api.openai.com`、`api.anthropic.com`，每个 URL 显示 OK 或 FAIL：

```text
== curl via env proxy ==
  OK              baidu.com (HTTP 200)
  OK              google.com.hk (HTTP 200)
  OK              openai (HTTP 421)
  OK              claude (HTTP 403)
```

流量路径是：

```text
compute 上的命令
-> compute 本地 127.0.0.1:${MSE_PROXY_PORT} / 127.0.0.1:${MSE_PROXY_SOCKS_PORT}
-> autossh 隧道
-> login 本地 127.0.0.1:${MSE_PROXY_PORT} / 127.0.0.1:${MSE_PROXY_SOCKS_PORT}
-> Clash
-> Clash 规则决定直连还是代理
```

### 国外用户

前提：

- login 节点本身能联网
- 你不需要 Clash

这时把模式切到 `direct-egress`。compute 节点会用 `autossh -D` 在本地开一个 SOCKS5 端口，然后直接借 login 节点出网。

长期设置必须写进 `~/.zprofile`，因为 `direct-egress` 不依赖 `clashctl runtime.yaml`：

```shell
export MSE_PROXY_MODE=direct-egress
export MSE_PROXY_PORT=<local-socks-port>
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
```

在这个模式下，`proxy.exec` 会更稳一些，因为它直接用 `proxychains-ng` 套住命令。

### `proxy.exec` 怎么用

很多程序在 `proxy.on` 之后就能直接用，因为它们会读：

- `http_proxy`
- `https_proxy`
- `all_proxy`
- `HTTP_PROXY`
- `HTTPS_PROXY`
- `ALL_PROXY`

有些程序不认这些环境变量，或者你只是想强制它走代理，这时就用 `proxy.exec`。

这里有一个关键点：仓库现在会把 `all_proxy` / `ALL_PROXY` 设成 `socks5h://127.0.0.1:${MSE_PROXY_SOCKS_PORT}`，优先让支持 SOCKS5h 的客户端把域名解析交给代理端，而不是让 compute 节点本地先做 DNS。这样解决的不只是 `git`，而是尽量把 `curl`、`pip`、`conda`、Python HTTP 客户端等一批常见 CLI 的 DNS 行为统一到“远端解析”。

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
# 代理模式：clash（Linux direct/login 由 clashctl 管理）或 compute-only direct-egress
export MSE_PROXY_MODE=clash

# Linux clash 模式不配置端口；HTTP/SOCKS 都从 clashctl runtime.yaml 读取

# 本地代理 host
export MSE_PROXY_HOST=127.0.0.1

# 这些主机按 login/direct 处理
export MSE_PROXY_DIRECT_HOSTS="c55b01n08"

# 手动指定 compute 节点回连到哪个 login 节点
export MSE_PROXY_UPSTREAM_HOST=login03

# 可选：限制 compute 节点启动代理时的反查和 SSH 连接等待时间
export MSE_PROXY_HOST_LOOKUP_TIMEOUT=2
export MSE_PROXY_PROCESS_LOOKUP_TIMEOUT=2
export MSE_PROXY_SSH_CONNECT_TIMEOUT=5
```

如果你是在 VSCode Remote SSH 里再打开 compute 节点上的 Terminal，常见情况是 `SSH_CONNECTION` 只会显示 `127.0.0.1 -> 127.0.0.1` 的本地转发，而不是真正的 login 节点地址。这时自动推断上游主机会失效，需要在 `~/.zprofile` 里手动设置 `MSE_PROXY_UPSTREAM_HOST=login03` 这类真实 login 主机名。

一个常见用法是先在 `~/.zprofile` 里固定写：

```shell
export MSE_PROXY_UPSTREAM_HOST=login03
```

之后每次用 VSCode Remote 打开 compute 节点上的 Terminal，直接执行：

```shell
proxy.on
proxy.status
git fetch
```

只要 `proxy.status` 里显示的 `proxy upstream` 是你期望的 login 节点，后面的 `git fetch` / `git pull` / `git push` 就应该沿着同一条代理链路工作。

当前自动判断规则：

- `login*` 按 login/direct 处理
- 其他 `c*b*n*` 按 compute 处理
- `MSE_PROXY_DIRECT_HOSTS` 里的主机名也按 login/direct 处理

compute 节点上的 `proxy.on` 现在不再只看本地端口是否在监听，还会额外做一次真实代理探测。也就是说：

- 如果旧的 autossh 进程还在，但它连到的上游主机 `127.0.0.1:${MSE_PROXY_PORT}` 实际不可用，`proxy.on` 会把它判定为坏隧道并重建
- 如果自动猜出来的第一个上游主机不可用，`proxy.on` 会继续尝试后续候选

当前上游候选顺序是：

- `MSE_PROXY_UPSTREAM_HOST`
- `SLURM_SUBMIT_HOST`
- `SSH_CONNECTION` / `SSH_CLIENT` 反查到的主机
- `MSE_PROXY_DIRECT_HOSTS` 里的主机

反查 `SSH_CONNECTION` / `SSH_CLIENT` 时会受 `MSE_PROXY_HOST_LOOKUP_TIMEOUT` 限制；查找旧 autossh 隧道时会直接读取 `/proc`，并受 `MSE_PROXY_PROCESS_LOOKUP_TIMEOUT` 限制；启动 autossh 隧道时会受 `MSE_PROXY_SSH_CONNECT_TIMEOUT` 限制，并使用非交互 SSH，避免 compute 节点登录时因为上游不可达、进程枚举异常或密码提示卡在 zsh 启动阶段。

每个 compute 主机的 MSE 隧道 PID 和完整命令记录在仓库内 Git 忽略的 `tools/clashctl/state/proxy-tunnels`。`proxy.on` 启动前与 `proxy.off` 关闭时都会清理当前主机的 stale state、旧端口隧道和旧版 MSE 隧道；匹配不到 MSE 完整特征的其它 autossh/SSH 隧道不会被处理。

如果这些候选都不对，建议在 `~/.zprofile` 里显式设置正确的 login 主机：

```shell
export MSE_PROXY_UPSTREAM_HOST=login05
```

在部分 compute 节点上，裸 `ssh -p 32985 cXXbYYnZZ` 会先进入系统默认登录 shell `/bin/bash`，而系统 `/etc/profile` 里的进程枚举命令可能卡住。交互式 zsh 中的 `ssh` 包装函数会只针对 `-p 32985` 的 Slurm compute 节点裸登录自动改写为远程执行 `zsh -l`，绕过这段 bash 登录初始化；带远程命令的 `ssh host command` 不会被改写。

补充说明：

- 代理端口不再由 `.mse-install.env` 接管
- 原生 Linux `clash` 模式只读取 `clashctl runtime.yaml` 的 HTTP 和 SOCKS 端口；环境端口会被覆盖，runtime 不完整则失败
- Slurm compute 的 `clash` 模式消费共享 runtime 并管理本机 MSE autossh 状态，不调用 `clashctl on/off`
- WSL 如果走 Clash for Windows，就在 `~/.zprofile` 里把 `MSE_PROXY_PORT` 设成 Clash for Windows 的 HTTP 端口
- Windows PowerShell profile 会读取 `MSE_PROXY_PORT`，未设置时使用 PowerShell profile 自己的默认值
- `MSE_PROXY_DIRECT_HOSTS` 用空格分隔多个主机名

临时覆盖时，直接在命令前带变量：

```shell
# 只对这一次把 c55b01n08 当成 direct
MSE_PROXY_DIRECT_HOSTS="c55b01n08" proxy.status
MSE_PROXY_DIRECT_HOSTS="c55b01n08" proxy.on

# 只对这一次手动指定上游 login 节点
MSE_PROXY_UPSTREAM_HOST=login03 proxy.on
```

这里要区分两个变量：

- `MSE_PROXY_UPSTREAM_HOST=login03 proxy.on`
  这是在说：这一次 `proxy.on` 不要自动猜上游，而是明确回连 `login03`
- `MSE_PROXY_DIRECT_HOSTS="c55b01n08" proxy.on`
  这是在说：这一次把 `c55b01n08` 当成 direct/login-like 主机，不把它识别成 compute 节点

所以 `MSE_PROXY_UPSTREAM_HOST=c55b01n08 proxy.on` 这种写法本身也有语义，但它表示的是：

- 当前这个 shell 所在节点要把代理隧道回连到 `c55b01n08`
- 只有当 `c55b01n08` 真的就是你想借出的那台上游主机，并且它本地确实有可用代理时，这样写才合理

大多数情况下，如果 `c55b01n08` 只是另一台 compute 节点，而不是登录入口或 direct 节点，那么这条命令通常不是你真正想要的配置。VSCode Remote 的典型正确写法仍然是把 `MSE_PROXY_UPSTREAM_HOST` 设成真实的 `login03` / `login04` 这类 login 主机名。

### 自动启用

- **compute 节点**：加载 `zshrc` 时自动执行 `proxy.on`（开 autossh 隧道 + 设环境变量 + 设 `GIT_SSH_COMMAND`）
- **login/direct 节点**：不会自动开代理，只提示 `proxy.on` 可用；需要时手动执行

如果自动启用失败，说明当前自动探测到的所有上游候选都没有提供一个真正可用的代理端口。这时优先检查：

- login 节点上是否已经执行过 `proxy.on`
- `proxy.status` 里的 `proxy upstream` 是否真的是你想借出的那台 login 节点
- 是否需要在 `~/.zprofile` 里显式设置 `MSE_PROXY_UPSTREAM_HOST=loginXX`
- 是否需要临时设置 `MSE_PROXY_DEBUG=1` 后重新执行 `proxy.on` 查看上游推断过程

如果你不想要 compute 节点的自动启用行为，在 `~/.zprofile` 里写：

```shell
export MSE_SLURM_NODE_PROXY_AUTO_ENABLE=false
```

### compute 节点上的 git

compute 节点 DNS 无法解析外网域名（如 `ssh.github.com`），SSH 不走 `http_proxy`。`proxy.on` 会在 compute 节点自动设置 `GIT_SSH_COMMAND`，通过 SOCKS5 代理路由 git SSH 流量，`git push` / `git pull` 可以直接使用。它优先使用支持 `-X 5 -x` 的 OpenBSD `nc`，不可用时再使用 `ncat`。

如果你还想把这套 SSH 代理能力扩展到不止 `git` 的其它 SSH 命令，可以在自己的 `~/.ssh/config` 里额外放一个 Host 段，例如：

```sshconfig
Host github.com ssh.github.com
    ProxyCommand ncat --proxy 127.0.0.1:<clash-socks-port> --proxy-type socks5 %h %p
```

只有 OpenBSD `nc` 时，对应写法是：

```sshconfig
Host github.com ssh.github.com
    ProxyCommand nc -x 127.0.0.1:<clash-socks-port> -X 5 %h %p
```

这样 `ssh` 本身也会直接走 SOCKS5，而不是只靠 `GIT_SSH_COMMAND` 给 git 单独兜底。

### 限制

- `proxychains-ng` 只适用于 TCP，不覆盖 UDP / ICMP
- `scancel` 掉 compute 节点后，节点上的 `autossh`、`sshd`、shell 和代理状态会一起结束
- 换新节点后，要重新进入节点，再重新执行 `proxy.on`
- Go 程序（如 `frp-panel`）绕过 libc 做 DNS，`proxychains` 无法拦截；compute 节点上需要用 IP 替代域名
- 如果你希望“几乎所有程序都无脑可用”，那已经不是 shell 环境变量层面能彻底解决的问题，而是需要 TUN / 透明代理，或者集群管理员直接提供可用 DNS

## 测试

仓库自带的 shell 单元测试不需要真实订阅、Mihomo 服务或外网，会使用临时目录验证 deploy 选择、端口同步、Slurm 角色分流和 clashctl 生命周期：

```shell
./tests/run.sh
```

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
