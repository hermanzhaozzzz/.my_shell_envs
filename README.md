# Shell 环境快速部署

Fast deployment for shell environments.

别把时间浪费在配置环境上。花十分钟装上 MSE，然后开始干活。

[简体中文](README.md) | [English](docs/README.en.md)

一个用于快速部署个人 Shell / Python / 编辑器环境的仓库，目标是减少手工配置时间，让常用终端工具、编辑器配置和部分开发环境可以快速落地。

## 目录

- [简介](#简介)
- [开始使用](#开始使用)
  - [前置依赖](#前置依赖)
  - [普通用户安装](#普通用户安装)
  - [通过 Git 安装](#通过-git-安装)
  - [更新](#更新)
  - [Conda 环境](#conda-环境)
  - [个人配置](#个人配置)
- [主要特性](#主要特性)
  - [1. micromamba](#1-micromamba)
  - [2. Vim / Neovim](#2-vim--neovim)
  - [3. Zsh](#3-zsh)
  - [4. jcat](#4-jcat)
  - [5. wd](#5-wd)
  - [6. 其他小工具](#6-其他小工具)
- [贡献](#贡献)
- [许可证](#许可证)

## 简介

这个仓库主要用于：

- 快速部署一套我常用的 Shell 环境
- 同步常用的 Zsh、pip、Vim/Neovim 配置
- 在 `fast` 和 `interactive` 两种部署模式之间切换
- 用 `--https` / `--ssh` 控制附属 Git 仓库的拉取方式

统一入口现在是 `mse`：

- 仓库内使用：`./mse deploy`、`./mse update`
- 普通用户安装后可直接使用：`mse update`

## 开始使用

### 前置依赖

如果你希望使用仓库里的 Zsh 配置，建议先准备这些依赖：

- `zsh`
- `git`
- `curl`
- `oh-my-zsh`

Linux 示例：

```shell
# system packages
sudo apt update
sudo apt install -y zsh git curl

# verify zsh
zsh --version

# set zsh as the default shell
chsh -s "$(which zsh)"
# usually requires logging out and logging back in

# install oh-my-zsh (official)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# install plugins required by this repo
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] || \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] || \
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
```

说明：

- 上面使用的是 Oh My Zsh 官方仓库地址
- 插件目录用的是 `$ZSH_CUSTOM`
- 如果你使用本仓库里的 `zshrc`，部署后不需要再手工维护 `plugins=(...)`

### 普通用户安装

适合只想快速用起来，不想完整 `git clone` 仓库的人。默认会把源码安装到 `~/.my_shell_envs`，并在 `~/.local/bin/mse` 放一个全局 wrapper。

```shell
curl -fsSL https://raw.githubusercontent.com/hermanzhaozzzz/.my_shell_envs/main/install.sh | sh
```

常见变体：

```shell
# interactive deploy
curl -fsSL https://raw.githubusercontent.com/hermanzhaozzzz/.my_shell_envs/main/install.sh | sh -s -- --interactive

# use ssh for secondary git clones during deployment
curl -fsSL https://raw.githubusercontent.com/hermanzhaozzzz/.my_shell_envs/main/install.sh | sh -s -- --ssh --interactive

# also link the demo zprofile template (review before use)
curl -fsSL https://raw.githubusercontent.com/hermanzhaozzzz/.my_shell_envs/main/install.sh | sh -s -- --interactive --use-zprofile-template
```

说明：

- 这条路径主要面向 macOS / Linux / WSL
- 安装脚本会先下载 GitHub `main` 分支 archive，再执行一次 `mse deploy`
- 安装开始前，脚本会先打印即将修改的路径，例如 `~/.zshrc`、`~/.condarc`、`~/.vim`、`~/.config/nvim`
- 只有在显式传入 `--use-zprofile-template` 时，才会改动 `~/.zprofile` 和 `~/.zshenv`
- 如果 `~/.local/bin` 不在 `PATH`，脚本会提示你手动添加，但不会自动修改你的 shell 配置

Windows 不使用这条 `curl | sh` 安装路径。

首次安装完成后，推荐更新方式：

```shell
mse update
```

如果 `mse` 还不在 PATH，可用：

```shell
~/.local/bin/mse update
```

Windows 安装与更新：

```powershell
# run in PowerShell
cd $HOME
git clone https://github.com/hermanzhaozzzz/.my_shell_envs.git
cd ~/.my_shell_envs

# deploy with git-bash
git-bash ./mse deploy
# or
git-bash ./mse deploy --interactive

# update later
git-bash ./mse update
```

说明：

- Windows 主流程是 `PowerShell` + `git-bash`
- Windows 端文档默认使用 HTTPS clone；如果你已经配置好 SSH，也可以自行替换成 SSH 地址
- `curl | sh` 安装器面向类 Unix 环境，不作为 Windows 入口

### 通过 Git 安装

适合希望完整保留 Git 历史、直接在本地管理仓库，或计划参与维护与提交修改的用户。

```shell
cd "$HOME"
git clone https://github.com/hermanzhaozzzz/.my_shell_envs.git
cd ~/.my_shell_envs

./mse deploy
# or
./mse deploy --interactive
# or
./mse deploy --interactive --use-zprofile-template
# or
git remote set-url origin git@github.com:hermanzhaozzzz/.my_shell_envs.git
./mse deploy --ssh --interactive
```

如果你已经配置好了 GitHub SSH，也可以从一开始就直接使用 SSH clone：

```shell
cd "$HOME"
git clone git@github.com:hermanzhaozzzz/.my_shell_envs.git
cd ~/.my_shell_envs

./mse deploy --ssh
```

### 更新

统一更新命令现在是：

```shell
# global wrapper path (recommended for archive installs)
mse update

# inside the repo
./mse update

# pass deploy flags through update
./mse update --interactive
./mse update --ssh --interactive
./mse update --interactive --use-zprofile-template
```

行为说明：

- `mse update` 会先更新源码，再重新执行部署
- Git 安装会走 `git fetch` + `git pull --rebase`
- Archive 安装会重新下载 GitHub archive，并在更新前做本地备份

### Conda 环境

`mse deploy` 里的 `micromamba` 步骤主要做两件事：

- 安装 `micromamba`
- 把当前平台对应的环境文件从 `conda/<platform>/` 软链接到 `conda_local_env_settings/`

它不会自动把所有环境都创建出来。部署完成后，你可以按需要手动重建或更新环境。

当前平台的 `base` 环境文件会被链接到：

```shell
conda_local_env_settings/base.yml
```

更新已有 `base` 环境：

```shell
micromamba env update -n base -f conda_local_env_settings/base.yml --prune
```

在一个全新的 `micromamba` 前缀里重建 `base` 环境：

```shell
micromamba create -y -n base -f conda_local_env_settings/base.yml
```

其他环境也是同样的模式，例如 Linux 下的 `esmfold`：

```shell
micromamba create -y -f conda/Linux/esmfold.yml
micromamba env update -n esmfold -f conda/Linux/esmfold.yml --prune
```

补充说明：

- `mse deploy` 负责准备 `micromamba` 和环境描述文件，不负责自动安装所有 Conda 环境
- `--prune` 会删除环境文件里已经不存在的包，适合做同步更新
- 如果你只想快速把当前平台的 `base` 环境对齐，优先使用 `micromamba env update`

### 个人配置

仓库里的公共配置和个人配置现在都统一收口到 `mse deploy`，但默认策略更保守：

- `./mse deploy` 默认不会改动 `~/.zprofile`
- 如果你明确希望把仓库里的示例模板软链接到 `~/.zprofile`，再额外加 `--use-zprofile-template`

```shell
./mse deploy --interactive

# optional: also link the demo zprofile template
./mse deploy --interactive --use-zprofile-template
```

补充说明：

- `~/.zprofile` 会在登录时先于 `~/.zshrc` 被加载
- `zsh/zshrc` 可以在没有 demo `~/.zprofile` 的情况下独立运行，所以只部署公共配置是默认推荐路径
- 仓库里的 `zsh/zprofile_hermanzhaozzzz_demo` 是个人化示例，包含主机、代理和命令习惯假设；如果你使用它，请先完整审阅并改成自己的版本
- 更推荐的做法是自己维护一个 `~/.zprofile`，把登录时才需要的环境变量、PATH、代理和主机别名放进去

建议把 `~/.zprofile` 用在这些场景：

- 配置 `PATH`
- 配置代理开关
- 设置只在登录 shell 中需要的环境变量
- 按机器类型加载不同工具链或主机别名

推荐的 `PATH` 写法：

```shell
# keep user-level bin directories near the front
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# add toolchain paths only when they exist
[ -d "$HOME/micromamba/bin" ] && export PATH="$HOME/micromamba/bin:$PATH"
[ -d "/opt/homebrew/bin" ] && export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
```

说明：

- 优先把你自己的 bin 目录放在前面，例如 `~/.local/bin`
- 对平台相关路径做存在性判断，避免在别的机器上报错
- 除非你非常确定后果，否则不要随意 `unset PATH`

一个最小可用的 `~/.zprofile` 示例：

```shell
export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export PAGER="less"

[ -d "$HOME/micromamba/bin" ] && export PATH="$HOME/micromamba/bin:$PATH"
```

代理配置示例：

```shell
proxy_on() {
  export http_proxy="http://127.0.0.1:7890"
  export https_proxy="http://127.0.0.1:7890"
  export all_proxy="socks5://127.0.0.1:7890"
}

proxy_off() {
  unset http_proxy https_proxy all_proxy
}

alias proxy.on=proxy_on
alias proxy.off=proxy_off
```

如果你希望把敏感 token、私有主机名或公司内网配置也放进去，建议再从 `~/.zprofile` 里 `source` 一个本机私有文件，而不是直接改仓库里的公共配置。

## 主要特性

### 1. micromamba

我用 micromamba 替代 conda / miniconda / mamba，主要原因是：

- conda / miniconda 速度偏慢
- mamba 在更新某些已有环境时有时不够稳

如果你只想保留自己的 conda，不想安装 micromamba，可以直接使用：

```shell
./mse deploy --interactive
```

![](https://pic3.zhimg.com/v2-9b990548c624931878c88dbc65154bea_b.jpg)

### 2. Vim / Neovim

- Vim 配置参考 [vim-for-coding](https://github.com/Leptune/vim-for-coding)
- Neovim 配置参考我的 [MyLazyVim](https://github.com/hermanzhaozzzz/MyLazyVim)

![](https://pic4.zhimg.com/v2-9587f7dca82dc9b6e700b661e96207db_b.jpg)

### 3. Zsh

包含一套我常用的 Zsh 插件和命令习惯：

- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting.git)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [z](https://github.com/rupa/z)

![](https://pic2.zhimg.com/v2-1d5b7cade272ec46c293bf80353d36e5_b.jpg)

### 4. jcat

终端里快速查看 `ipynb` 文件内容，参考项目：

- [jcat](https://github.com/zhifanzhu/jcat)

![](https://pic1.zhimg.com/v2-cc31145bcbe6d57e78dbf90db7b78f10_b.jpg)
![](https://pic4.zhimg.com/v2-42f94f107405490e83cef241d413ca97_b.jpg)

### 5. wd

终端词典工具，参考项目：

- [Wudao-dict](https://github.com/ChestnutHeng/Wudao-dict)

![](https://pic1.zhimg.com/v2-4941f3b7b7c83780d50bcfb36b6dbad8_b.jpg)

### 6. 其他小工具

还包含一些我日常会用的小功能：

- 一个“回收站式”的删除机制，避免误用 `rm -rf`
- `l` / `ll` / `lll` / `llll` 这些更顺手的目录查看命令
- `btop`、`open` 等常用别名
- 可以通过在 `~/.my_shell_envs/bin` 下建立软链接，把你自己的命令加入 PATH

## 贡献

欢迎提交 Issue 和 Pull Request。

如果你发现了 bug、兼容性问题、文档缺失，或者希望补充新的环境模块，都可以直接在仓库中发起讨论或提交修改。

## 许可证

自由使用，按需修改。
