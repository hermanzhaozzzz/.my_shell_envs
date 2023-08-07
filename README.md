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


# use
```shell
# install

cd $HOME
git clone git@github.com:hermanzhaozzzz/.my_shell_envs.git
cd .my_shell_envs
# deploy
bash deploying_locally.sh

# update
cd ~/.my_shell_envs
git fetch
git pull --rebase
```
