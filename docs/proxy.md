# Cluster Proxy 详细说明

README 里的集群代理部分只保留速查；这里放完整细节。

适用场景：Slurm compute 节点本身不联网，但你还想继续用 `curl`、`git`、`codex`、`claude` 这些需要网络的工具。

`cluster_proxy_tools` step 会接入：

- `autossh`
- `proxychains-ng`
- `proxy.on` / `proxy.off` / `proxy.status` / `proxy.test` / `proxy.exec`

`mse deploy --fast` 默认启用这个 step。

## 先选模式

### 取值与行为

| `MSE_PROXY_MODE` | 登录节点 | 计算节点 |
|---|---|---|
| `clash+via-login`（默认） | 走 Clash，按规则分流 | 经 SSH 隧道到 login 的 Clash 端口 |
| `clash+clash` | 走 Clash | 在计算节点本地跑 Clash（需节点自己上网） |
| `clash+origin` | 走 Clash | 走自己的网络 |
| `origin+via-login` | 走自己的网络 | 经 SSH 隧道到 login，再由 login 直接出网 |
| `origin+clash` | 走自己的网络 | 在计算节点本地跑 Clash（需节点自己上网） |
| `origin+origin` | 走自己的网络 | 走自己的网络 |

计算节点选 `clash` 时会在本节点启动 Clash（前提是节点本身能上网）；选 `via-login` 则不跑 Clash，只经隧道借用 login 的出口。

### 按场景选择

| 场景 | login 节点 | 计算节点 | 用什么 |
|---|---|---|---|
| Linux / WSL，中国大陆，login 跑 Clash | 走 Clash，按规则分流 | 经 SSH 隧道到 login 的 Clash 端口 | `MSE_PROXY_MODE=clash+via-login` + 仓库内 `clashctl` |
| 登录端跑 Clash，计算节点自己有外网 | 走 Clash | 走自己的网络 | `MSE_PROXY_MODE=clash+origin`，执行 `proxy.on` |
| 计算节点自己有外网，想在本节点跑 Clash | 按登录端需要 | 本地 Clash | `MSE_PROXY_MODE=clash+clash` 或 `origin+clash` |
| Linux / WSL，海外或校园网：login 能直接上网 | 走自己的网络 | 经 SSH 隧道到 login，再由 login 直接出网 | `MSE_PROXY_MODE=origin+via-login` |
| 计算节点本身就有外网 | 走自己的网络 | 走自己的网络 | `MSE_PROXY_MODE=origin+origin`，不执行 `proxy.on` |

WSL 按 Linux 逻辑处理；只有 Windows 侧的端点发现依赖 PowerShell interop 和 `wslpath`。macOS 不区分 login / compute，自动识别系统代理。

## clash+via-login（登录端 Clash）

前提：

- login 节点本身能联网
- login 节点上已经打开 Clash
- `clashctl runtime.yaml` 中同时存在有效的 HTTP 和 SOCKS 端口

仓库只负责把请求接到 login 节点上的 Clash。`baidu`、`google`、`gpt`、`claude` 这些请求最后怎么走，全部由 Clash 的规则决定；这个仓库不负责流量分流。

### 安装位置

原生 Linux 上，`mse deploy --fast` 会执行 `clashctl` step。控制脚本、Web UI 和基础资源放在仓库的 `tools/clashctl` 中；`mihomo` 和 `subconverter` 会按当前 CPU 架构安装到仓库的 `bin` 中：

```shell
~/.my_shell_envs/bin/mihomo
~/.my_shell_envs/bin/subconverter/subconverter
```

`yq` 只是 clashctl 的私有运行依赖，默认安装到不进入 `PATH` 的 `libexec` 目录，避免平时整理仓库 `bin` 时误删：

```shell
~/.local/libexec/mse-clashctl/yq
```

如需改到其它位置，可在部署时设置 `MSE_CLASHCTL_YQ_BIN`；deploy 会把最终路径写入 `tools/clashctl/state/env`。

订阅、token、生成的 `runtime.yaml`、日志和下载缓存同样留在仓库目录内，但被 Git 忽略：

```shell
~/.my_shell_envs/tools/clashctl/state
~/.my_shell_envs/tools/clashctl/cache
```

deploy 不读取或兼容 `$HOME/clashctl` 等旧安装路径，也不会覆盖已经生成的 state。

### 首次订阅

```shell
exec zsh
clashctl sub add --use '<subscription-url>'
proxy.on
```

`clashctl add '<subscription-url>'` 是“添加并立即使用”的快捷命令；同一 URL 已存在时会安全更新现有订阅。`clashctl del <id>` 会先停止 Mihomo 并清理 runtime，不保留旧端口或配置 fallback。

订阅下载默认使用 `clash-verge/v2.3.1` User-Agent，以便服务商下发 AnyTLS 等现代 Mihomo 协议。deploy 会把该值写入 `tools/clashctl/state/env`；可在部署时设置 `MSE_CLASHCTL_SUB_UA` 覆盖。

### 常用命令

```shell
clashctl status   # 查看 Clash 内核状态
clashctl on       # 开启 Clash
clashctl off      # 关闭 Clash
clashctl ui       # 查看 Web 面板地址
```

`clashctl on` 会覆盖当前 shell 里的 `http_proxy`、`https_proxy`、`all_proxy`、`no_proxy` 及其大写版本。仓库的 `proxy.on` / `proxy.off` 管理同一组变量：`http_proxy` / `https_proxy` 指向 HTTP 端口，`all_proxy` 指向 SOCKS 端口。

### 端口与 runtime

原生 Linux `clash` 模式下，`zsh/zshrc` 会从 `clashctl` 的 `runtime.yaml` 分别读取 HTTP 和 SOCKS 端口，并无条件覆盖同名环境变量。runtime 缺失、端口不完整或不可读时，`proxy.*` 直接失败，不使用手工端口。

**不要**在 `clash+via-login` 模式下配置 `MSE_PROXY_PORT` 或 `MSE_PROXY_SOCKS_PORT`；需要改变端口时修改 clashctl 配置并重新生成 runtime。

Slurm compute 节点读取共享仓库里的同一份 runtime，只把本地对应端口转发到 login 节点，不执行 `clashctl on/off`。

### 符号链接与物理路径

如果 `~/.my_shell_envs` 本身是指向共享文件系统的符号链接或逻辑路径，clashctl 会先解析为同一个物理仓库路径，再派生 binary、state 与 pid 身份，避免同一 Mihomo 被逻辑路径和物理路径误判为两个服务。

### 部署顺序与预检

Linux deploy 会先完成 clashctl，再执行需要 GitHub/Rust 网络的公共安装。已有有效 runtime 时，deploy 会先自动启用它，再更新 clashctl 程序并把代理用于后续步骤；本地安装归档完整时也可以离线重装。

真正的首次部署既没有 runtime、没有完整归档、又无法直连外网时：

- 交互模式会在任何下载之前暂停，提示你临时打开当前终端可用的外网
- 非交互模式会立即停止

clashctl 安装完成后，如果仍无订阅且无法访问外网，交互模式会再提示你在另一终端执行仓库 `bin/clashctl add '<subscription-url>'`。这两道预检都不会悄悄回退到其它 Linux 代理实现。

## origin+via-login（经 login 出网）

前提：

- login 节点本身能联网
- 你不需要 Clash

compute 节点会用 `autossh -D` 在本地开一个 SOCKS5 端口，然后直接借 login 节点出网。

长期设置必须写进 `~/.zprofile`，因为 `origin+via-login` 不依赖 `clashctl runtime.yaml`：

```shell
export MSE_PROXY_MODE=origin+via-login
# 可选：固定端口；不写时 `proxy.on` 会自动选一个 >10000 的空闲端口
# export MSE_PROXY_PORT=<local-socks-port>
```

不设置 `MSE_PROXY_PORT` 时，`proxy.on` 会自动在 10001–60000 中挑一个空闲端口，并在当前会话导出。需要固定端口（例如已有脚本或配置引用它）时再手动指定。`proxy.on` 会用 `autossh -D 127.0.0.1:<port>` 建立动态 SOCKS 隧道。

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

这个模式下 `proxy.exec` 更稳，因为它直接用 `proxychains-ng` 套住命令。

## `proxy.exec` 怎么用

很多程序在 `proxy.on` 之后就能直接用，因为它们会读：

- `http_proxy` / `https_proxy` / `all_proxy`
- `HTTP_PROXY` / `HTTPS_PROXY` / `ALL_PROXY`

有些程序不认这些环境变量，或者你只是想强制它走代理，这时用 `proxy.exec`。

仓库会把 `all_proxy` / `ALL_PROXY` 设成 `socks5h://127.0.0.1:${MSE_PROXY_SOCKS_PORT}`，优先让支持 SOCKS5h 的客户端把域名解析交给代理端，而不是让 compute 节点本地先做 DNS。这样统一的是 `git`、`curl`、`pip`、`conda`、Python HTTP 客户端等一批常见 CLI 的 DNS 行为。

```shell
proxy.exec curl -I https://www.google.com
proxy.exec git ls-remote https://github.com/rofl0r/proxychains-ng.git
proxy.exec codex
proxy.exec claude
```

## 代理命令语义

`proxy.on` / `proxy.off` / `proxy.status` 是低门槛入口：

- direct/login 节点：`proxy.on` 等价于 `clashctl on` 加仓库自己的端口同步和环境变量整理
- direct/login 节点：`proxy.off` 等价于 `clashctl off -e` 加仓库自己的环境变量清理，不停止 Clash 服务
- compute 节点：`proxy.on` / `proxy.off` 只负责 autossh 隧道，不直接控制 Clash 服务
- `proxy.status` 保留仓库状态信息，并在 direct/login 节点附带 `clashctl status`

MSE 不读写全局 Git 代理配置。compute 节点的 `proxy.on` 只在当前 shell 临时设置 `GIT_SSH_COMMAND`；`proxy.off` 会恢复原值，而不是无条件删除用户已有配置。

## proxy.test

Linux 上会依次测试这些地址，每个显示 OK 或 FAIL：

```text
== curl via env proxy ==
  OK              baidu.com (HTTP 200)
  OK              google.com.hk (HTTP 200)
  OK              openai (HTTP 421)
  OK              claude (HTTP 403)
```

对应地址是 `baidu.com`、`google.com.hk`、`api.openai.com`、`api.anthropic.com`。macOS / WSL 的 `proxy.test` 对每个已识别的 HTTP、SOCKS 协议分别请求 `example.com` 的 HTTP 和 HTTPS 地址，忽略 curl 配置和绕过规则。

## 自动启用

- **macOS**：新终端读取 `scutil --proxy` 中已启用的 HTTP / HTTPS / SOCKS 配置，结合本地 `lsof` 监听进程归属设置大小写代理变量，避免混用不同客户端。启动不运行 curl、不联网探测；没有可用系统配置时保持 off，手动 `proxy.on` 仍可通过客户端监听端口发现并验证代理。
- **Linux（含 WSL）**：新终端一律保持 off，并清除继承的大小写代理环境变量。启动不调用 `clashctl` 或 `autossh`；需要时手动 `proxy.on`。WSL 启动时同样不探测 Windows 或本地代理。

`proxy.on`、`proxy.status`、`proxy.test`、`proxy.exec` 执行时重新识别；打开终端时不进行网络探测。代理已开启时，`proxy.status` 会同步刷新大小写环境变量；关闭状态下只显示发现结果。

## 端点发现与验证

手动执行 `proxy.on` 时的自动识别顺序：

- macOS：先读取 `scutil --proxy` 中启用的系统代理；不可用时，通过 `lsof` 查找 Surge、ClashX、FlClash 及 mihomo、sing-box 等内核的 TCP 监听端口。
- WSL：通过 Windows PowerShell 读取当前用户的系统代理和代理进程监听端口，也支持 WSL 内运行的代理内核。Windows loopback 地址会依次尝试本地 loopback 和 WSL 默认网关，以兼容 mirrored / NAT 网络。

对候选端口分别验证 HTTP CONNECT 和 SOCKS5h；不会仅因端口开放就认为它是代理，也不会把 HTTP-only 端口当成 SOCKS。HTTP-only、SOCKS-only、分离端口和混合端口均可使用；macOS 系统端点按监听进程分组，并补充同一进程的其他代理端口，不拼接两个无关客户端。

协议验证通过 `curl` 访问 `example.com`，需要代理能连通该站点；单次探测最多 2 秒，候选端点去重后逐一检查。macOS 需要系统的 `scutil` / `lsof`；WSL 的 Windows 发现需要 PowerShell interop 和 `wslpath`。

不执行 PAC 脚本，也不自动处理需要账号密码的代理；PAC/TUN 客户端若同时提供可识别的本地代理监听，仍可使用进程发现。没有可用候选时给出诊断，不要求填写覆盖变量。

WSL NAT 下如果 Windows 客户端只监听 Windows localhost 或被防火墙阻挡，需要在客户端允许 WSL 访问，或使用 mirrored 网络。

## Upstream 推断与 VSCode Remote

当前自动判断规则：

- `login*` 按 login/direct 处理
- 其他 `c*b*n*` 按 compute 处理
- `MSE_PROXY_DIRECT_HOSTS` 里的主机名也按 login/direct 处理

compute 节点上的 `proxy.on` 不只看本地端口是否在监听，还会做一次真实代理探测：

- 旧 autossh 进程还在、但上游 `127.0.0.1:${MSE_PROXY_PORT}` 不可用时，判定为坏隧道并重建
- 自动猜出的第一个上游不可用时，继续尝试后续候选

上游候选顺序：

1. `MSE_PROXY_UPSTREAM_HOST`（显式覆盖，一般不用设）
2. `SLURM_SUBMIT_HOST`
3. Slurm 作业的 `SubmitHost`（`scontrol show job`）
4. `SSH_CONNECTION` / `SSH_CLIENT` 反查到的主机
5. `MSE_PROXY_DIRECT_HOSTS` 里的主机

反查受 `MSE_PROXY_HOST_LOOKUP_TIMEOUT` 限制；查找旧 autossh 隧道时直接读取 `/proc`，受 `MSE_PROXY_PROCESS_LOOKUP_TIMEOUT` 限制；启动 autossh 受 `MSE_PROXY_SSH_CONNECT_TIMEOUT` 限制，并使用非交互 SSH，避免长时间等待。

每个 compute 主机的 MSE 隧道 PID 和完整命令记录在 `tools/clashctl/state/proxy-tunnels`（Git 忽略）。`proxy.on` 启动前与 `proxy.off` 关闭时都会清理当前主机的 stale state、旧端口隧道和旧版 MSE 隧道；匹配不到 MSE 完整特征的其他 autossh/SSH 隧道不会被处理。

在 VSCode Remote SSH 里再打开 compute 节点的 Terminal 时，`SSH_CONNECTION` 往往只显示 `127.0.0.1 -> 127.0.0.1` 的本地转发，但这种情况下 Slurm 的 `SLURM_SUBMIT_HOST` / `SubmitHost` 通常仍能给出 login 节点。只有当这些信息都缺失时，才需要在 `~/.zprofile` 里固定写：

```shell
export MSE_PROXY_UPSTREAM_HOST=login03
```

之后直接：

```shell
proxy.on
proxy.status
git fetch
```

只要 `proxy.status` 里的 `proxy upstream` 是你期望的 login 节点，后面的 `git` 操作就会沿同一条链路工作。

区分两个变量：

- `MSE_PROXY_UPSTREAM_HOST=login03 proxy.on`：这一次不要自动猜上游，明确回连 `login03`
- `MSE_PROXY_DIRECT_HOSTS="c55b01n08" proxy.on`：这一次把 `c55b01n08` 当成 direct/login-like 主机，不识别成 compute

如果这些候选都不对，优先检查 `proxy.status` 里的 upstream，或临时设置 `MSE_PROXY_DEBUG=1` 后重跑 `proxy.on` 查看推断过程。

## compute 节点上的 git

compute 节点 DNS 无法解析外网域名（如 `ssh.github.com`），SSH 不走 `http_proxy`。`proxy.on` 会在 compute 节点自动设置 `GIT_SSH_COMMAND`，通过 SOCKS5 代理路由 git SSH 流量，`git push` / `git pull` 可以直接使用。它优先使用支持 `-X 5 -x` 的 OpenBSD `nc`，不可用时再使用 `ncat`。

如果想把 SSH 代理扩展到其他 SSH 命令，可以在自己的 `~/.ssh/config` 里加：

```sshconfig
Host github.com ssh.github.com
    ProxyCommand ncat --proxy 127.0.0.1:<clash-socks-port> --proxy-type socks5 %h %p
```

只有 OpenBSD `nc` 时：

```sshconfig
Host github.com ssh.github.com
    ProxyCommand nc -x 127.0.0.1:<clash-socks-port> -X 5 %h %p
```

## 限制

- `proxychains-ng` 只适用于 TCP，不覆盖 UDP / ICMP
- `scancel` 掉 compute 节点后，节点上的 `autossh`、`sshd`、shell 和代理状态会一起结束
- 换新节点后，要重新进入节点，再重新执行 `proxy.on`
- Go 程序（如 `frp-panel`）绕过 libc 做 DNS，`proxychains` 无法拦截；compute 节点上需要用 IP 替代域名
- 如果希望“几乎所有程序都无脑可用”，那不是 shell 环境变量能解决的，需要 TUN / 透明代理，或集群管理员提供可用 DNS

## 排错

compute 节点手动 `proxy.on` 失败时，优先检查：

- login 节点上是否已经执行过 `proxy.on`
- `proxy.status` 里的 `proxy upstream` 是否真的是你想借出的那台 login 节点
- 是否需要在 `~/.zprofile` 里显式设置 `MSE_PROXY_UPSTREAM_HOST=loginXX`
- 是否需要临时设置 `MSE_PROXY_DEBUG=1` 后重新执行 `proxy.on`

## 常用变量

```shell
export MSE_PROXY_MODE=clash+via-login   # clash+via-login | clash+origin | origin+via-login | origin+origin
export MSE_PROXY_HOST=127.0.0.1     # 代理客户端所在主机，一般不用改
export MSE_PROXY_DIRECT_HOSTS="c55b01n08"
export MSE_PROXY_UPSTREAM_HOST=login03
export MSE_PROXY_HOST_LOOKUP_TIMEOUT=2
export MSE_PROXY_PROCESS_LOOKUP_TIMEOUT=2
export MSE_PROXY_SSH_CONNECT_TIMEOUT=5
```

补充：

- 代理端口不再由 `.mse-install.env` 接管
- 原生 Linux `clash` 模式只读 `clashctl runtime.yaml` 的 HTTP 和 SOCKS 端口
- Slurm compute 的 `clash` 模式消费共享 runtime 并管理本机 MSE autossh 状态
- macOS 自动识别系统代理或代理进程监听端口；WSL 按 Linux 逻辑手动 `proxy.on`，端点发现可读取 Windows 系统代理
- Windows PowerShell profile 会读取 `MSE_PROXY_PORT`
- `MSE_PROXY_DIRECT_HOSTS` 用空格分隔多个主机名
