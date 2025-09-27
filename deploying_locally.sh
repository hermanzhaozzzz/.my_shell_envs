# set git connect method
git_method=${1:-'https'}

if [ $git_method == 'https' ]; then
	url_root="https://github.com/"
elif [ $git_method == 'ssh' ]; then
	url_root="git@github.com:"
else
	echo "git_method must be one of <https|ssh>"
fi
echo "set git connect method: $git_method (https (default) / ssh)"

# get repo path
REPO_PATH=$(pwd)
chmod +x $REPO_PATH/bin/mse_update
# ------------------------------------------------------------------->>>>>>>>>>
# platform judgement and var setting
# ------------------------------------------------------------------->>>>>>>>>>
platform="$(uname)"
platform=$(echo $platform | awk -F '_' '{printf $1}')

if [[ "$platform" == "Linux" ]]; then
	platform="Linux"
	URL=https://micro.mamba.pm/api/micromamba/linux-64/latest
	ROOT_PATH=$HOME/0.apps/micromamba

elif [[ "$platform" == "Darwin" ]]; then
	if [[ "$(uname -p)" == "i386" ]]; then
		platform="MacOS/x86_64"
		URL=https://micro.mamba.pm/api/micromamba/osx-64/latest
		ROOT_PATH=$HOME/micromamba
	elif [[ "$(uname -p)" == "arm" ]]; then
		platform="MacOS/arm64"
		URL=https://micro.mamba.pm/api/micromamba/osx-arm64/latest
		ROOT_PATH=$HOME/micromamba
	fi

elif [[ "$platform" == "MINGW64" ]]; then
	platform="Windows" # TODO, no strategy now
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
	if [ ! -f "$ROOT_PATH/bin/micromamba" ]; then
		echo "micromamba not found @$ROOT_PATH/bin/! start to install..."
		if [ -z "$(which bzip2)" ]; then
			echo "Seems the command 'bzip2' is not installed on your system, please install it first."
			exit 1
		fi
		mkdir -p $ROOT_PATH
		cd $ROOT_PATH
		curl -Ls $URL | tar -xvj bin/micromamba
		cd $REPO_PATH
		# this repo fix pycharm conda, select conda/micromamba-pycharm/conda when using conda in pycharm!
		git clone ${url_root}jonashaag/micromamba-pycharm.git conda/micromamba-pycharm
	else
		echo "micromamba exists @$ROOT_PATH/bin/! skip installing..."
	fi
	# set yml files...
	echo "start to choose env.yml..."
	# make softlink directory
	mkdir -p $CONDA_ENVS

	for yml in $(ls $REPO_PATH/conda/$platform/*.yml); do
		ln -sf $yml $CONDA_ENVS/$(basename $yml)
	done
	echo "conda config files @: $CONDA_ENVS "
else
	echo "skip micromamba installing:" $platform
fi
echo "set micromamba as conda / mamba successful"

echo -e "---------------------------------|\nset conda panels..."

mv $HOME/.condarc $HOME/.condarc_bak
ln -s $REPO_PATH/conda/condarc $HOME/.condarc

echo "set condarc successful"
# ------------------------------------------------------------------->>>>>>>>>>
# zsh setting (annotate if not use)
# ------------------------------------------------------------------->>>>>>>>>>
if [[ "$platform" != "Windows" ]]; then
	echo -e "---------------------------------|\nset zsh config file"

	platform_fix="$(echo $platform | awk -F '/' '{printf $1}')" # fix "MacOS/x86_64" or "MacOS/arm64" to "MacOS"
	/bin/rm -rf $HOME/.zshrc_bak 2>/dev/null
	mv $HOME/.zshrc $HOME/.zshrc_bak
	ln -s $REPO_PATH/zsh/zshrc $HOME/.zshrc
	echo "zsh config file @: $REPO_PATH/zsh/zshrc"
else
	echo "zsh not support platform:" $platform
fi
echo "set zsh config (zshrc) successful"
# ------------------------------------------------------------------->>>>>>>>>>
# spyder setting (annotate if not use)
# ------------------------------------------------------------------->>>>>>>>>>
echo -e "---------------------------------|\nset spyder config file"

platform_fix="$(echo $platform | awk -F '/' '{printf $1}')" # fix "MacOS/x86_64" or "MacOS/arm64" to "MacOS"
/bin/rm -rf $HOME/.spyder-py3_bak 2>/dev/null
mv $HOME/.spyder-py3 $HOME/.spyder-py3_bak
ln -s $REPO_PATH/spyder/general/spyder-py3 $HOME/.spyder-py3
echo "spyder config file @: $REPO_PATH/spyder/general/spyder-py3"
echo "set spyder config successful"
# ------------------------------------------------------------------->>>>>>>>>>
# pip settings (annotate if not use)
# ___________________________________________________________________>>>>>>>>>>
echo -e "---------------------------------|\nset pip config file"

mkdir -p $HOME/.pip
/bin/rm -rf $HOME/.pip/pip.conf_bak 2>/dev/null
mv $HOME/.pip/pip.conf $HOME/.pip/pip.conf_bak
ln -s $REPO_PATH/pip/pip.conf $HOME/.pip/pip.conf
echo "pip config file @: $REPO_PATH/pip/pip.conf"
echo "set pip config successful"
# ------------------------------------------------------------------->>>>>>>>>>
# vim/nvim setting (annotate if not use)
# ------------------------------------------------------------------->>>>>>>>>>
echo -e "---------------------------------|\nset vim config file"

if test -e $HOME/.vim/vimrc; then
	echo 'old setting exists, running update steps...'
	cd $HOME/.vim
	git fetch
	git pull
else
	echo 'old setting does not exist, running git clone steps...'
	cd $HOME
	mv .vim .vimbak &>/dev/null
	mv .vimrc .vimrcbak &>/dev/null
	git clone ${url_root}hermanzhaozzzz/vim-for-coding.git $HOME/.vim
	ln -s .vim/vimrc .vimrc

	echo "vim config file @ $HOME/.vim"
fi
echo "set vim successful"

echo -e "---------------------------------|\nset nvim config file"

if test -e $HOME/.config/nvim/init.lua; then
	echo 'old setting exists, running update steps...'
	cd $HOME/.config/nvim
	git fetch
	git pull
else
	echo 'old setting does not exist, running git clone steps...'
	/bin/rm -rf ~/.cache/nvim 2>/dev/null
	/bin/rm -rf ~/.local/share/nvim 2>/dev/null
	/bin/rm -rf ~/.local/state/nvim 2>/dev/null
	/bin/rm -rf ~/.cache/nvim 2>/dev/null
	git clone ${url_root}hermanzhaozzzz/MyLazyVim.git $HOME/.config/nvim
	echo "nvim config file @ $HOME/.config/nvim"
fi
echo "set nvim successful"
# # ------------------------------------------------------------------->>>>>>>>>>
# # kitty setting (annotate if not use)
# # ------------------------------------------------------------------->>>>>>>>>>
# echo -e "---------------------------------|\nset kitty config file"
# mkdir -p $HOME/.config/kitty
# mv $HOME/.config/kitty $HOME/.config/kitty_bak
# ln -s $REPO_PATH/tools/kitty $HOME/.config/kitty
# echo "set kitty successful"
# ------------------------------------------------------------------->>>>>>>>>>
# set external apps
# ------------------------------------------------------------------->>>>>>>>>>
echo -e "---------------------------------|\nset external tools...\n"

# jcat
echo "set jcat"
if [[ "$platform" != "Windows" ]]; then

	if test -e $REPO_PATH/tools/jcat/jcat; then
		echo 'old setting exists, nothing to do...'
	else
		echo 'old setting does not exist, running jcat compiling steps...'
		mkdir -p $REPO_PATH/bin
		/bin/rm $REPO_PATH/bin/jcat 2>/dev/null
		/bin/rm $REPO_PATH/tools/jcat/jcat 2>/dev/null
		cd $REPO_PATH/tools/jcat
		if [ -z $(which make) ]; then
			echo "Seems the command 'make' is not installed on your system, please install it first."
			exit 1
		fi
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
	git clone ${url_root}hermanzhaozzzz/Wudao-dict.git $HOME/.Wudao-dict
	cd $HOME/.Wudao-dict/wudao-dict
	mkdir ./usr
	chmod -R 777 ./usr
	pip install bs4 lxml
	echo '#!/bin/bash' >./wd
	echo 'save_path=$PWD' >>./wd
	echo 'cd '$PWD >>./wd
	echo './wdd $*' >>./wd
	echo 'cd $save_path' >>./wd
	chmod +x ./wd
	ln -s $HOME/.Wudao-dict/wudao-dict/wd $REPO_PATH/bin/wd
fi
echo "set wd successful"

# tldr
echo "set tldr"
if test -e $REPO_PATH/bin/tldr; then
	echo 'old setting exists, nothing to do...'
else
	/bin/rm ~/.my_shell_envs/bin/tldr 2>/dev/null
	ln -s $ROOT_PATH/bin/tldr ~/.my_shell_envs/bin/tldr
fi
echo "set tldr successful"

# ------------------------------------------------------------------->>>>>>>>>>
# Windows setting for PowerShell (dependent: git-bash)
# ------------------------------------------------------------------->>>>>>>>>>
if [[ "$platform" == "Windows" ]]; then
	cd $REPO_PATH

    mkdir -p /c/Program\ Files/PowerShell/7
	WinProfile=/c/Program\ Files/PowerShell/7/profile.ps1
	RepoProfile="$REPO_PATH/powershell/Microsoft.PowerShell_profile.ps1"
	echo -e "---------------------------------|\nset profile softlink @ $WinProfile..."
	/bin/rm -rf $HOME/.condarc 2>/dev/null
	powershell -File $RepoProfile
	mv $WinProfile ${WinProfile}_bak
	ln -s $RepoProfile $WinProfile
	echo "profile config file @ $RepoProfile"
	# end
	echo -e "---------------------------------|\nall done"

	echo "↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓"
	echo -e "well done there! now you should:\n"
	echo -e "\t\topen PowerShell to use your environment, something will be installed at the first running!"
	echo -e "\t\tconda activate base"
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
	echo -e "\t\tconda activate base"
	echo -e "\t\tconda install -f $CONDA_ENVS/base.yml"
	echo "and start to use this environment."
	echo "↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑"

	echo "ヾ(≧O≦)〃~"
fi

echo "Tips:"
echo -e "\t raise issue on https://github.com/hermanzhaozzzz/.my_shell_envs/issues"
