# Fast Deployment for Shell Envs

## Table of Contents

- [Fast Deployment for Shell Envs](#fast-deployment-for-shell-envs)
  - [Table of Contents](#table-of-contents)
  - [usage](#usage)
    - [dependencies](#dependencies)
    - [install](#install)
    - [update](#update)
    - [personal settings:](#personal-settings)
  - [features and skills](#features-and-skills)
    - [1. <strong>micromamba</strong>: A faster and better <strong>"conda"</strong>](#1-micromamba-a-faster-and-better-conda)
    - [2. <strong>vim / neovim</strong>: Immediately start to use](#2-vim--neovim-immediately-start-to-use)
    - [3. <strong>ZSH</strong>: Clear and practical ZSH themes and plugins](#3-zsh-clear-and-practical-zsh-themes-and-plugins)
    - [4. <strong>Spyder</strong>: Auto deploy spyder config](#4-spyder-auto-deploy-spyder-config)
    - [5. <strong>jcat</strong>: A convenient command for fast checking notebook with ipynb format in terminal](#5-jcat-a-convenient-command-for-fast-checking-notebook-with-ipynb-format-in-terminal)
    - [6. <strong>wd</strong>: A dictory in terminal](#6-wd-a-dictory-in-terminal)
    - [7. <strong>tldr</strong>: too long don't read, it is a famous command for repalcing <strong>man</strong>](#7-tldr-too-long-dont-read-it-is-a-famous-command-for-repalcing-man)
    - [8. <strong>Other skills</strong>](#8-other-skills)
  - [license](#license)

## usage

### dependencies

> **when use windows:**
>
> - [scoop](https://scoop.sh/) is the dependency
> - all commands below should run in `PowerShell`

before we can start deploy our envs, you should make sure zsh and oh-my-zsh are installed

```shell
# install zsh & oh-my-zsh
sudo apt install zsh  # on Ubuntu
# change shell to zsh
chsh -s $(which zsh)

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# plugins for oh-my-zsh
cd ~/.oh-my-zsh/custom/plugins/
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
git clone https://github.com/zsh-users/zsh-autosuggestions
```

### install

now we can start deploy `.my_shell_envs`

```shell
# install .my_shell_envs
cd $HOME
git clone https://github.com/hermanzhaozzzz/.my_shell_envs.git
## or git clone git@github.com:hermanzhaozzzz/.my_shell_envs.git

# deploy envs on MacOS / Linux / Windows
cd ~/.my_shell_envs

bash deploying_locally.sh # MacOS/Linux
# or
git-bash deploying_locally.sh # Windows, in powershell!


# <tips> via https or ssh
# you can set git clone via https (default) or ssh
# bash deploying_locally.sh ssh

# <tips>
# scoop install git  # powershell
# git-bash deploying_locally.sh  # powershell

cd ~/.my_shell_envs/
cd
# then just try
z my
```

### update

```shell
mse_update
```

### personal settings:

see details in `.my_shell_envs/apply_personal_envs.sh`

this script will remove exist zsh settings (zshenv, zprofile) and copy my personal settings (`.my_shell_envs/zsh/zprofile_hermanzhaozzzz_demo`) and rename it to `~/.zprofile`

**zprofile will be sourced before zshrc when you login, and don't effect no-login operations like `scp / rsync`**

you can create a `~/.zprofile` by yourself and don't use `.my_shell_envs/apply_personal_envs.sh` and `zprofile_hermanzhaozzzz_demo`

```shell
# e.g. deploy my personal settings, I just:
bash apply_personal_envs.sh

# <tips>
# you can create a ~/.zprofile and use it by yourself but not use my <apply_personal_envs.sh>
# when you login your system, ~/.zprofile (personal settings)
# will be sourced before ~/.zshrc (.my_shell_envs' public settings)
```

## features and skills

### 1. **micromamba**: A faster and better **"conda"**

I use micromamba to replace conda, miniconda or mamba, because:

- conda / miniconda: Slow as a turtle, trust me, you will wait until you want to hit the keyboard
- mamba: Often you don't dare to update `base` env because of missing dependencies or version problems raised by mamba

when you use [.my_shell_envs](https://github.com/hermanzhaozzzz/.my_shell_envs), if `base` is boomed, you just `cd ~/.my_shell_envs && bash deploying_locally`, that's all!

![](https://pic3.zhimg.com/v2-9b990548c624931878c88dbc65154bea_b.jpg)

### 2. **vim / neovim**: Immediately start to use

vim config refs to [vim-for-coding](https://github.com/Leptune/vim-for-coding), it's lightweight but very practical.

![](https://pic4.zhimg.com/v2-9587f7dca82dc9b6e700b661e96207db_b.jpg)

neovim config refs to [nvimdots](https://github.com/ayamir/nvimdots), I really enjoy using it to write code on the server!

### 3. **ZSH**: Clear and practical ZSH themes and plugins

- syntax highlighting: refs to [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting.git)
- autosuggestions: refs to [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- z plugin: refs to [z](https://github.com/rupa/z)

![](https://pic2.zhimg.com/v2-1d5b7cade272ec46c293bf80353d36e5_b.jpg)

### 4. **Spyder**: Auto deploy spyder config

![](https://pic2.zhimg.com/v2-1d477136ea9fbc3e42295d153924b6fd_b.jpg)

### 5. **jcat**: A convenient command for fast checking notebook with ipynb format in terminal

refs to [jcat](https://github.com/zhifanzhu/jcat)

![](https://pic1.zhimg.com/v2-cc31145bcbe6d57e78dbf90db7b78f10_b.jpg)

![](https://pic4.zhimg.com/v2-42f94f107405490e83cef241d413ca97_b.jpg)

### 6. **wd**: A dictory in terminal

refs to [Wudao-dict](https://github.com/ChestnutHeng/Wudao-dict)
![](https://pic1.zhimg.com/v2-4941f3b7b7c83780d50bcfb36b6dbad8_b.jpg)

### 7. **tldr**: too long don't read, it is a famous command for repalcing **man**

refs to [https://tldr.sh/](https://tldr.sh/)

![](http://_pic.zhaohuanan.cc:7777/images/2023/11/14/20231114212028333f22f9bb5d513e.png)

### 8. **Other skills**

- a trash folder to avoid dangerous `rm -rf`
  - `rm` (alias `mv` to `rm`, use `\rm` or `/bin/rm` or `rm.real.rm` if you want to use raw `rm`)
  - `rm.*` cmds
    - `rm.real.rm`
    - `rm.trash.back`
    - `rm.trash.clear`
    - `rm.trash.show`
- `l` / `ll` / `lll` / `llll` cmds to replace `ls`
- `btop` cmd to replace `top` / `htop`
- `open` cmd, to open a file with default apps
- when you want to add cmds in your `PATH`, just `cd ~/.my_shell_envs/bin && ln -s /absolute_path/cmd`

## license

Use my setting for free!
