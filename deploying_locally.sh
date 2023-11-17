# get repo path
REPO_PATH=`pwd` 
# ------------------------------------------------------------------->>>>>>>>>>
# platform judgement and var setting
# ------------------------------------------------------------------->>>>>>>>>>

echo -e "---------------------------------|\nset conda panels..."

mv $HOME/.condarc $HOME/.condarc_bak
ln -s $REPO_PATH/conda/condarc $HOME/.condarc

platform="`uname`"
platform=`echo $platform | awk -F '_' '{printf $1}'`

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

elif [[ "$platform" == "MINGW64" ]]; then
    platform="Windows"  # TODO, no strategy now
else
    echo "unsupported OS: $platform!"
    exit 1
fi
echo -e "---------------------------------|\nplatform detected: $platform"


# ------------------------------------------------------------------->>>>>>>>>>
# micromamba setting (annotate if not use)
# ------------------------------------------------------------------->>>>>>>>>>
CONDA_ENVS=$REPO_PATH/conda_local_env_settings
if [[ "$platform" != "Windows" ]]; then

    echo -e "---------------------------------|\nset conda env config files..."

    # install micromamba
    if [ ! -f "$ROOT_PATH/bin/micromamba" ];then
        echo "micromamba not found @$ROOT_PATH/bin/! start to install..."
        mkdir -p $ROOT_PATH
        cd $ROOT_PATH
        curl -Ls $URL | tar -xvj bin/micromamba
        cd $REPO_PATH
        # this repo fix pycharm conda, select conda/micromamba-pycharm/conda when using conda in pycharm!
        git clone https://github.com/jonashaag/micromamba-pycharm.git conda/micromamba-pycharm
    else
        echo "micromamba exists @$ROOT_PATH/bin/! skip installing..."
    fi
    # set yml files...
    echo "start to choose env.yml..."
    # make softlink directory
    mkdir -p $CONDA_ENVS

    for yml in `ls $REPO_PATH/conda/$platform/*.yml`; do
        ln -sf $yml $CONDA_ENVS/`basename $yml`
    done
    echo "conda config files @: $CONDA_ENVS "
else
    echo "skip micromamba installing:" $platform
fi
# ------------------------------------------------------------------->>>>>>>>>>
# zsh setting (annotate if not use)
# ------------------------------------------------------------------->>>>>>>>>>
if [[ "$platform" != "Windows" ]]; then
    echo -e "---------------------------------|\nset zsh config file"

    platform_fix="`echo $platform | awk -F '/' '{printf $1}'`"  # fix "MacOS/x86_64" or "MacOS/arm64" to "MacOS"
    rm -rf $HOME/.zshrc_bak
    mv $HOME/.zshrc $HOME/.zshrc_bak
    ln -s $REPO_PATH/zsh/$platform_fix/zshrc $HOME/.zshrc
    echo "zsh config file @: $REPO_PATH/zsh/$platform_fix/zshrc"
else
    echo "zsh not support platform:" $platform
fi

# ------------------------------------------------------------------->>>>>>>>>>
# spyder setting (annotate if not use)
# ------------------------------------------------------------------->>>>>>>>>>
echo -e "---------------------------------|\nset spyder config file"

platform_fix="`echo $platform | awk -F '/' '{printf $1}'`"  # fix "MacOS/x86_64" or "MacOS/arm64" to "MacOS"
rm -rf $HOME/.spyder-py3_bak
mv $HOME/.spyder-py3 $HOME/.spyder-py3_bak
ln -s $REPO_PATH/spyder/MacOS/spyder-py3 $HOME/.spyder-py3
echo "spyder config file @: $REPO_PATH/spyder/MacOS/spyder-py3"

# ------------------------------------------------------------------->>>>>>>>>>
# pip settings (annotate if not use)
# ___________________________________________________________________>>>>>>>>>>
echo -e "---------------------------------|\nset pip config file"

mkdir -p $HOME/.pip
rm -rf $HOME/.pip/pip.conf_bak
mv $HOME/.pip/pip.conf $HOME/.pip/pip.conf_bak
ln -s $REPO_PATH/pip/pip.conf $HOME/.pip/pip.conf
echo "pip config file @: $REPO_PATH/pip/pip.conf"

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
if [[ "$platform" != "Windows" ]]; then
    
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
else
    echo "jcat not support platform:" $platform
fi

# wudao dict
echo "set wd"

if test -e $HOME/.Wudao-dict/wudao-dict/wd; then      
    echo 'old setting exists, running update steps...'
    cd $HOME/.Wudao-dict
    git fetch
    git pull
else
    echo 'old setting does not exist, running git clone steps...'
    git clone https://github.com/hermanzhaozzzz/Wudao-dict.git $HOME/.Wudao-dict
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


# tldr-python-version
echo "set tldr (python version)"
if test -e $REPO_PATH/bin/tldr; then
    echo 'old setting exists, nothing to do...'
else
    pip install tldr
    ln -s `which tldr` $REPO_PATH/bin/tldr
fi
echo "set tldr (python version) successful"

# ------------------------------------------------------------------->>>>>>>>>>
# Windows setting for PowerShell (dependent: git-bash)
# ------------------------------------------------------------------->>>>>>>>>>
if [[ "$platform" == "Windows" ]]; then
    cd $REPO_PATH
    WinProfile="$HOME/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1"
    RepoProfile="$REPO_PATH/powershell/Microsoft.PowerShell_profile.ps1"
    echo -e "---------------------------------|\nset profile @ $WinProfile..."
    rm -rf $WinProfile
    rm -rf $HOME/.condarc
    powershell -File "$REPO_PATH/powershell/deploying_powershell.ps1"
    mv $WinProfile ${WinProfile}_bak
    ln -s $RepoProfile $WinProfile
    echo "profile config file @ $RepoProfile"
    # end
    echo -e "---------------------------------|\nall done"

    echo "↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓"
    echo -e "well done there! now you should:\n"
    echo -e "\t\topen PowerShell to use your environment, something will be installed at the first running!"
    echo -e "\t\tconda install -f $CONDA_ENVS/base.yml  # in powershell!"
    echo "and start to use this environment."
    echo "↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑"

    echo "this window will close after 300s, you can exit now."

    echo "ヾ(≧O≦)〃~"
    sleep 300
else
    # end
    echo -e "---------------------------------|\nall done"

    echo "↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓"
    echo -e "well done there! now you should:\n"
    echo -e "\t\tsource ~/.zshrc"
    echo -e "\t\tconda install -f $CONDA_ENVS/base.yml"
    echo "and start to use this environment."
    echo "↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑"

    echo "ヾ(≧O≦)〃~"
fi


