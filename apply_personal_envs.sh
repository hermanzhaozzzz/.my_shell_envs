REPO_PATH=$(pwd)
/bin/rm -f $HOME/.zshenv_bak 2>/dev/null
mv $HOME/.zshenv $HOME/.zshenv_bak
ln -s $REPO_PATH/zsh/zshenv_demo $HOME/.zshenv
