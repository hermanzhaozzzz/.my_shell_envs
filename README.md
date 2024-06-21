# fast deployment for shell envs

# Table of Contents

- [fast deployment for shell envs](#fast-deployment-for-shell-envs)
- [Table of Contents](#table-of-contents)
  - [usage](#usage)
    - [dependencies](#dependencies)
    - [install](#install)
    - [update](#update)
    - [personal settings:](#personal-settings)
  - [features and skills](#features-and-skills)
    - [1. A faster and better "conda"](#1-a-faster-and-better-conda)
    - [2. "Immediately start to use" vim / nvim](#2-immediately-start-to-use-vim--nvim)
      - [vim](#vim)
      - [nvim (neovim)](#nvim-neovim)
    - [3. Clear and practical ZSH themes and plugins](#3-clear-and-practical-zsh-themes-and-plugins)
    - [4. auto deploy spyder config](#4-auto-deploy-spyder-config)
    - [5. a convenient jcat command for fast check notebook with ipynb format in terminal](#5-a-convenient-jcat-command-for-fast-check-notebook-with-ipynb-format-in-terminal)
    - [6. wd for fast query words in the terminal (for English learners)](#6-wd-for-fast-query-words-in-the-terminal-for-english-learners)
    - [7. tldr is a famous command for learning shell, just like a simplified man](#7-tldr-is-a-famous-command-for-learning-shell-just-like-a-simplified-man)
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

```

### update

```shell
cd ~/.my_shell_envs
git fetch
git pull --rebase
```

### personal settings:

see details in `.my_shell_envs/apply_personal_envs.sh`

```shell
# e.g. deploy my personal settings, I just:
bash apply_personal_envs.sh

# <tips>
# you can create a ~/.zshenv and use it by yourself but not use my <apply_personal_envs.sh>
# when you login your system, ~/.zshenv (personal settings)
# will be sourced before ~/.zshrc (.my_shell_envs' public settings)
```

## features and skills

### 1. A faster and better "conda"

I use micromamba to replace conda, miniconda or mamba, because:

- conda / miniconda: Slow as a turtle, trust me, you will wait until you want to hit the keyboard
- mamba: Often you don't dare to update `base` env because of missing dependencies or version problems raised by mamba

when you use [.my_shell_envs](https://github.com/hermanzhaozzzz/.my_shell_envs), if `base` is boomed, you just `cd ~/.my_shell_envs && bash deploying_locally`, that's all!

![](https://pic3.zhimg.com/v2-9b990548c624931878c88dbc65154bea_b.jpg)

### 2. "Immediately start to use" vim / nvim

#### vim

vim config refs to [vim-for-coding](https://github.com/Leptune/vim-for-coding), it's lightweight but very practical.

![](https://pic4.zhimg.com/v2-9587f7dca82dc9b6e700b661e96207db_b.jpg)

#### nvim (neovim)

neovim config refs to [nvimdots](https://github.com/ayamir/nvimdots), I really enjoy using it to write code on the server!

### 3. Clear and practical ZSH themes and plugins

- syntax highlighting: refs to [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting.git)
- autosuggestions: refs to [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- z plugin: refs to [z](https://github.com/rupa/z)

![](https://pic2.zhimg.com/v2-1d5b7cade272ec46c293bf80353d36e5_b.jpg)

### 4. auto deploy spyder config

![](https://pic2.zhimg.com/v2-1d477136ea9fbc3e42295d153924b6fd_b.jpg)

### 5. a convenient `jcat` command for fast check notebook with ipynb format in terminal

refs to [jcat](https://github.com/zhifanzhu/jcat)

![](https://pic1.zhimg.com/v2-cc31145bcbe6d57e78dbf90db7b78f10_b.jpg)

![](https://pic4.zhimg.com/v2-42f94f107405490e83cef241d413ca97_b.jpg)

### 6. `wd` for fast query words in the terminal (for English learners)

refs to [Wudao-dict](https://github.com/ChestnutHeng/Wudao-dict)
![](https://pic1.zhimg.com/v2-4941f3b7b7c83780d50bcfb36b6dbad8_b.jpg)

### 7. `tldr` is a famous command for learning `shell`, just like a simplified `man`

refs to [https://tldr.sh/](https://tldr.sh/)

![](http://_pic.zhaohuanan.cc:7777/images/2023/11/14/20231114212028333f22f9bb5d513e.png)

## license

Use my setting for free!
