# fast deployment for shell envs
## features
- [conda (use micromamba)](https://github.com/mamba-org/mamba)
  - a faster and easy to use version of conda
- [vim (use my setting)](https://github.com/hermanzhaozzzz/vim-for-coding)
  - simple and useful features
- [zsh (use oh-my-zsh)](https://github.com/ohmyzsh/ohmyzsh)
  - very good settings for zsh
- [spyder](https://github.com/spyder-ide/spyder)
  - data science IDE for python coder
- [command: `jcat`](https://github.com/zhifanzhu/jcat)
  - a self-contained command line tool for viewing jupyter notebook files in terminal
- [command: `wd`](https://github.com/ChestnutHeng/Wudao-dict)
  - command line version for Youdao dict
- [command: `tldr`](https://github.com/tldr-pages/tldr-python-client)
    - a very useful demo document for command lines
- [neovim](https://github.com/neovim/neovim)
    - a self use config setting for `nvim`
    - see the doc for [my config](tools/nvim/README.md) and learn to use it


# use
## install \& update
### MacOS / Linux / Windows
> **when use windows:**
> - [scoop](https://scoop.sh/) is the dependency
> - all commands below should run in `PowerShell`

```shell
# install zsh & oh-my-zsh
# eg: sudo apt install zsh
# change shell to zsh
chsh -s /usr/bin/zsh

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# plugins for oh-my-zsh
cd ~/.oh-my-zsh/custom/plugins/
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
git clone https://github.com/zsh-users/zsh-autosuggestions

# install .my_shell_envs
cd $HOME
# git clone git@github.com:hermanzhaozzzz/.my_shell_envs.git
git clone https://github.com/hermanzhaozzzz/.my_shell_envs.git


# deploy envs
cd .my_shell_envs

# deploy: MacOS/Linux
bash deploying_locally.sh
# you can set git clone via https or ssh
# bash deploying_locally.sh ssh
# bash deploying_locally,sh https (default)


# deploy: Windows, in powershell!
scoop install git  # powershell
git-bash deploying_locally.sh  # powershell


# update my_shell_envs
cd ~/.my_shell_envs
git fetch
git pull --rebase
```
## skills

### 1\. 快速conda配置

![](https://pic3.zhimg.com/v2-9b990548c624931878c88dbc65154bea_b.jpg)

### 2\. 便捷的vim配置

![](https://pic4.zhimg.com/v2-9587f7dca82dc9b6e700b661e96207db_b.jpg)

使用了一个比较大佬的公开配置，[查看文档](https://github.com/bitterteasweetorange/nvim.git)

<!-- *   Insert模式下
*   ctrl + A跳转至行首
*   ctrl + E跳转至行尾
*   Normal模式下
*   ctrl + M多行选择文本
*   ...
*   具体查看[GitHub - hermanzhaozzzz/.my\_shell\_envs](https://link.zhihu.com/?target=https%3A//github.com/hermanzhaozzzz/.my_shell_envs)相关说明  
   -->
  
  

### 3\. 自动配置美观的zsh命令行显示，带有自动补全命令行功能和z插件跳转等

![](https://pic2.zhimg.com/v2-1d5b7cade272ec46c293bf80353d36e5_b.jpg)

### 4\. 自动部署spyder配置文件

![](https://pic2.zhimg.com/v2-1d477136ea9fbc3e42295d153924b6fd_b.jpg)

### 5\. 使用jcat命令在命令行下查看jupyter notebook的\`ipynb\`格式文件

![](https://pic1.zhimg.com/v2-cc31145bcbe6d57e78dbf90db7b78f10_b.jpg)

![](https://pic4.zhimg.com/v2-42f94f107405490e83cef241d413ca97_b.jpg)

### 6\. 使用wd命令在命令行下查单词

![](https://pic1.zhimg.com/v2-4941f3b7b7c83780d50bcfb36b6dbad8_b.jpg)

### 使用tldr命令查询命令行用法

![](http://_pic.zhaohuanan.cc:7777/images/2023/11/14/20231114212028333f22f9bb5d513e.png)

# license
use my setting for free!
