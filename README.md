# fast deployment for shell envs
- conda (use micromamba)
- vim (use spacevim)
- zsh (use oh-my-zsh)

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
