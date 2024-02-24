# set ZSH
ZSH_SET=${1:-'new'}

if [ $ZSH_SET == 'old' ]; then
	PROFILE=/lustre3/chengqiyi_pkuhpc/folder_for_learning/zhaohn/.bash_profile_old
elif [ $ZSH_SET == 'new' ]; then
	PROFILE=/lustre3/chengqiyi_pkuhpc/folder_for_learning/zhaohn/.bash_profile
else
	echo "param ZSH_SET must be one of <old|new>"
	echo "old for salloc use, and new for daily jupyterlab use"
fi
echo -e "\n!!! -> set ZSH_SET: $ZSH_SET (new (default) / old)"

echo -e "\n!!! -> will source profile @ $PROFILE"
echo -e "\n"

cat /lustre3/chengqiyi_pkuhpc/folder_for_learning/zhaohn/README.md

echo "-------------------------------------"
echo "My Disk Usage:"
echo "-------------------------------------"
cat /lustre3/chengqiyi_pkuhpc/folder_for_learning/zhaohn/__diskusage.my_space.tsv

echo -e "\n!!! -> use [ nohup df_h_all.sh & ]\n\tto check diskusage per week!"

cd /lustre3/chengqiyi_pkuhpc/folder_for_learning/zhaohn/
echo 'NOW @ HOME ==>> /lustre3/chengqiyi_pkuhpc/folder_for_learning/zhaohn'
source $PROFILE

