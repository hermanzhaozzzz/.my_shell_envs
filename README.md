# My Shell Env (MSE)

[简体中文](README.md) | [English](docs/README.en.md)

一条命令搭好终端环境：zsh、编辑器、micromamba、常用 CLI，以及 Slurm 集群代理。**Linux（含 WSL）与 macOS 共用同一套配置**，换机器一条命令重建。

这篇文档只需要记住三件事：

1. **快速开始**：装好就能用
2. **定制自己的配置**：个人设置写在哪，怎么和仓库的公共配置共存
3. **日常命令速查**：最常用的命令

其余（部署参数、功能细节、集群代理、测试）都是次要信息，需要时再查。

## 快速开始

Linux / macOS 先装依赖：

```shell
# Debian / Ubuntu
sudo apt install -y git zsh build-essential pkg-config

# macOS
xcode-select --install      # zsh 系统自带
```

然后：

```shell
git clone https://github.com/hermanzhaozzzz/.my_shell_envs.git ~/.my_shell_envs
cd ~/.my_shell_envs
./mse deploy
```

装完执行 `exec zsh`。之后 `mse` 已在 PATH，可直接运行 `mse deploy` / `mse update`；默认安装全部模块，换协议或只装一部分见「部署与更新」。

## 定制自己的配置

**你只需要改 `~/.zprofile`。**

| 文件 | 放什么 | 更新行为 |
|---|---|---|
| `~/.zprofile` | 你的机器、路径、代理参数等**个人**配置 | 不随 MSE 更新，`deploy` / `update` 默认不改动它 |
| `~/.zshrc` | 仓库统一管理的公共交互逻辑（软链到 `${HOME}/.my_shell_envs/zsh/zshrc`） | 随 MSE 更新，仓库一变它就跟着变，等于强制覆盖 |

直接改 `~/.zshrc` 会丢——下次更新就被仓库内容覆盖了。

zsh 加载顺序：

```text
.zshenv -> .zprofile -> .zshrc -> .zlogin -> .zlogout
```

- `~/.zshenv`：所有 zsh 进程都读；会影响 `scp` 等非登录 / 非交互连接的行为，**尽量少放**
- `~/.zprofile`：登录 shell 先读，只影响登录交互式 shell；**推荐在这里维护你的个人 DIY 配置**（PATH、代理端口、主机相关变量）
- `~/.zshrc`：交互式 shell 读；**这是 MSE 通用配置的实现位置，不要修改**
- `~/.zlogin` / `~/.zlogout`：登录收尾 / 退出时读；可以用，按场景选择，**一般很少使用**

不要在 `~/.zprofile` 里重新定义仓库提供的命令，尤其是 `proxy.on` / `proxy.off`。

### 写自己的 `~/.zprofile`

可以什么都不写——所有默认值都在仓库的 `zsh/zshrc` 里。下面**全部是可选的示例**，按需保留或删掉：

```shell
# 示例：个人偏好，不加也完全没问题
export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"

# 示例：覆盖 MSE 默认行为
# 默认为 false：不自动激活 micromamba 的 base 环境，
#   base 里装的 conda / python 等命令不会出现在 PATH 上
# 改成 true：每个新 shell 自动执行 micromamba activate base，命令更方便但会影响终端启动速度
export MSE_MAMBA_AUTO_ACTIVATE_BASE=true
```

保存后新开的终端就会生效。集群代理相关变量见「集群代理」一节，普通机器不用配。

### 常用变量

| 变量 | 作用 | 示例 |
|---|---|---|
| `MSE_ZSH_THEME` | 覆盖默认主题；默认 `fino`，可用主题见 [Themes](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes) | `export MSE_ZSH_THEME="agnoster"` |
| `MSE_ZSH_PLUGINS` | 整体替换默认插件列表；默认 `git z zsh-syntax-highlighting zsh-autosuggestions`，可用插件见 [Plugins](https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins) | `export MSE_ZSH_PLUGINS="git z"`：只用这两个<br>`export MSE_ZSH_PLUGINS="git z zsh-syntax-highlighting zsh-autosuggestions docker"`：默认四个 + docker |
| `MSE_MAMBA_AUTO_ACTIVATE_BASE` | 新 shell 是否自动激活 micromamba 的 base 环境；默认 `false`，设为 `true` 会影响终端启动速度 | `export MSE_MAMBA_AUTO_ACTIVATE_BASE=true` |
| `MSE_PROXY_MODE` | 两段式：登录端+计算端。登录端可选 `clash`/`origin`，计算端可选 `clash`/`via-login`/`origin`；常用组合见「集群代理」 | `export MSE_PROXY_MODE=clash+via-login` |

### 维护者的个人配置（`--maintainer-personal-zprofile`）

`deploy` 的这个开关会把维护者本人的 `zsh/zprofile_hermanzhaozzzz_demo` 直接当作 `~/.zprofile` 使用；启用前会先备份已有的 `~/.zprofile`。等价于：

```shell
ln -s ~/.my_shell_envs/zsh/zprofile_hermanzhaozzzz_demo ~/.zprofile
```

- 维护者本人：可以用
- 其他用户：**不要直接用**，只当写法的参考（PATH、代理模式、目录约定），自己写 `~/.zprofile`
- 不加这个参数时，`deploy` **不会**改动你的 `~/.zprofile`
- 这个文件写死了维护者的机器路径、集群主机名和代理参数

## 日常命令速查

| 想做的事 | 命令 |
|---|---|
| 部署 / 更新 | `mse deploy` / `mse update` |
| 开代理 / 关代理 / 看状态 | `proxy.on` / `proxy.off` / `proxy.status` |
| 测代理连通性 | `proxy.test` |
| 强制命令走代理 | `proxy.exec <命令>` |
| 删除文件（进回收站） | `rm <路径>` |
| 真删除 | `rrm <路径>` |
| 看 / 恢复 / 清空回收站 | `rm.trash.show` / `rm.trash.back` / `rm.trash.clear` |
| 管理 Conda 环境 | `conda`（已别名到 `micromamba`） |
| 查看 Slurm（Linux） | `sqtop` |

## 部署与更新

### `mse deploy`

默认：**`fast` 模式 + `https`**，安装所有支持的模块。

| 想改变什么 | 加什么参数 |
|---|---|
| 只装一部分模块 | `--interactive` |
| 用 SSH 拉仓库 | `--ssh` |
| 两个都改 | `--ssh --interactive` |

参数可自由组合、顺序无关；`--fast` 与 `--interactive` 同时出现时，最后一个生效。维护者专用的 `--maintainer-personal-zprofile` 见「定制自己的配置」。

Linux 和 macOS 命令相同。Windows 用 PowerShell + git-bash：

```powershell
git clone https://github.com/hermanzhaozzzz/.my_shell_envs.git $HOME/.my_shell_envs
cd $HOME/.my_shell_envs
git-bash ./mse deploy
```

部署会尝试 `chsh -s "$(which zsh)"`；不想改默认 shell 就在密码提示时回车。

做这些事：

- 把 `~/.zshrc` 链接到 `${HOME}/.my_shell_envs/zsh/zshrc`
- 安装或接入 `oh-my-zsh` 和插件
- 安装 `micromamba`
- 处理 `vim` / `neovim`
- 构建仓库托管的 CLI 工具
- 按 step 安装额外模块

覆盖已有文件前会备份成 `<原名>_bak`；如果旧备份已存在，会被覆盖，日志里会提示。

### `mse update`

```shell
mse update
```

流程：

1. 先 fetch 上游
2. 如果本地有未提交的改动，或有本地提交不在上游，询问你是否以上游为准
3. 输入 `y`：丢弃本地内容，`reset --hard` 到上游
4. 输入 `n`：退出，让你自己检查仓库
5. 非交互环境：直接退出，不做任何改动

更新完成后会按上次保存的配置重新部署，但不会再要求你改默认 shell。

`--https` / `--ssh` 会把 GitHub origin 转成对应协议再 fetch，不是只影响后续 clone。无法安全转换的非 GitHub origin 会直接报错，不会悄悄换协议。

Vim、Neovim、Wudao 这些独立 Git 仓库如有本地修改，deploy 只警告并跳过它的 pull，不会 stash、回滚或覆盖。

### `.mse-install.env`

记录最近一次成功部署的参数和 step 开关：

```shell
MSE_GIT_METHOD='ssh'
MSE_DEPLOY_MODE='fast'
MSE_MAINTAINER_PERSONAL_ZPROFILE='false'
MSE_STEP_NVIM='true'
MSE_STEP_SQTOP='true'
MSE_STEP_CLASHCTL='true'
MSE_STEP_CLUSTER_PROXY_TOOLS='true'
```

`mse update` 会复用它，所以结果可能和一次全新的 `mse deploy --fast` 不同。改默认行为有两种方式：重新跑 `mse deploy --interactive`，或直接编辑这个文件。

## 功能

### Zsh

默认启用 Oh My Zsh、`git`、`z`、`zsh-syntax-highlighting`、`zsh-autosuggestions`。

`htop` 已别名到 `btop`；`eza` 提供 `ll` / `lll` 等列表别名。

### micromamba

`conda` / `mamba` 都别名到 `micromamba`，日常直接用 `conda`。

Linux 和 macOS 统一安装在 `$HOME/0.apps/micromamba`：

| 项目 | 路径 |
|---|---|
| 可执行文件 | `$HOME/0.apps/micromamba/bin/micromamba` |
| base 环境 | `$HOME/0.apps/micromamba` 本身 |
| 命名环境 | `$HOME/0.apps/micromamba/envs/<name>` |
| 根前缀 | `MAMBA_ROOT_PREFIX=$HOME/0.apps/micromamba` |

### Vim / Neovim

- Vim 配置参考 [vim-for-coding](https://github.com/Leptune/vim-for-coding)
- Neovim 配置参考 [MyLazyVim](https://github.com/hermanzhaozzzz/MyLazyVim)

### 回收站（`rm` 包装）

交互式 zsh 里 `rm` 不真删，而是移动到回收站：

```shell
rm <路径>          # 移入回收站；-rf 等选项会被忽略
rrm <路径>         # 真正的删除（/bin/rm）
rm.trash.show      # 查看所有回收站
rm.trash.back      # 恢复到当前目录（多个回收站时先选编号）
rm.trash.clear     # 清空所有回收站（会先确认）
```

回收站按磁盘分开：同盘 `mv` 只是 rename，跨盘才会真的复制。默认只有 `$HOME/.mytrash`；要多盘各放一个，在 `~/.zprofile` 里声明：

```shell
TRASH_DIRS=(
    "${HOME}/.mytrash"               # 本机
    /lustre1/cqyi/hnzhao/.mytrash    # 集群 A /lustre1
    /lustre2/cqyi/hnzhao/.mytrash    # 集群 A /lustre2
)
```

删除时选择与目标同一设备上的第一个回收站；都不匹配就回退 `$HOME/.mytrash`，并提示跨盘复制。

**注意**：这是交互式 zsh 别名。脚本、cron、`sbatch --wrap` 里 `rm` 仍然是真删除。

### jcat

终端里快速查看 `ipynb`。参考 [jcat](https://github.com/zhifanzhu/jcat)。

### wd

终端词典工具。参考 [Wudao-dict](https://github.com/ChestnutHeng/Wudao-dict)。

### macupdatectl

macOS 系统更新控制工具（macOS 12+）：

```shell
macupdatectl          # 打开图形菜单
macupdatectl status   # 查看状态
```

菜单可以屏蔽系统更新、恢复检查与手动更新（黑苹果推荐）、清除更新小红点。“屏蔽”会关闭软件更新服务、相关自动更新选项，并在 `/etc/hosts` 的受管区块阻断 Apple 更新服务器；修改前会备份到 `/var/backups/macupdatectl/`。

### sqtop

Linux 上可选的 Slurm 终端监控工具，类似 `htop` / `nvitop`。`deploy --fast` 默认安装；`--interactive` 时可单独决定。

## 集群代理（速查）

compute 节点通常不联网。先看流量怎么走：

### 前置条件

`proxy.on` / `proxy.test` / `proxy.exec` 需要：

- 部署时启用 `cluster_proxy_tools`（提供 `autossh`、`proxychains`）
- 选了 `clash`（任意一端）：`clashctl` 已部署，**至少添加了一个订阅**，runtime 里有 HTTP 和 SOCKS 端口
- 只选 `via-login`：不需要 Clash 和订阅，但 login 节点本身必须能上网
- macOS / WSL：本地代理客户端在运行

其中 `proxy.test` / `proxy.exec` 还要求当前节点有代理：登录节点要求登录端为 `clash`；计算节点要求计算端为 `clash` 或 `via-login`。计算端为 `origin`、以及登录端为 `origin` 的登录节点都没有代理。

### 按场景选择

| 场景 | login 节点 | 计算节点 | 配置 |
|---|---|---|---|
| 中国大陆，login 跑 Clash | 走 Clash，按规则分流 | 经 SSH 隧道到 login 的 Clash 端口 | `MSE_PROXY_MODE=clash+via-login`（默认），执行 `proxy.on` |
| 登录端跑 Clash，计算节点自己有外网 | 走 Clash | 走自己的网络 | `MSE_PROXY_MODE=clash+origin`，执行 `proxy.on` |
| 计算节点自己有外网，想在本节点跑 Clash | 按登录端需要 | 本地 Clash | `MSE_PROXY_MODE=clash+clash` 或 `origin+clash` |
| login 能直接上网，计算节点不能 | 走自己的网络 | 经 SSH 隧道到 login，再由 login 直接出网 | `MSE_PROXY_MODE=origin+via-login`，执行 `proxy.on`（端口自动选） |
| 计算节点本身就有外网 | 走自己的网络 | 走自己的网络 | `MSE_PROXY_MODE=origin+origin`，不需要执行 `proxy.on` |

### 每种取值的行为

| `MSE_PROXY_MODE` | 登录节点 | 计算节点 |
|---|---|---|
| `clash+via-login`（默认） | 走 Clash，按规则分流 | 经 SSH 隧道到 login 的 Clash 端口 |
| `clash+clash` | 走 Clash | 在计算节点本地跑 Clash（需节点自己上网） |
| `clash+origin` | 走 Clash | 走自己的网络 |
| `origin+via-login` | 走自己的网络 | 经 SSH 隧道到 login，再由 login 直接出网 |
| `origin+clash` | 走自己的网络 | 在计算节点本地跑 Clash（需节点自己上网） |
| `origin+origin` | 走自己的网络 | 走自己的网络 |

计算节点选 `clash` 时会在本节点启动 Clash（前提是节点本身能上网）；选 `via-login` 则不跑 Clash，只经隧道借用 login 的出口。

macOS 不区分 login / compute：启动代理客户端后 `proxy.on`，自动识别端口。WSL 按 Linux 逻辑处理；只有 Windows 侧的端点发现依赖 PowerShell interop。

最短流程：

```shell
proxy.status                 # 看当前状态和节点角色
proxy.on                     # 开代理（compute 节点会建 autossh 隧道）
proxy.test                   # 测常见站点
proxy.exec codex             # 让不认环境变量的程序也走代理
proxy.off                    # 只清当前 shell，不停 Clash 服务
```

三个常见坑：

- 「开了 `proxy.on` 但不通」先看 `proxy.status` 里的 `proxy upstream` 对不对
- VSCode Remote 进 compute 节点时 upstream 推断会失效，在 `~/.zprofile` 固定 `MSE_PROXY_UPSTREAM_HOST=login03`
- Go 程序（如 `frp-panel`）绕过系统 DNS，`proxychains` 拦不住，用 IP 代替域名

完整说明（clashctl 安装、订阅、runtime、端点发现、upstream 推断、限制与排错）见 **[docs/proxy.md](docs/proxy.md)**。

## 测试

不需要真实订阅、Mihomo 服务或外网，测试用临时目录：

```shell
./tests/run.sh
```

覆盖部署选择、更新行为、端口同步、Slurm 角色分流、clashctl 生命周期和回收站。

## 贡献

欢迎 Issue 和 PR。流程：

```shell
cd "$HOME"
git clone git@github.com:<your-github-name>/.my_shell_envs.git
cd ~/.my_shell_envs
./mse deploy
```

确认本地可用后提交修改。

## 许可证

自由使用，按需修改。
