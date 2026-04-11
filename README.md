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

`--use-zprofile-template` 只适合你明确想接管自己的 `~/.zprofile` 时使用。默认情况下，`mse` 不会改这个文件。

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

所以：

- `mse deploy --fast` 的默认行为
- 后面的 `mse update`

不一定完全一样。`update` 会优先复用 `.mse-install.env` 里已经保存的选择。

你有两种方式改默认行为：

- 重新执行 `mse deploy --interactive`
- 直接修改 `.mse-install.env`

## 个人配置

### `~/.zprofile` 和 `~/.zshrc`

推荐这样分工：

- `~/.zprofile`：放你自己的机器相关变量、PATH、代理参数、私有 token
- `~/.zshrc`：由本仓库统一管理公共交互逻辑

不要在自己的 `~/.zprofile` 里重新定义仓库已经提供的命令，尤其是 `proxy.on` / `proxy.off`。这些命令现在统一由仓库里的 `zsh/zshrc` 提供。

如果你容易混淆这几个文件，可以先记住 zsh 的常见加载顺序：

```text
.zshenv -> .zprofile -> .zshrc -> .zlogin -> .zlogout
```

通常可以这样理解：

- `~/.zshenv`：所有 zsh 进程都会读，尽量少放东西
- `~/.zprofile`：登录 shell 会先读，适合放 PATH、代理端口、主机相关变量
- `~/.zshrc`：交互式 shell 会读，你平时开终端最常接触的是它
- `~/.zlogin`：登录 shell 的收尾阶段才读，大多数时候用不上
- `~/.zlogout`：退出登录 shell 时才读

这个仓库的思路很简单：

- 机器相关、个人相关的设置放 `~/.zprofile`
- 公共 alias、函数、插件和交互逻辑放仓库里的 `zsh/zshrc`

### 可选变量示例

下面这些都不是必须项，只是你想覆盖默认行为时可以写进 `~/.zprofile` 的示例。

如果你什么都不写，大多数功能也能正常工作，因为仓库里的 `zsh/zshrc` 已经提供了默认值。

```shell
export MSE_ZSH_THEME="fino"
export MSE_ZSH_PLUGINS="git z zsh-syntax-highlighting zsh-autosuggestions"
export MSE_MAMBA_AUTO_ACTIVATE_BASE=false
export MSE_SLURM_NODE_PROXY_AUTO_ENABLE=false
export MSE_PROXY_PORT=8234
```

这些变量的作用分别是：

- `MSE_ZSH_THEME`：覆盖默认 Oh My Zsh 主题
- `MSE_ZSH_PLUGINS`：整体覆盖默认插件列表
- `MSE_MAMBA_AUTO_ACTIVATE_BASE=true|false`：是否在新 shell 中自动 `micromamba activate base`
- `MSE_SLURM_NODE_PROXY_AUTO_ENABLE=true|false`：是否在 Slurm 计算节点加载 `zshrc` 时自动尝试启用代理
- `MSE_PROXY_PORT=<port>`：代理端口，默认是 `8234`
- `MSE_PROXY_HOST=<host>`：默认 `127.0.0.1`
- `MSE_PROXY_FORCE_MODE=compute|direct`：手动覆盖代理模式判断
- `MSE_PROXY_UPSTREAM_HOST=<host>`：在计算节点无法自动推断上游 login 节点时手动指定

### 一个最小可用的 `~/.zprofile`

```shell
export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export MSE_MAMBA_AUTO_ACTIVATE_BASE=false
export MSE_SLURM_NODE_PROXY_AUTO_ENABLE=false
export MSE_PROXY_PORT=8234

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

这一部分是给 Slurm 集群用户准备的小 trick，主要用来解决计算节点本身不联网的问题。

思路很简单：

- login 节点继续跑你平时就在用的 Clash
- compute 节点把流量通过 SSH 隧道转回 login 节点
- 这样在 compute 节点里也能继续联网

### 组成

`cluster_proxy_tools` step 会接入：

- `autossh`
- `proxychains-ng`
- `proxy.on`
- `proxy.off`
- `proxy.status`
- `proxy.test`
- `proxy.exec`

默认情况下：

- `mse deploy --fast` 会启用 `cluster_proxy_tools`
- `mse update` 会沿用 `.mse-install.env` 中保存的 step 选择

### 工作方式

在 compute 节点上的流量路径是：

```text
program on compute
-> ${MSE_PROXY_HOST:-127.0.0.1}:${MSE_PROXY_PORT:-8234} on compute
-> autossh tunnel
-> ${MSE_PROXY_HOST:-127.0.0.1}:${MSE_PROXY_PORT:-8234} on login
-> Clash on login
-> Clash rules / PAC / 分流
```

可以把它理解成：

- compute 节点自己不做分流
- 分流规则直接复用 login 节点上的 Clash
- 如果 Clash 现在是“国内直连、国外走代理”，compute 节点也会跟着这样走

### 模式判断

当前仓库里的自动识别规则如下：

- `login*` 视为 direct
- `c55b01n08` 视为 direct
- 其他 `c*b*n*` 视为 compute
- `MSE_PROXY_FORCE_MODE=compute|direct` 可以手动覆盖

### 默认行为

- 在 compute 节点，加载 `zshrc` 时会自动尝试启用代理
- 在 direct/login 节点，如果本地代理端口已经在监听，也会顺手启用代理
- 自动启用成功后，会打印提示，提醒你可以测试网络

如果你不希望在计算节点默认自动启用代理，在自己的 `~/.zprofile` 中设置：

```shell
export MSE_SLURM_NODE_PROXY_AUTO_ENABLE=false
```

这样命令还在，只是新 shell 不会自动执行 `proxy.on`。

### 端口和主机变量

当前正式支持的变量是：

```shell
export MSE_PROXY_PORT=8234
export MSE_PROXY_HOST=127.0.0.1
export MSE_PROXY_UPSTREAM_HOST=login03
```

说明：

- `MSE_PROXY_PORT` 默认是 `8234`
- 如果你的 WSL 代理入口是 `7890`，就在 `~/.zprofile` 里改成 `MSE_PROXY_PORT=7890`
- Windows PowerShell profile 默认仍然使用 `7890`，这是为了兼容 Clash for Windows 的常见默认设置；如果你改了本机代理端口，同样用 `MSE_PROXY_PORT` 覆盖即可
- `MSE_PROXY_UPSTREAM_HOST` 只在 compute 节点无法自动推断上游 login 节点时需要设置

### 常用命令

```shell
proxy.status
proxy.on
proxy.test
proxy.exec curl -I https://www.baidu.com
proxy.off
```

大致作用如下：

- `proxy.on`：在 direct 节点直接启用本地代理环境；在 compute 节点建立到 login 节点的 `autossh` 隧道并设置环境变量
- `proxy.off`：清理代理环境；在 compute 节点还会尝试关闭对应隧道
- `proxy.status`：查看当前模式、端口、上游节点和隧道状态
- `proxy.test`：用 `curl` 和 `proxychains-ng` 做一轮最小连通性测试
- `proxy.exec <cmd>`：给那些不认 `http_proxy` / `https_proxy` / `all_proxy` 的 TCP 程序强制套代理

### 限制和生命周期

- `proxychains-ng` 只适用于 TCP，不覆盖 UDP / ICMP
- 这套方案本质上还是“复用 login 节点已有代理”，不是系统级透明代理
- 如果你 `scancel` 了 compute 节点，对应的 `autossh`、`sshd`、shell 和代理状态都会一起结束
- 换新节点后，需要重新进入节点并重新建立代理

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
