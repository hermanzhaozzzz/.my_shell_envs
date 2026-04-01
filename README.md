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
  - [7. code-notify](#7-code-notify)
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

- `Rust` 工具链（通过 `rustup` 安装，但不让 `rustup` 修改 PATH）
- repo-managed CLI 工具：`eza`、`bat`、`rg`
- `oh-my-zsh`
- Oh My Zsh 标准插件：`git`、`z`
- 自定义插件：`zsh-syntax-highlighting`、`zsh-autosuggestions`

你需要提前准备的是：

```shell
# required on macOS / Linux / WSL
git
# 编译依赖时，需要调用系统 C 编译器/链接器
sudo apt update
sudo apt install -y build-essential pkg-config
```

脚本会按下面的规则处理：

- macOS / Linux / WSL 都一样：脚本会先检查 `zsh`
- 如果系统里没有 `zsh`，脚本会直接报错退出，并提示你先手动安装 `zsh`
- 如果系统里已经有 `zsh`，脚本会继续安装默认的 `Rust` 工具链、repo-managed CLI 工具 `eza` / `bat` / `rg`，并配置 `oh-my-zsh`、标准插件 `git` / `z`、自定义插件 `zsh-syntax-highlighting` / `zsh-autosuggestions`
- 部署会自动链接 `~/.zshrc`，并尝试执行 `chsh -s "$(which zsh)"`
- 在执行 `chsh` 之前，脚本会先提示你：如果现在不想改默认 shell，可以直接在密码提示处敲回车；随后脚本会进入“重试 / 跳过”选择
- 如果 `chsh` 不可用，或者你没有权限修改默认 shell，部署不会退出；脚本会继续，并询问你是否把“自动进入 zsh”的配置写入当前 shell 的配置文件
- `Rust` 的安装通过 `rustup --no-modify-path` 完成；`~/.cargo/bin` 由仓库的 `zshrc` 在需要时加入 PATH
- `eza`、`bat`、`rg` 会作为默认依赖直接部署，并接到仓库的 `bin/` 目录
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
- 如果 `zsh` 已经存在，脚本会默认安装 `Rust`、`eza`、`bat`、`rg`，然后安装 Oh My Zsh、安装必需插件、链接 `~/.zshrc`，并尝试把默认 shell 切到 `zsh`
- 在执行 `chsh` 之前，脚本会先告诉你：如果不想现在改默认 shell，可以直接在密码提示处敲回车，然后在后续菜单里选择 retry 或 skip
- 如果默认 shell 无法改成 `zsh`，脚本会继续部署，并给你两个选择：重试 `chsh`，或者跳过 `chsh`，改为把自动进入 `zsh` 的逻辑写到当前 shell 的配置文件里
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
- `mse deploy` 会把 PowerShell 用户 profile `~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1` 链接到仓库中的 `powershell/Microsoft.PowerShell_profile.ps1`，因此后续直接修改任一侧都能实时联动，不需要重新部署

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

常用参数这样理解：

- `--interactive`
  作用：进入交互模式，按 step 逐个确认要不要执行
  什么时候加：如果你想自己选择安装哪些模块，就加这个参数
- `--ssh`
  作用：附属 Git 仓库也使用 SSH 地址
  什么时候加：如果你已经配置好 GitHub SSH key，并且希望附属仓库也走 SSH，就保留这个参数
- `--use-zprofile-template`
  作用：把仓库里的 demo `zprofile` 链接到 `~/.zprofile`
  什么时候加：只有你明确要使用这个 demo 文件时才加；如果你要保留自己的登录配置，就不要加

常用组合命令：

```shell
# 开发者默认方式：SSH + demo zprofile
./mse deploy --ssh --use-zprofile-template

# 自己选 step，但保留自己的 ~/.zprofile
./mse deploy --ssh --interactive

# 自己选 step，并且同时使用 demo zprofile
./mse deploy --ssh --interactive --use-zprofile-template
```

### 更新

更新时直接执行：

```shell
./mse update

# 临时覆盖上次 deploy 保存的设置
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
- 不会再次执行 `chsh`，也不会要求你输入默认 shell 的密码
- 如果你上次 `deploy` 用的是 interactive mode，`update` 会直接复用上次保存的 step 选择，不再重新逐项提问
- 这些持久化设置保存在仓库根目录的 `~/.my_shell_envs/.mse-install.env`
- 每次成功执行 `mse deploy` 或 `mse update` 后，这个文件都会按本次实际使用的配置重写

`~/.my_shell_envs/.mse-install.env` 是普通文本文件，可以手动修改。格式示例：

```shell
MSE_GIT_METHOD='ssh'
MSE_DEPLOY_MODE='fast'
MSE_DEFAULT_BRANCH='main'
MSE_USE_ZPROFILE_TEMPLATE='false'
MSE_STEP_MICROMAMBA='true'
MSE_STEP_CONDARC='true'
MSE_STEP_PIP='true'
MSE_STEP_VIM='true'
MSE_STEP_NVIM='true'
MSE_STEP_JCAT='false'
MSE_STEP_WD='true'
MSE_STEP_CODE_NOTIFY='true'
```

这些字段的含义：

- `MSE_GIT_METHOD`：update 默认用 HTTPS 还是 SSH
- `MSE_DEPLOY_MODE`：update 默认按 fast 还是 interactive 的部署方式走
- `MSE_DEFAULT_BRANCH`：当前这份安装配置对应的默认分支信息
- `MSE_USE_ZPROFILE_TEMPLATE`：update 时是否继续使用仓库里的 demo `~/.zprofile`
- `MSE_STEP_<NAME>`：每个可选 step 是否启用，`update` 会直接按这里的 `true/false` 执行，不再重新询问

如果你想改默认行为，有两种方式：

- 直接手改 `~/.my_shell_envs/.mse-install.env`
- 重新执行 `mse deploy --interactive`

如果你手动改了这个文件，下一次执行 `mse update` 就会按你修改后的值执行。你也可以直接在命令行传参数；只要这次执行成功，`.mse-install.env` 就会同步更新成这次实际使用的配置。

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
- 在 Windows 上，如果仓库里存在 `tools/micromamba/Windows/micromamba-win-64.exe`，会优先直接复用这份本地备份，避免 TLS / 代理问题导致的在线安装失败

它不会自动创建所有环境。部署完成后，需要你自己执行 `conda` 命令。

当前平台的 `base.yml` 会链接到：

```shell
~/.my_shell_envs/conda_local_env_settings/base.yml
```

要在 PowerShell 中重建或更新 `base` 环境，直接执行：

```shell
conda env update -n base -f ~/.my_shell_envs/conda_local_env_settings/base.yml --prune
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
export PATH="$HOME/.local/bin:$PATH"

# add extra toolchain paths only when they exist
[ -d "/opt/homebrew/bin" ] && export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
```

如果你使用仓库默认的 `Rust` 安装方式，不需要手工把 `~/.cargo/bin` 写进 `~/.zprofile`。仓库的 `zsh/zshrc` 会在检测到 `cargo` 存在时自动把它加入 PATH。

写 `PATH` 时注意：

- 一定要保留 `$PATH`，不要写成 `export PATH="/some/path"` 这种覆盖式写法
- 这样系统已有命令、仓库里的 `~/.my_shell_envs/bin`、以及 `zsh/zshrc` 后续追加的内容都不会丢
- 优先把你自己的 bin 目录放在前面，例如 `~/.local/bin`
- 在这个仓库里，通常不需要在 `~/.zprofile` 里手动加入 `micromamba/bin`，因为仓库的 `zsh/zshrc` 已经会处理 `micromamba` / `conda`
- 只有当你明确希望在 `zsh/zshrc` 执行之前就能直接使用 `micromamba` 时，才自己把它加到 `~/.zprofile`
- 对平台相关路径做存在性判断，避免在别的机器上报错
- 除非你非常确定后果，否则不要随意 `unset PATH`

一个最小可用的 `~/.zprofile` 示例：

```shell
# keep existing PATH
export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export PAGER="less"
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

如果你在交互模式里选择配置 `wd`，MSE 会：

- clone 或 update `~/.Wudao-dict`
- 直接生成可执行文件 `~/.my_shell_envs/bin/wd`
- 这个 `wd` 命令会进入 `~/.Wudao-dict/wudao-dict` 并执行词典程序

如果你在交互模式里没有选择 `wd`，MSE 会删除 `~/.my_shell_envs/bin/wd`，避免 PATH 里残留一个你并不想保留的命令。

![](https://pic1.zhimg.com/v2-4941f3b7b7c83780d50bcfb36b6dbad8_b.jpg)

### 6. 其他小工具

还包含一些我日常会用的小功能：

- 一个“回收站式”的删除机制，避免误用 `rm -rf`
- `l` / `ll` / `lll` / `llll` 这些更顺手的目录查看命令
- `open` 等常用别名
- `conda/micromamba-pycharm`：给 PyCharm 用的 micromamba 兼容桥接，让 PyCharm 可以把 micromamba 当成 conda 可执行文件
- 可以通过在 `~/.my_shell_envs/bin` 下建立软链接，把你自己的命令加入 PATH

### 7. code-notify

macOS 终端通知工具，参考项目：

- [code-notify](https://github.com/mylee04/code-notify)

如果你在 macOS 上部署时选择了 `code_notify`，MSE 会：

- 通过 Homebrew 安装 `code-notify`
- 设置提示音为 `Blow.aiff`
- 添加 `permission_prompt` 和 `auth_success` 两种 alert
- 启用通知

交互式部署中你可以跳过这一步。Windows / Linux 上该步骤自动忽略。

## 贡献

欢迎提交 Issue 和 Pull Request。

如果你发现了 bug、兼容性问题、文档缺失，或者希望补充新的环境模块，都可以直接在仓库中发起讨论或提交修改。

一个最基础的贡献流程如下：

1. 先在 GitHub 上 fork 本仓库到你自己的账号下。
2. 把你自己的 fork 克隆到本地。

```shell
cd "$HOME"
git clone git@github.com:<your-github-name>/.my_shell_envs.git
cd ~/.my_shell_envs
```

3. 在本地部署你自己的 fork，确认修改能实际跑通。

```shell
./mse deploy
```

4. 修改代码或文档，反复调试，直到你本地用起来没问题。
5. 把修改提交到你自己的 fork。
6. 在 GitHub 上从你的 fork 发起一个 PR，请求合并到本仓库。

如果你只改文档，也欢迎直接提 PR。

如果你不确定改动方向，也可以先开 Issue 讨论。

非常欢迎大家一起维护这个仓库。

## 许可证

自由使用，按需修改。
