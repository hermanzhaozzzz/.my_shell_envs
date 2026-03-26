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
  - [HTTPS Install for Users](#https-install-for-users)
  - [SSH Install for Developers](#ssh-install-for-developers)
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

This repo installs my shell / Python / editor environment.

Inside the repo, use these two commands:

- `./mse deploy`
- `./mse update`

## Getting Started

Pick one installation method:

- users: HTTPS `git clone`
- owner / developers: SSH `git clone`

### Prerequisites

On Linux / macOS / WSL, make sure `zsh` is already installed before you run `./mse deploy`.

Then `./mse deploy` will handle:

- `oh-my-zsh`
- standard Oh My Zsh plugins: `git`, `z`
- custom plugins: `zsh-syntax-highlighting`, `zsh-autosuggestions`

What you need before running it:

```shell
# required on macOS / Linux / WSL
git
```

The script follows these rules:

- macOS / Linux / WSL all follow the same rule: the script checks whether `zsh` exists first
- if `zsh` is missing, the script stops with an error and tells you to install `zsh` manually
- if `zsh` already exists, the script continues with `oh-my-zsh`, standard plugins `git` / `z`, and custom plugins `zsh-syntax-highlighting` / `zsh-autosuggestions`
- deployment links `~/.zshrc` and tries to run `chsh -s "$(which zsh)"`
- the default Oh My Zsh theme in this repo is `fino`
- if you use this repo's `zshrc`, you do not need to manually edit the `plugins=(...)` list after deployment

### HTTPS Install for Users

For normal users, run:

```shell
cd "$HOME"
git clone https://github.com/hermanzhaozzzz/.my_shell_envs.git
cd ~/.my_shell_envs

./mse deploy
```

If you want an interactive deploy, or want to link the demo `zprofile`, run:

```shell
./mse deploy --interactive
./mse deploy --interactive --use-zprofile-template
```

When you run `./mse deploy`:

- on Linux / macOS / WSL, MSE checks `zsh` first; if it is missing, it stops and tells you to install `zsh` manually
- if `zsh` already exists, the script installs Oh My Zsh, installs required plugins, links `~/.zshrc`, and switches the default shell to `zsh`
- before deployment starts, the script prints the paths it may modify, such as `~/.zshrc`, `~/.oh-my-zsh`, plugin directories, `~/.condarc`, `~/.vim`, and `~/.config/nvim`
- `~/.zprofile` is only touched when you explicitly pass `--use-zprofile-template`

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

On Windows, do this:

- the Windows path uses `PowerShell` + `git-bash`
- the default user path uses an HTTPS clone

### SSH Install for Developers

For repository developers, run:

```shell
cd "$HOME"
git clone git@github.com:hermanzhaozzzz/.my_shell_envs.git
cd ~/.my_shell_envs

./mse deploy --ssh --use-zprofile-template
```

When you run `./mse deploy --ssh --use-zprofile-template`:

- this path uses an SSH clone by default
- on Linux / macOS / WSL, MSE checks `zsh` first; if it is missing, it stops and tells you to install `zsh` manually
- if `zsh` already exists, the script continues with Oh My Zsh, required plugins, `~/.zshrc`, and a default-shell switch
- deployment runs in `fast` mode by default, which means non-interactive installation
- `--ssh` makes secondary Git repositories use SSH as well
- `--use-zprofile-template` links the repository's demo `zprofile` template to `~/.zprofile`
- if you want to keep your own login config, drop `--use-zprofile-template`

Read the common flags like this:

- `--interactive`
  Purpose: enter interactive mode and confirm steps one by one
  Add it when: you want to choose which modules to install
- `--ssh`
  Purpose: make secondary Git repositories use SSH too
  Add it when: you already configured your GitHub SSH key and want secondary repos to use SSH as well
- `--use-zprofile-template`
  Purpose: symlink the repository demo `zprofile` to `~/.zprofile`
  Add it when: you explicitly want to use that demo file; if you want to keep your own login config, do not add it

Common command combinations:

```shell
# default developer path: SSH + demo zprofile
./mse deploy --ssh --use-zprofile-template

# choose steps yourself, but keep your own ~/.zprofile
./mse deploy --ssh --interactive

# choose steps yourself and also use the demo zprofile
./mse deploy --ssh --interactive --use-zprofile-template
```

### Update

To update, run:

```shell
./mse update

# pass deploy flags through update
./mse update --interactive
./mse update --ssh --interactive
./mse update --interactive --use-zprofile-template
```

After install or deploy, the repo puts `mse` here:

```shell
~/.my_shell_envs/bin/mse
```

The repo `zsh/zshrc` adds this directory to PATH:

```shell
~/.my_shell_envs/bin
```

So after you open a new zsh terminal, you can run these commands from any directory:

```shell
mse update
mse deploy
```

When you run `./mse update`:

- `mse update` updates source code first, then redeploys
- Git installs use `git fetch` + `git pull --rebase`

If you want your own commands to be globally available too, put them in that directory:

```shell
ln -s /absolute/path/to/your_tool ~/.my_shell_envs/bin/your_tool
```

Or copy the executable there:

```shell
cp /absolute/path/to/your_tool ~/.my_shell_envs/bin/
chmod +x ~/.my_shell_envs/bin/your_tool
```

After opening a new zsh terminal, you can then run `your_tool` from any directory.

### Conda Environments

In this repo, `conda` is an alias of `micromamba`.

When you run `./mse deploy`, the script:

- install `micromamba`
- link the environment files for the current platform from `conda/<platform>/` into `conda_local_env_settings/`

It does not automatically create every Conda environment. After deployment, run `conda` yourself.

The current platform's `base.yml` is linked to:

```shell
~/.my_shell_envs/conda_local_env_settings/base.yml
```

To update or install the `base` environment, run:

```shell
conda activate base && conda install -f ~/.my_shell_envs/conda_local_env_settings/base.yml
```

For other environments, replace `base.yml` with the corresponding `.yml` file.

### Personal Settings

By default, `./mse deploy` only handles shared config. It does not overwrite your personal login config:

- on Linux / macOS / WSL, `./mse deploy` requires `zsh` to already exist; after that, it configures Oh My Zsh, plugins, and links `~/.zshrc`
- `./mse deploy` does not modify `~/.zprofile` by default
- `--use-zprofile-template` only symlinks the repository demo template to `~/.zprofile`

```shell
./mse deploy --interactive

# optional: also link the demo zprofile template
./mse deploy --interactive --use-zprofile-template
```

Here is the practical rule:

- for most users, do not directly symlink my demo `zprofile`
- `zsh/zprofile_hermanzhaozzzz_demo` is only a demo file for my own usage patterns
- if you want to DIY your own setup, create your own `~/.zprofile`
- this repo manages shared interactive config in `zsh/zshrc`; your machine-specific config should go into your own `~/.zprofile`

Zsh loads files in this order:

```text
.zshenv -> .zprofile -> .zshrc -> .zlogin -> .zlogout
```

Use each file like this:

- `~/.zshenv`
  Purpose: loaded by every zsh process, including non-interactive shells
  Advice: keep it minimal. Do not put proxies, aliases, plugins, or heavy logic here
- `~/.zprofile`
  Purpose: loaded by login shells before `~/.zshrc`
  Advice: put your own PATH, proxies, machine-specific environment variables, private tokens, and host aliases here
- `~/.zshrc`
  Purpose: loaded by interactive shells
  Advice: this repo already manages shared config here, including Oh My Zsh, theme, plugins, aliases, functions, and `~/.my_shell_envs/bin`
- `~/.zlogin`
  Purpose: loaded at the end of login-shell startup
  Advice: most users do not need it

For DIY config, put things here:

- PATH: `~/.zprofile`
- proxy helpers: `~/.zprofile`
- private tokens / company-only config: `~/.zprofile`, or a private file sourced from it
- shared aliases / functions: keep using the repo-managed `zsh/zshrc`
- if you only want to change the Oh My Zsh theme or plugin list, do not edit the repo `zsh/zshrc`; override them in your own `~/.zprofile`

The most important PATH rule is: do not overwrite the existing `$PATH`. Extend it.

If you want to override the theme or plugins, put these variables in `~/.zprofile`:

```shell
# optional: override Oh My Zsh theme
export MSE_ZSH_THEME="robbyrussell"

# optional: override plugin list
export MSE_ZSH_PLUGINS="git z zsh-syntax-highlighting zsh-autosuggestions"
```

The rule is simple:

- `MSE_ZSH_THEME`: overrides the repo default theme `fino`
- `MSE_ZSH_PLUGINS`: replaces the repo default plugin list
- put these variables in `~/.zprofile`; the repo `zsh/zshrc` will read them

If you do not want to change theme or plugins, do not set these variables.

Use this pattern:

```shell
# keep existing PATH, then prepend your own paths
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# add extra toolchain paths only when they exist
[ -d "/opt/homebrew/bin" ] && export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
```

When editing `PATH`:

- always keep `$PATH`; do not replace it with a hard-coded value such as `export PATH="/some/path"`
- this keeps system commands, `~/.my_shell_envs/bin`, and the repo-managed `zshrc` additions working
- keep your own bin directories near the front, for example `~/.local/bin`
- in this repo, you usually do not need to manually add `micromamba/bin` in `~/.zprofile`, because the repo `zsh/zshrc` already handles `micromamba` / `conda`
- only add it to `~/.zprofile` if you explicitly want `micromamba` to be available before `zsh/zshrc` runs
- guard platform-specific paths with existence checks
- avoid `unset PATH` unless you fully understand the implications

A minimal `~/.zprofile` example:

```shell
# keep existing PATH
export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export PAGER="less"
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

If you need sensitive tokens, private hostnames, or company-only settings, use this pattern:

```shell
[ -f "$HOME/.zprofile.private" ] && source "$HOME/.zprofile.private"
```

Put those private values in your own `~/.zprofile.private` instead of the shared repo config.

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

- Oh My Zsh theme: `fino`
- standard Oh My Zsh plugins: `git`, `z`
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting.git)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [z](https://github.com/rupa/z)

What the default plugins do and how to use them:

- `git`
  Purpose: provides common git aliases
  Examples: `gst` shows status, `gco <branch>` switches branches, `gaa` stages all changes
- `z`
  Purpose: remembers directories you visit often, then jumps to them quickly
  Examples: after using `cd` normally for a while, run `z project` or `z Downloads`
- `zsh-syntax-highlighting`
  Purpose: highlights command syntax directly in the shell
  Usage: valid commands are usually highlighted while mistyped commands are not
- `zsh-autosuggestions`
  Purpose: suggests completions from your shell history
  Usage: the shell shows a gray suggestion; usually you can accept it with the Right Arrow key

If you do not change personal config, these plugins work right after deployment.

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

A minimal contribution workflow looks like this:

1. Fork this repository to your own GitHub account.
2. Clone your own fork locally.

```shell
cd "$HOME"
git clone git@github.com:<your-github-name>/.my_shell_envs.git
cd ~/.my_shell_envs
```

3. Deploy your fork locally and make sure your changes actually work.

```shell
./mse deploy
```

4. Edit code or docs, and test locally until the result works as expected.
5. Commit and push the changes to your own fork.
6. Open a PR from your fork and request merging into this repository.

Documentation-only PRs are also very welcome.

If you are not sure about the direction of a change, open an Issue first.

Contributions are very welcome. This repo is much better when people maintain it together.

## License

Free to use and adapt.
