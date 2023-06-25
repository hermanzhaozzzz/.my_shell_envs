# get repo path
REPO_PATH=`pwd` 
echo -e "---------------------------------|\nset conda panels..."

mv $HOME/.condarc $HOME/.condarc_bak && ln -s $REPO_PATH/conda/condarc $HOME/.condarc

platform="`uname`"

if [[ "$platform" == "Linux" ]]; then
    platform="Linux"
elif [[ "$platform" == "Darwin" ]]; then
    platform="MacOS"

    if [[ "`uname -p`" == "i386" ]]; then
        platform="MacOS/x86_64"
    elif [[ "`uname -p`" == "arm" ]]; then
        platform="MacOS/arm64"
    fi
elif [[ "$platform" == "WindowsNT" ]]; then
    platform="Windows"
else
    echo "unsupported OS: $platform!"
    exit 1
fi
echo -e "---------------------------------|\nplatform detected: $platform"

echo -e "---------------------------------|\nset conda env config files..."
# make softlink directory
CONDA_ENVS=$REPO_PATH/conda_local_env_settings
mkdir -p $CONDA_ENVS

for yml in `ls $REPO_PATH/conda/$platform/*.yml`; do
    ln -sf $yml $CONDA_ENVS/`basename $yml`
done
echo "conda config files @: $CONDA_ENVS "


echo -e "---------------------------------|\nset zsh config file"

platform="`echo $platform | awk -F '/' '{printf $1}'`"  # fix "MacOS/x86_64" or "MacOS/arm64" to "MacOS"
mv $HOME/.zshrc $HOME/.zshrc_bak && ln -s $REPO_PATH/zsh/$platform/zshrc $HOME/.zshrc
echo "zsh config file @: $REPO_PATH/zsh/$platform/zshrc"

echo -e "---------------------------------|\nall done"