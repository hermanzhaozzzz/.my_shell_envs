REPO_PATH=$(pwd)
/bin/rm $HOME/.zshenv_bak 2>/dev/null
mv $HOME/.zshenv $HOME/.zshenv_bak
ln -s $REPO_PATH/zsh/my_zshenv $HOME/.zshenv
