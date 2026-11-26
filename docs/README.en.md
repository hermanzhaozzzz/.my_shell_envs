# My Shell Env (MSE)

[简体中文](../README.md) | [English](README.en.md)

Set up a terminal environment in one command: zsh, editors, micromamba, common CLIs, and a Slurm cluster proxy. **The same configuration works on Linux (including WSL) and macOS**, and one command rebuilds it on a new machine.

You only need to remember three things in this document:

1. **Quick start** — install it and go
2. **Customize your own configuration** — where your settings live and how they coexist with the repo
3. **Daily commands** — the commands you will actually use

Everything else (deploy flags, feature details, cluster proxy, tests) is secondary; look it up when needed.

## Quick Start

Install the dependencies first on Linux / macOS:

```shell
# Debian / Ubuntu
sudo apt install -y git zsh build-essential pkg-config

# macOS
xcode-select --install      # zsh is already installed
```

Then:

```shell
git clone https://github.com/hermanzhaozzzz/.my_shell_envs.git ~/.my_shell_envs
cd ~/.my_shell_envs
./mse deploy
```

Run `exec zsh` when it finishes. `mse` is on PATH afterwards, so `mse deploy` / `mse update` work directly; the default installs every module — see "Deploy and update" for other protocols or partial installs.

## Customize Your Own Configuration

**The only file you need to edit is `~/.zprofile`.**

| File | What goes there | Update behavior |
|---|---|---|
| `~/.zprofile` | Your machine, paths, proxy settings — **personal** configuration | Not updated by MSE; `deploy` / `update` leave it alone by default |
| `~/.zshrc` | Shared interactive logic managed by the repo (symlinked to `${HOME}/.my_shell_envs/zsh/zshrc`) | Follows the repo; a repo update replaces it wholesale |

Editing `~/.zshrc` directly loses your changes — the next update overwrites it with the repo version.

zsh load order:

```text
.zshenv -> .zprofile -> .zshrc -> .zlogin -> .zlogout
```

- `~/.zshenv` — read by every zsh process; it also affects `scp` and other non-login / non-interactive connections, so **keep it minimal**
- `~/.zprofile` — read by login shells, affects login interactive shells only; **this is where you keep your personal DIY settings** (PATH, proxy ports, host-specific variables)
- `~/.zshrc` — read by interactive shells; **this is where MSE's shared configuration lives, do not edit it**
- `~/.zlogin` / `~/.zlogout` — read at login end / logout; usable, but **rarely needed**

Do not redefine repo-provided commands in `~/.zprofile`, especially `proxy.on` / `proxy.off`.

### Write your own `~/.zprofile`

You can leave it completely empty — every default lives in the repo's `zsh/zshrc`. Everything below is **an optional example**; keep or delete as needed:

```shell
# Example: personal preferences — omitting these is fine
export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"

# Example: override an MSE default
# Default is false: the micromamba base environment is not activated, so
#   conda / python installed in base are not on PATH
# Set it to true to run `micromamba activate base` in every new shell;
#   more convenient, but it affects terminal startup time
export MSE_MAMBA_AUTO_ACTIVATE_BASE=true
```

New terminals pick it up after saving. Cluster proxy variables are covered in "Cluster proxy"; ordinary machines do not need them.

### Common variables

| Variable | Purpose | Example |
|---|---|---|
| `MSE_ZSH_THEME` | Override the default theme; default `fino`; see [Themes](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes) | `export MSE_ZSH_THEME="agnoster"` |
| `MSE_ZSH_PLUGINS` | Replace the whole plugin list; default `git z zsh-syntax-highlighting zsh-autosuggestions`; see [Plugins](https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins) | `export MSE_ZSH_PLUGINS="git z"` — only these two<br>`export MSE_ZSH_PLUGINS="git z zsh-syntax-highlighting zsh-autosuggestions docker"` — the default four plus docker |
| `MSE_MAMBA_AUTO_ACTIVATE_BASE` | Whether every new shell activates the micromamba base environment; default `false`; `true` affects startup time | `export MSE_MAMBA_AUTO_ACTIVATE_BASE=true` |
| `MSE_PROXY_MODE` | Two-part: login side + compute side. Login side is `clash`/`origin`; compute side is `clash`/`via-login`/`origin`; see "Cluster proxy" for common combinations | `export MSE_PROXY_MODE=clash+via-login` |

`MSE_ZSH_PLUGINS` is a **full replacement**, not an append.

### Maintainer's personal profile (`--maintainer-personal-zprofile`)

This deploy switch uses the maintainer's own `zsh/zprofile_hermanzhaozzzz_demo` as `~/.zprofile`; it backs up any existing `~/.zprofile` first. It is equivalent to:

```shell
ln -s ~/.my_shell_envs/zsh/zprofile_hermanzhaozzzz_demo ~/.zprofile
```

- Maintainer: use it freely
- Everyone else: **do not use it directly**; treat it as a reference for style (PATH, proxy mode, directory conventions) and write your own `~/.zprofile`
- Without the flag, `deploy` **never** touches your `~/.zprofile`
- That file hardcodes the maintainer's machine paths, cluster hostnames, and proxy settings

## Daily Commands

| What you want | Command |
|---|---|
| Deploy / update | `mse deploy` / `mse update` |
| Turn proxy on / off / show status | `proxy.on` / `proxy.off` / `proxy.status` |
| Test proxy connectivity | `proxy.test` |
| Force a command through the proxy | `proxy.exec <command>` |
| Delete a file (to trash) | `rm <path>` |
| Really delete | `rrm <path>` |
| Show / restore / empty trash | `rm.trash.show` / `rm.trash.back` / `rm.trash.clear` |
| Manage Conda environments | `conda` (aliased to `micromamba`) |
| Inspect Slurm (Linux) | `sqtop` |

## Deploy and Update

### `mse deploy`

Default: **`fast` mode + `https`** — installs every supported module.

| What you want to change | Flag to add |
|---|---|
| Install only part of the modules | `--interactive` |
| Clone with SSH | `--ssh` |
| Both | `--ssh --interactive` |

Flags combine freely and order does not matter; if both `--fast` and `--interactive` are given, the last one wins. The maintainer-only `--maintainer-personal-zprofile` is described in "Customize your own configuration".

Linux and macOS use the same command. Windows uses PowerShell + git-bash:

```powershell
git clone https://github.com/hermanzhaozzzz/.my_shell_envs.git $HOME/.my_shell_envs
cd $HOME/.my_shell_envs
git-bash ./mse deploy
```

Deploy tries `chsh -s "$(which zsh)"`; press Enter at the password prompt to skip changing your default shell.

What it does:

- Links `~/.zshrc` to `${HOME}/.my_shell_envs/zsh/zshrc`
- Installs or wires up `oh-my-zsh` and plugins
- Installs `micromamba`
- Handles `vim` / `neovim`
- Builds repo-managed CLI tools
- Installs extra modules per step

Existing files are backed up as `<name>_bak` before being replaced; an older backup with the same name is overwritten, and the log says so.

### `mse update`

```shell
mse update
```

Flow:

1. Fetch upstream
2. If there are uncommitted changes or local commits not on upstream, ask whether upstream should win
3. `y`: discard local content and `reset --hard` to upstream
4. `n`: exit so you can inspect the repo yourself
5. Non-interactive shell: exit without changing anything

It then redeploys with the settings saved from the last deploy, and never asks about the default shell again.

`--https` / `--ssh` convert the GitHub origin to that protocol before fetching — they do not just affect future clones. A non-GitHub origin that cannot be converted safely fails with an error instead of silently switching.

If the standalone Git repos for Vim, Neovim, or Wudao have local changes, deploy only warns and skips their pull; it never stashes, reverts, or overwrites them.

### `.mse-install.env`

Records the parameters and step switches of the last successful deploy:

```shell
MSE_GIT_METHOD='ssh'
MSE_DEPLOY_MODE='fast'
MSE_MAINTAINER_PERSONAL_ZPROFILE='false'
MSE_STEP_NVIM='true'
MSE_STEP_SQTOP='true'
MSE_STEP_CLASHCTL='true'
MSE_STEP_CLUSTER_PROXY_TOOLS='true'
```

`mse update` reuses it, so the result can differ from a fresh `mse deploy --fast`. To change defaults, rerun `mse deploy --interactive` or edit this file.

## Features

### Zsh

Enabled by default: Oh My Zsh, `git`, `z`, `zsh-syntax-highlighting`, `zsh-autosuggestions`.

`htop` is aliased to `btop`; `eza` provides `ll` / `lll` and similar listing aliases.

### micromamba

`conda` / `mamba` are aliased to `micromamba`, so use `conda` in daily work.

Linux and macOS both install under `$HOME/0.apps/micromamba`:

| Item | Path |
|---|---|
| Executable | `$HOME/0.apps/micromamba/bin/micromamba` |
| Base environment | `$HOME/0.apps/micromamba` itself |
| Named environment | `$HOME/0.apps/micromamba/envs/<name>` |
| Root prefix | `MAMBA_ROOT_PREFIX=$HOME/0.apps/micromamba` |

### Vim / Neovim

- Vim configuration based on [vim-for-coding](https://github.com/Leptune/vim-for-coding)
- Neovim configuration based on [MyLazyVim](https://github.com/hermanzhaozzzz/MyLazyVim)

### Trash (`rm` wrapper)

In an interactive zsh, `rm` does not delete — it moves files to the trash:

```shell
rm <path>          # move to trash; flags like -rf are ignored
rrm <path>         # real deletion (/bin/rm)
rm.trash.show      # list every trash directory
rm.trash.back      # restore into the current directory (pick one when there are several)
rm.trash.clear     # empty every trash directory (asks first)
```

Trash is per disk: a same-device `mv` is just a rename, while a cross-device move is a real copy. The default is only `$HOME/.mytrash`; to keep one trash per disk, declare them in `~/.zprofile`:

```shell
TRASH_DIRS=(
    "${HOME}/.mytrash"               # local machine
    /lustre1/cqyi/hnzhao/.mytrash    # cluster A /lustre1
    /lustre2/cqyi/hnzhao/.mytrash    # cluster A /lustre2
)
```

Deletion picks the first trash directory on the same device as the target; with no match it falls back to `$HOME/.mytrash` and warns about the cross-device copy.

**Note**: these are interactive zsh aliases. In scripts, cron, and `sbatch --wrap`, `rm` still deletes for real.

### jcat

View `ipynb` files in the terminal. See [jcat](https://github.com/zhifanzhu/jcat).

### wd

Terminal dictionary. See [Wudao-dict](https://github.com/ChestnutHeng/Wudao-dict).

### macupdatectl

macOS system update control tool (macOS 12+):

```shell
macupdatectl          # open the graphical menu
macupdatectl status   # show current state
```

The menu can block system updates, restore update checks and manual updates (recommended for Hackintosh), and clear the update badge. "Block" disables the software update service and related automatic options and blocks Apple update servers in a managed block of `/etc/hosts`; the file is backed up to `/var/backups/macupdatectl/` first.

### sqtop

Optional Slurm terminal monitor on Linux, similar to `htop` / `nvitop`. Installed by default with `deploy --fast`; choose it individually with `--interactive`.

## Cluster Proxy (Quick Reference)

Compute nodes usually have no internet. Start with how traffic flows:

### Prerequisites

`proxy.on` / `proxy.test` / `proxy.exec` require:

- The `cluster_proxy_tools` step during deploy (provides `autossh`, `proxychains`)
- If either side uses `clash`: `clashctl` deployed, **at least one subscription added**, and HTTP + SOCKS ports present in the runtime
- `via-login` only: no Clash or subscription needed, but the login node itself must have internet
- macOS / WSL: a local proxy client running

`proxy.test` / `proxy.exec` additionally need a proxy on the current node: a login node requires the login side to be `clash`; a compute node requires the compute side to be `clash` or `via-login`. Compute side `origin`, and login side `origin` on a login node, have no proxy.

### Choose by scenario

| Scenario | Login node | Compute node | Configuration |
|---|---|---|---|
| Mainland China, Clash on the login node | Clash, rule-based routing | SSH tunnel to the login node's Clash ports | `MSE_PROXY_MODE=clash+via-login` (default), run `proxy.on` |
| Clash on the login node, compute node has its own internet | Clash | Its own network | `MSE_PROXY_MODE=clash+origin`, run `proxy.on` |
| Compute node has internet and should run Clash locally | As needed for the login side | Local Clash | `MSE_PROXY_MODE=clash+clash` or `origin+clash` |
| Login node has internet, compute node does not | Its own network | SSH tunnel to the login node, then its direct egress | `MSE_PROXY_MODE=origin+via-login`, run `proxy.on` (port chosen automatically) |
| Compute node has internet | Its own network | Its own network | `MSE_PROXY_MODE=origin+origin`, no `proxy.on` needed |

### Behavior of each value

| `MSE_PROXY_MODE` | Login node | Compute node |
|---|---|---|
| `clash+via-login` (default) | Clash | SSH tunnel to the login node's Clash ports |
| `clash+clash` | Clash | Local Clash on the compute node (needs its own internet) |
| `clash+origin` | Clash | Its own network |
| `origin+via-login` | Its own network | SSH tunnel to the login node, then its direct egress |
| `origin+clash` | Its own network | Local Clash on the compute node (needs its own internet) |
| `origin+origin` | Its own network | Its own network |

When the compute side is `clash`, Clash starts on the compute node itself (the node must have internet); with `via-login`, no Clash runs there and traffic borrows the login node's egress through a tunnel.

macOS has no login / compute split: start your proxy client and run `proxy.on`; ports are discovered automatically. WSL follows the Linux logic; only Windows-side endpoint discovery depends on PowerShell interop.

Shortest flow:

```shell
proxy.status                 # node role and current state
proxy.on                     # enable; a compute node builds the autossh tunnel
proxy.test                   # test common sites
proxy.exec codex             # force programs that ignore env vars through the proxy
proxy.off                    # clear this shell only; the Clash service keeps running
```

Three common pitfalls:

- "`proxy.on` ran but nothing works" — check `proxy upstream` in `proxy.status` first
- VSCode Remote into a compute node can defeat upstream detection; fix it with `MSE_PROXY_UPSTREAM_HOST=login03` in `~/.zprofile`
- Go programs such as `frp-panel` bypass system DNS, so `proxychains` cannot intercept them; use IPs instead of hostnames

Full details (clashctl install, subscriptions, runtime, endpoint discovery, upstream detection, limits, troubleshooting) are in **[proxy.md](proxy.md)**.

## Tests

No real subscription, Mihomo service, or external network is needed; tests use temporary directories:

```shell
./tests/run.sh
```

They cover deploy selection, update behavior, port sync, Slurm role routing, clashctl lifecycle, and trash handling.

## Contributing

Issues and PRs are welcome. Workflow:

```shell
cd "$HOME"
git clone git@github.com:<your-github-name>/.my_shell_envs.git
cd ~/.my_shell_envs
./mse deploy
```

Confirm it works locally, then submit your changes.

## License

Free to use and modify.
