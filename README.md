# My Shell Env (MSE)

Fast deployment for shell environments.

> [!TIP]
> 🚀 别把时间浪费在配置环境上。花十分钟装上 MSE，然后开始干活。

[简体中文](README.md) | [English](docs/README.en.md)

一个用于快速部署个人 Shell / Python / 编辑器环境的仓库，目标是减少手工配置时间，让常用终端工具、编辑器配置和部分开发环境可以快速落地。

## 目录

- [简介](#简介)
- [开始使用](#开始使用)
  - [前置依赖](#前置依赖)
  - [HTTPS 安装（普通用户）](#https-安装普通用户)
  - [SSH 安装（开发者）](#ssh-安装开发者)
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

这个仓库用来部署我自己的 Shell / Python / 编辑器环境。

在仓库目录里，直接用这两个命令：

- `./mse deploy`
- `./mse update`

## 开始使用

按你的情况选一种安装方式：

- 普通用户：使用 HTTPS `git clone`
- Owner / 开发者：使用 SSH `git clone`

### 前置依赖

在 Linux / macOS / WSL 上，执行 `./mse deploy` 之前，请先确认系统里已经有 `zsh`。

`./mse deploy` 会继续处理这些内容：

- `oh-my-zsh`
- Oh My Zsh 标准插件：`git`、`z`
- 自定义插件：`zsh-syntax-highlighting`、`zsh-autosuggestions`

你需要提前准备的是：

```shell
# required on macOS / Linux / WSL
git
```

脚本会按下面的规则处理：

- macOS / Linux / WSL 都一样：脚本会先检查 `zsh`
- 如果系统里没有 `zsh`，脚本会直接报错退出，并提示你先手动安装 `zsh`
- 如果系统里已经有 `zsh`，脚本会继续配置 `oh-my-zsh`、标准插件 `git` / `z`、自定义插件 `zsh-syntax-highlighting` / `zsh-autosuggestions`
- 部署会自动链接 `~/.zshrc`，并尝试执行 `chsh -s "$(which zsh)"`
- 仓库默认的 Oh My Zsh 主题是 `fino`
- 如果你使用本仓库里的 `zshrc`，部署后不需要再手工维护 `plugins=(...)`

### HTTPS 安装（普通用户）

普通用户直接执行：

```shell
cd "$HOME"
git clone https://github.com/hermanzhaozzzz/.my_shell_envs.git
cd ~/.my_shell_envs

./mse deploy
```

如果你要交互式部署，或者要链接 demo `zprofile`，用下面的命令：

```shell
./mse deploy --interactive
./mse deploy --interactive --use-zprofile-template
```

执行 `./mse deploy` 时：

- 在 Linux / macOS / WSL 上，部署会先检查 `zsh`；如果没有，就报错退出，并提示你先手动安装 `zsh`
- 如果 `zsh` 已经存在，脚本会安装 Oh My Zsh、安装必需插件、链接 `~/.zshrc`，并把默认 shell 切到 `zsh`
- 部署开始前，脚本会先打印即将修改的路径，例如 `~/.zshrc`、`~/.oh-my-zsh`、插件目录、`~/.condarc`、`~/.vim`、`~/.config/nvim`
- 只有在显式传入 `--use-zprofile-template` 时，才会改动 `~/.zprofile`

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

Windows 上直接这样做：

- Windows 主流程是 `PowerShell` + `git-bash`
- 普通用户默认使用 HTTPS clone

### SSH 安装（开发者）

本仓库开发者直接执行：

```shell
cd "$HOME"
git clone git@github.com:hermanzhaozzzz/.my_shell_envs.git
cd ~/.my_shell_envs

./mse deploy --ssh --use-zprofile-template
```

执行 `./mse deploy --ssh --use-zprofile-template` 时：

- 这条路径默认使用 SSH clone
- 在 Linux / macOS / WSL 上，会先检查 `zsh`；如果没有，就报错退出，并提示你先手动安装 `zsh`
- 如果 `zsh` 已经存在，脚本会继续配置 Oh My Zsh、必需插件、`~/.zshrc` 和默认 shell 切换
- 部署时默认走 `fast` 模式，也就是非交互式安装
- `--ssh` 会让附属 Git 仓库也使用 SSH
- `--use-zprofile-template` 会把仓库里的示例 `zprofile` 模板链接到 `~/.zprofile`
- 如果你想保留自己的登录配置，可以去掉 `--use-zprofile-template`

### 更新

更新时直接执行：

```shell
./mse update

# pass deploy flags through update
./mse update --interactive
./mse update --ssh --interactive
./mse update --interactive --use-zprofile-template
```

安装或部署完成后，仓库会把 `mse` 放到：

```shell
~/.my_shell_envs/bin/mse
```

仓库的 `zsh/zshrc` 会把这个目录加入 PATH：

```shell
~/.my_shell_envs/bin
```

所以打开一个新的 zsh 终端后，你可以在任意目录直接执行：

```shell
mse update
mse deploy
```

执行 `./mse update` 时：

- `mse update` 会先更新源码，再重新执行部署
- Git 安装会走 `git fetch` + `git pull --rebase`

如果你希望把自己的命令也做成全局可用，直接放到这个目录里即可：

```shell
ln -s /absolute/path/to/your_tool ~/.my_shell_envs/bin/your_tool
```

或者把可执行文件直接复制进去：

```shell
cp /absolute/path/to/your_tool ~/.my_shell_envs/bin/
chmod +x ~/.my_shell_envs/bin/your_tool
```

这样打开一个新的 zsh 终端后，你就可以在任意目录直接运行 `your_tool`。

### Conda 环境

这个仓库里，`conda` 就是 `micromamba` 的 alias。

执行 `./mse deploy` 时，脚本会：

- 安装 `micromamba`
- 把当前平台对应的环境文件从 `conda/<platform>/` 软链接到 `conda_local_env_settings/`

它不会自动创建所有环境。部署完成后，需要你自己执行 `conda` 命令。

当前平台的 `base.yml` 会链接到：

```shell
~/.my_shell_envs/conda_local_env_settings/base.yml
```

要更新或安装 `base` 环境，直接执行：

```shell
conda activate base && conda install -f ~/.my_shell_envs/conda_local_env_settings/base.yml
```

如果你要装别的环境，就把 `base.yml` 换成对应的 `.yml` 文件。

### 个人配置

默认情况下，`./mse deploy` 只处理公共配置，不改你的个人登录配置：

- 在 Linux / macOS / WSL 上，`./mse deploy` 要求系统里已经有 `zsh`；确认后会继续配置 Oh My Zsh、插件，并链接 `~/.zshrc`
- `./mse deploy` 默认不会改动 `~/.zprofile`
- `--use-zprofile-template` 只会把仓库里的 demo 模板链接到 `~/.zprofile`

```shell
./mse deploy --interactive

# optional: also link the demo zprofile template
./mse deploy --interactive --use-zprofile-template
```

这里直接说明白：

- 对普通用户来说，不建议直接链接我的 `zprofile` 模板
- `zsh/zprofile_hermanzhaozzzz_demo` 只是 demo，主要方便我自己使用，里面是个人习惯示例，不是通用配置
- 如果你要 DIY 自己的环境，建议你自己新建 `~/.zprofile`
- 这个仓库的公共交互配置在 `zsh/zshrc`，个人机器相关配置放你自己的 `~/.zprofile`

Zsh 的加载顺序是：

```text
.zshenv -> .zprofile -> .zshrc -> .zlogin -> .zlogout
```

每个文件建议这样用：

- `~/.zshenv`
  作用：每次启动 zsh 都会加载，包括非交互 shell
  建议：尽量少放东西。不要放代理、别名、插件、复杂逻辑。这个仓库现在不要求你改它
- `~/.zprofile`
  作用：login shell 时加载，在 `~/.zshrc` 之前
  建议：把你自己的 PATH、代理、机器相关环境变量、私有 token、主机别名放这里
- `~/.zshrc`
  作用：interactive shell 时加载，是你平时开终端最常用的配置文件
  建议：这个仓库已经帮你管理公共配置，里面负责 Oh My Zsh、主题、插件、alias、函数和 `~/.my_shell_envs/bin`
- `~/.zlogin`
  作用：login shell 的最后阶段才加载
  建议：大多数用户不用它

如果你要 DIY，推荐这样放：

- PATH：放在 `~/.zprofile`
- 代理开关：放在 `~/.zprofile`
- 私有 token / 公司内网配置：放在 `~/.zprofile`，或者再 `source` 一个只有本机有的私有文件
- 公共 alias / 函数：继续让仓库的 `zsh/zshrc` 管理
- 如果你只想改 Oh My Zsh 主题或插件，不要改仓库里的 `zsh/zshrc`，直接在你自己的 `~/.zprofile` 里覆盖

`PATH` 最重要的规则只有一条：不要覆盖现有的 `$PATH`，要在现有值前后追加。

如果你要覆盖主题或插件，直接把下面这些变量写进 `~/.zprofile`：

```shell
# optional: override Oh My Zsh theme
export MSE_ZSH_THEME="robbyrussell"

# optional: override plugin list
export MSE_ZSH_PLUGINS="git z zsh-syntax-highlighting zsh-autosuggestions"
```

规则很简单：

- `MSE_ZSH_THEME`：覆盖仓库默认主题 `fino`
- `MSE_ZSH_PLUGINS`：整体覆盖仓库默认插件列表
- 这些变量放在 `~/.zprofile` 里即可，仓库的 `zsh/zshrc` 会读取它们

如果你不想改主题和插件，就不要写这两个变量。

推荐写法：

```shell
# keep existing PATH, then prepend your own paths
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# add toolchain paths only when they exist
[ -d "$HOME/micromamba/bin" ] && export PATH="$HOME/micromamba/bin:$PATH"
[ -d "/opt/homebrew/bin" ] && export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
```

写 `PATH` 时注意：

- 一定要保留 `$PATH`，不要写成 `export PATH="/some/path"` 这种覆盖式写法
- 这样系统已有命令、仓库里的 `~/.my_shell_envs/bin`、以及 `zsh/zshrc` 后续追加的内容都不会丢
- 优先把你自己的 bin 目录放在前面，例如 `~/.local/bin`
- 对平台相关路径做存在性判断，避免在别的机器上报错
- 除非你非常确定后果，否则不要随意 `unset PATH`

一个最小可用的 `~/.zprofile` 示例：

```shell
# keep existing PATH
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

如果你要放敏感 token、私有主机名或公司内网配置，更稳妥的做法是：

```shell
[ -f "$HOME/.zprofile.private" ] && source "$HOME/.zprofile.private"
```

把这些私密内容放进你自己的 `~/.zprofile.private`，不要直接写进仓库里的公共配置。

## 主要特性

### 1. micromamba

我用 micromamba 替代 conda / miniconda / mamba，主要原因是：

- conda / miniconda 速度偏慢
- mamba 在更新某些已有环境时有时不够稳

在这个仓库里，日常命令直接写 `conda` 即可，因为 `conda` 已经被 alias 到 `micromamba`。

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

- Oh My Zsh 主题：`fino`
- Oh My Zsh 标准插件：`git`、`z`
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting.git)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [z](https://github.com/rupa/z)

默认插件的作用和常用用法：

- `git`
  作用：提供常用 git alias
  例子：`gst` 查看状态，`gco <branch>` 切分支，`gaa` 添加全部修改
- `z`
  作用：记录你常去的目录，之后可以快速跳转
  例子：先多 `cd` 几次，之后直接 `z project`、`z Downloads`
- `zsh-syntax-highlighting`
  作用：命令行里直接高亮语法
  用法：输入命令时，通常可执行的命令会高亮，拼错的命令不会高亮
- `zsh-autosuggestions`
  作用：根据历史命令自动补全建议
  用法：终端里会显示灰色建议，通常按右方向键接受建议

如果你不改任何个人配置，部署后这些插件就会直接生效。

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
