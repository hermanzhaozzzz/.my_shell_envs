# My Shell Env (MSE)

Do not waste time configuring your environment. Spend ten minutes installing MSE, then get to work.
> [!TIP]
> 🚀 Do not waste time configuring your environment. Spend ten minutes installing MSE, then get to work.

[简体中文](../README.md) | [English](README.en.md)

This repository helps me bootstrap a personal shell and development environment quickly, including shell config, editor config, Python-related setup, and a few utility tools.

## Contents

- [Overview](#overview)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Install for Users](#install-for-users)
  - [Developer Install](#developer-install)
  - [Update](#update)
  - [Conda Environments](#conda-environments)
  - [Personal Settings](#personal-settings)
- [Highlights](#highlights)
  - [1. micromamba](#1-micromamba)
  - [2. Vim / Neovim](#2-vim--neovim)
  - [3. Zsh](#3-zsh)
  - [4. jcat](#4-jcat)
  - [5. wd](#5-wd)
  - [6. Other Utilities](#6-other-utilities)
- [Contributing](#contributing)
- [License](#license)

## Overview

This repo is designed to:

- bootstrap my shell environment quickly
- sync Zsh, pip, Vim, and Neovim settings
- support both `fast` and `interactive` deployment modes
- switch secondary Git clone style with `--https` or `--ssh`

The unified entrypoint is now `mse`:

- inside the repo: `./mse deploy`, `./mse update`
- after bootstrap install: `mse update`

## Getting Started

There are two recommended installation paths:

- users: `curl | sh`
- owner / developers: SSH `git clone`, then `./mse deploy --ssh --use-zprofile-template`

### Prerequisites

On non-Windows platforms, `mse deploy` automatically manages this base layer:

- `zsh`
- `oh-my-zsh`
- standard Oh My Zsh plugins: `git`, `z`
- custom plugins: `zsh-syntax-highlighting`, `zsh-autosuggestions`

What you need before running it:

```shell
# required on macOS / Linux / WSL
git
curl
```

Notes:

- macOS requires `brew`, because MSE uses it to install `zsh`
- Linux / WSL requires `apt-get` and `sudo`, because MSE uses them to install `zsh`
- on non-Windows platforms, deployment links `~/.zshrc`, installs required plugins, and tries to run `chsh -s "$(which zsh)"`
- if you use this repo's `zshrc`, you do not need to manually edit the `plugins=(...)` list after deployment

### Install for Users

This is the recommended path if you just want a working setup and do not need a full Git clone. It installs the source into `~/.my_shell_envs` and places a global wrapper at `~/.local/bin/mse`.

```shell
curl -fsSL https://raw.githubusercontent.com/hermanzhaozzzz/.my_shell_envs/main/install.sh | sh
```

Common variants:

```shell
# interactive deploy
curl -fsSL https://raw.githubusercontent.com/hermanzhaozzzz/.my_shell_envs/main/install.sh | sh -s -- --interactive

# use ssh for secondary git clones during deployment
curl -fsSL https://raw.githubusercontent.com/hermanzhaozzzz/.my_shell_envs/main/install.sh | sh -s -- --ssh --interactive

# also link the demo zprofile template (review before use)
curl -fsSL https://raw.githubusercontent.com/hermanzhaozzzz/.my_shell_envs/main/install.sh | sh -s -- --interactive --use-zprofile-template
```

Notes:

- this path is mainly for macOS / Linux / WSL
- the installer downloads the GitHub `main` archive, then runs `mse deploy`
- on non-Windows platforms, MSE first runs the mandatory base setup: install `zsh`, install Oh My Zsh, install required plugins, link `~/.zshrc`, and switch the default shell to `zsh`
- before deployment starts, the installer prints the paths it may modify, such as `~/.zshrc`, `~/.oh-my-zsh`, plugin directories, `~/.condarc`, `~/.vim`, and `~/.config/nvim`
- `~/.zprofile` is only touched when you explicitly pass `--use-zprofile-template`
- if `~/.local/bin` is not in your `PATH`, the installer will tell you, but it will not modify your shell config automatically

This `curl | sh` path is not the Windows installation flow.

Recommended update command after bootstrap install:

```shell
mse update
```

If `mse` is not yet in `PATH`, use:

```shell
~/.local/bin/mse update
```

Windows installation and update:

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

Notes:

- the Windows path uses `PowerShell` + `git-bash`
- the documented Windows flow uses an HTTPS clone; if you already use SSH, you can replace the clone URL yourself
- the `curl | sh` bootstrap installer is for Unix-like environments and is not the Windows entrypoint

### Developer Install

Use this path if you are the repository owner, a long-term maintainer, or a developer who wants the full Git history.

```shell
cd "$HOME"
git clone git@github.com:hermanzhaozzzz/.my_shell_envs.git
cd ~/.my_shell_envs

./mse deploy --ssh --use-zprofile-template
```

Notes:

- this path uses an SSH clone by default
- on non-Windows platforms, the mandatory base setup includes `zsh`, Oh My Zsh, required plugins, `~/.zshrc`, and a default-shell switch
- deployment runs in `fast` mode by default, which means non-interactive installation
- `--ssh` makes secondary Git repositories use SSH as well
- `--use-zprofile-template` links the repository's demo `zprofile` template to `~/.zprofile`
- if you want to keep your own login config, drop `--use-zprofile-template`

### Update

The unified update entrypoint is now:

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

Behavior:

- `mse update` updates source code first, then redeploys
- Git installs use `git fetch` + `git pull --rebase`
- archive installs re-download the GitHub archive and create a local backup before replacing files

### Conda Environments

In this repo, `conda` is an alias of `micromamba`.

`mse deploy` mainly does two things:

- install `micromamba`
- link the environment files for the current platform from `conda/<platform>/` into `conda_local_env_settings/`

It does not automatically create every Conda environment. After deployment, just use `conda`.

The current platform's `base` environment file is linked to:

```shell
~/.my_shell_envs/conda_local_env_settings/base.yml
```

To update or deploy the `base` environment, run:

```shell
conda activate base && conda install -f ~/.my_shell_envs/conda_local_env_settings/base.yml
```

For other environments, replace `base.yml` with the corresponding `.yml` file.

### Personal Settings

Public config and personal login settings are now handled through `mse deploy`, with a conservative default:

- on non-Windows platforms, `./mse deploy` always installs the Zsh base layer and links `~/.zshrc`
- `./mse deploy` does not modify `~/.zprofile` by default
- if you explicitly want to symlink the repository's demo template to `~/.zprofile`, add `--use-zprofile-template`

```shell
./mse deploy --interactive

# optional: also link the demo zprofile template
./mse deploy --interactive --use-zprofile-template
```

Notes:

- `~/.zprofile` is sourced before `~/.zshrc` in login shells
- `zsh/zshrc` works without the demo `~/.zprofile`, so `zprofile` remains optional
- `zsh/zprofile_hermanzhaozzzz_demo` is a personal example with host-specific, proxy-specific, and workflow-specific assumptions; review it carefully before using it
- the better default for most users is to maintain their own `~/.zprofile` for login-time environment variables, PATH setup, proxies, and machine-specific aliases
- the repo does not currently track a `zshenv` file; historically there was a `zsh/zshenv_demo`, added in `4236a13` and removed in `84d9230`

Typical use cases for `~/.zprofile`:

- define `PATH`
- define proxy helpers
- export environment variables needed only in login shells
- load machine-specific toolchains or aliases

A practical `PATH` pattern:

```shell
# keep user-level bin directories near the front
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# add toolchain paths only when they exist
[ -d "$HOME/micromamba/bin" ] && export PATH="$HOME/micromamba/bin:$PATH"
[ -d "/opt/homebrew/bin" ] && export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
```

Notes:

- keep your own bin directories near the front, for example `~/.local/bin`
- guard platform-specific paths with existence checks
- avoid `unset PATH` unless you fully understand the implications

A minimal `~/.zprofile` example:

```shell
export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export PAGER="less"

[ -d "$HOME/micromamba/bin" ] && export PATH="$HOME/micromamba/bin:$PATH"
```

Proxy example:

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

If you need to load sensitive tokens, private hostnames, or company-specific settings, it is better to `source` a local private file from `~/.zprofile` than to place those values in the shared repo config.

## Highlights

### 1. micromamba

I use micromamba instead of conda / miniconda / mamba because:

- conda / miniconda can feel slow
- mamba is not always ideal for updating an existing base environment

In this repo, you can just type `conda` in daily use, because `conda` is already aliased to `micromamba`.

If you want to keep your own conda setup and skip micromamba, use:

```shell
./mse deploy --interactive
```

![](https://pic3.zhimg.com/v2-9b990548c624931878c88dbc65154bea_b.jpg)

### 2. Vim / Neovim

- Vim config references [vim-for-coding](https://github.com/Leptune/vim-for-coding)
- Neovim config references my [MyLazyVim](https://github.com/hermanzhaozzzz/MyLazyVim)

![](https://pic4.zhimg.com/v2-9587f7dca82dc9b6e700b661e96207db_b.jpg)

### 3. Zsh

The repo includes a practical Zsh setup with:

- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting.git)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [z](https://github.com/rupa/z)

![](https://pic2.zhimg.com/v2-1d5b7cade272ec46c293bf80353d36e5_b.jpg)

### 4. jcat

Quickly inspect `ipynb` files in the terminal. Reference:

- [jcat](https://github.com/zhifanzhu/jcat)

![](https://pic1.zhimg.com/v2-cc31145bcbe6d57e78dbf90db7b78f10_b.jpg)
![](https://pic4.zhimg.com/v2-42f94f107405490e83cef241d413ca97_b.jpg)

### 5. wd

A terminal dictionary tool. Reference:

- [Wudao-dict](https://github.com/ChestnutHeng/Wudao-dict)

![](https://pic1.zhimg.com/v2-4941f3b7b7c83780d50bcfb36b6dbad8_b.jpg)

### 6. Other Utilities

The repo also includes a few convenience helpers:

- a trash-style deletion workflow to reduce `rm -rf` mistakes
- `l` / `ll` / `lll` / `llll` shortcuts
- aliases such as `btop` and `open`
- an easy way to expose your own commands by linking them into `~/.my_shell_envs/bin`

## Contributing

Issues and pull requests are welcome.

If you find a bug, hit a compatibility problem, notice missing documentation, or want to improve a module in this repo, feel free to open an issue or submit a PR.

## License

Free to use and adapt.
