# this script set personal env in a login zsh env
# it will be loaded before `~/.zshrc`
REPO_PATH=$(pwd)

# `~/.zshenv` will be removed for a clean env, annotate it if you don't want to do this
/bin/rm $HOME/.zshenv $HOME/.zshenv_bak 2>/dev/null

#
/bin/rm $HOME/.zprofile_bak 2>/dev/null
mv $HOME/.zprofile $HOME/.zprofile_bak 2>/dev/null
ln -s $REPO_PATH/zsh/zprofile_hermanzhaozzzz_demo $HOME/.zprofile
