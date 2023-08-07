# get repo path
REPO_PATH=`pwd` 
# ------------------------------------------------------------------->>>>>>>>>>
# platform judgement and var setting
# ------------------------------------------------------------------->>>>>>>>>>

echo -e "---------------------------------|\nset conda panels..."

mv $HOME/.condarc $HOME/.condarc_bak
ln -s $REPO_PATH/conda/condarc $HOME/.condarc

platform="`uname`"

if [[ "$platform" == "Linux" ]]; then
    platform="Linux"
    URL=https://micro.mamba.pm/api/micromamba/linux-64/latest
    ROOT_PATH=$HOME/0.apps/micromamba

elif [[ "$platform" == "Darwin" ]]; then
    if [[ "`uname -p`" == "i386" ]]; then
        platform="MacOS/x86_64"
        URL=https://micro.mamba.pm/api/micromamba/osx-64/latest
        ROOT_PATH=$HOME/micromamba
    elif [[ "`uname -p`" == "arm" ]]; then
        platform="MacOS/arm64"
        URL=https://micro.mamba.pm/api/micromamba/osx-arm64/latest
        ROOT_PATH=$HOME/micromamba
    fi

elif [[ "$platform" == "WindowsNT" ]]; then
    platform="Windows"  # TODO, no strategy now
    echo "unsupported OS: $platform!"
    exit 1
else
    echo "unsupported OS: $platform!"
    exit 1
fi
echo -e "---------------------------------|\nplatform detected: $platform"


# ------------------------------------------------------------------->>>>>>>>>>
# micromamba setting (annotate if not use)
# ------------------------------------------------------------------->>>>>>>>>>

echo -e "---------------------------------|\nset conda env config files..."

# install micromamba
if [ ! -f "$ROOT_PATH/bin/micromamba" ];then
    echo "micromamba not found @$ROOT_PATH/bin/! start to install..."
    mkdir -p $ROOT_PATH
    cd $ROOT_PATH
    curl -Ls $URL | tar -xvj bin/micromamba
    cd $REPO_PATH
else
    echo "micromamba exists @$ROOT_PATH/bin/! skip installing..."
fi
# set yml files...
echo "start to choose env.yml..."
# make softlink directory
CONDA_ENVS=$REPO_PATH/conda_local_env_settings
mkdir -p $CONDA_ENVS

for yml in `ls $REPO_PATH/conda/$platform/*.yml`; do
    ln -sf $yml $CONDA_ENVS/`basename $yml`
done
echo "conda config files @: $CONDA_ENVS "

# ------------------------------------------------------------------->>>>>>>>>>
# zsh setting (annotate if not use)
# ------------------------------------------------------------------->>>>>>>>>>

echo -e "---------------------------------|\nset zsh config file"

platform_fix="`echo $platform | awk -F '/' '{printf $1}'`"  # fix "MacOS/x86_64" or "MacOS/arm64" to "MacOS"
mv $HOME/.zshrc $HOME/.zshrc_bak
ln -s $REPO_PATH/zsh/$platform_fix/zshrc $HOME/.zshrc
echo "zsh config file @: $REPO_PATH/zsh/$platform_fix/zshrc"

# ------------------------------------------------------------------->>>>>>>>>>
# spyder setting (annotate if not use)
# ------------------------------------------------------------------->>>>>>>>>>

echo -e "---------------------------------|\nset spyder config file"
mv $HOME/.spyder-py3 $HOME/.spyder-py3_bak
ln -s $REPO_PATH/spyder/$platform/spyder-py3 $HOME/.spyder-py3
echo "spyder config file @: $REPO_PATH/spyder/$platform/spyder-py3"

# ------------------------------------------------------------------->>>>>>>>>>
# vim setting (annotate if not use)
# ------------------------------------------------------------------->>>>>>>>>>
echo -e "---------------------------------|\nset vim config file"

if test -e $HOME/.vim/vimrc; then      
    echo 'old setting exists, running update steps...'
    cd $HOME/.vim 
    git fetch
    git pull
else
    echo 'old setting does not exist, running git clone steps...'
    rm -rf $HOME/.vim $HOME/.vimrc
    curl https://raw.githubusercontent.com/hermanzhaozzzz/vim-for-coding/master/install.sh | sh
    echo "vim config file @ $HOME/.vim"
fi

# ------------------------------------------------------------------->>>>>>>>>>
# set external apps 
# ------------------------------------------------------------------->>>>>>>>>>
echo -e "---------------------------------|\nset external tools..."
# jcat
echo "set jcat"

if test -e $REPO_PATH/tools/jcat/jcat; then      
    echo 'old setting exists, nothing to do...'
else
    echo 'old setting does not exist, running jcat compiling steps...'
    mkdir -p $REPO_PATH/bin
    rm $REPO_PATH/bin/jcat
    rm $REPO_PATH/tools/jcat/jcat
    cd $REPO_PATH/tools/jcat
    make
    ln -s $REPO_PATH/tools/jcat/jcat $REPO_PATH/bin/jcat
fi
echo "set jcat successful"


# wudao dict
echo "set wd"

if test -e $HOME/.Wudao-dict/wudao-dict/wd; then      
    echo 'old setting exists, running update steps...'
    cd $HOME/.Wudao-dict
    git fetch
    git pull
else
    echo 'old setting does not exist, running git clone steps...'
    git clone git@github.com:hermanzhaozzzz/Wudao-dict.git $HOME/.Wudao-dict
    cd $HOME/.Wudao-dict/wudao-dict
    mkdir ./usr
    chmod -R 777 ./usr
    pip install bs4 lxml
    echo '#!/bin/bash'>./wd
    echo 'save_path=$PWD'>>./wd
    echo 'cd '$PWD >>./wd
    echo './wdd $*'>>./wd
    echo 'cd $save_path'>>./wd
    chmod +x ./wd
    ln -s $HOME/.Wudao-dict/wudao-dict/wd $REPO_PATH/bin/wd
fi
echo "set wd successful"

# end
echo -e "---------------------------------|\nall done"

echo "↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓"
echo -e "well done there! now you should:\n"
echo -e "\t\tsource ~/.zshrc"
echo -e "\t\tconda install -f $CONDA_ENVS/base.yml"
echo "and start to use this environment."
echo "↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑"

echo "ヾ(≧O≦)〃~"
