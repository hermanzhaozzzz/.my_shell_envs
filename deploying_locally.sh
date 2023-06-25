# get repo path
REPO_PATH=`pwd` 

echo "set conda panels..."
mv $HOME/.condarc $HOME/.condarc_bak && ln -s $REPO_PATH/conda/condarc $HOME/.condarc

# make softlink directory
CONDA_ENVS=$REPO_PATH/conda_local_env_settings
mkdir -p $CONDA_ENVS

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

echo "platform detected: $platform"

for yml in `ls $REPO_PATH/conda/$platform/*.yml`; do
    ln -sf $yml $CONDA_ENVS/`basename $yml`
done

echo "$CONDA_ENVS settings done"
echo "all done"