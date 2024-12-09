echo -e '\n\n'
echo '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
echo '(~/.zprofile) is sourced @' `hostname` 
echo -e '\tapply @ ~/.zprofile (private) settings for zsh'
echo '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'


# ------------------------------------------------------------------->>>>>>>>>>
# global alias
# ------------------------------------------------------------------->>>>>>>>>>
alias ssh.server.veteran="ssh zhaohuanan@162.105.250.73"
alias ssh.server.bioin="ssh zhaohuanan@bioin.vip -p 10006"
alias ssh.server.polaris="ssh chengqiyi_zhn@10.100.1.88"
alias ssh.server.alioth="ssh -o HostKeyAlgorithms=+ssh-rsa,ssh-dss hnzhao@10.100.0.99"

alias checkbam="for i in *.bam ;do (samtools quickcheck \$i && echo \"ok    \" \$i || echo \"error    \" \$i);done"


# global alias for clash proxy 
alias proxy.start='ssh -qTnN -D 8234 zhaohuanan@zhaohuanan.cc'
alias proxy.on='export https_proxy=http://127.0.0.1:8234;export http_proxy=http://127.0.0.1:8234;export all_proxy=socks5://127.0.0.1:8234;export no_proxy="192.168.59.102,192.168.59.103"'
alias proxy.off='unset https_proxy;unset http_proxy;unset all_proxy;git config --global --unset https.proxy; git config --global --unset http.proxy'

proxy.off





# ------------------------------------------------------------------->>>>>>>>>>
# set different settings on different machines
# ------------------------------------------------------------------->>>>>>>>>>

# ------------------------------------------------------------------->>>>>>>>>>
if [[ `hostname` == "login"* || `hostname` == "c"*"b"*"n"* ]]; then
# ------------------------------------------------------------------->>>>>>>>>>

    echo -e '\tmatch polaris server @' $HOST

    # on polars, I need to clean system PATH for DIY usage
    unset PATH
    # for system use
    export PATH=/usr/bin:/usr/lib:/usr/lib64:/usr/libexec:/usr/sbin
    export PATH=$PATH:/usr/local/bin:/usr/local/lib:/usr/local/lib64:/usr/local/libexec
    # start with zsh
    export PATH=/home/chengqiyi_pkuhpc/.local/share/zsh/bin:$PATH
    # I need the slurm system cmds for work
#    export PATH=$PATH:/rm/rm_prog/slurm/18.08.7/bin:/data01/oldbin/newbin
    export PATH=$PATH:/rm/rm_prog/slurm/22.05.6/bin:/data01/oldbin/newbin

    # optional bioinformatic cmds to add
    export PATH=$PATH:${HOME}/0.apps/homer/bin
    export PATH=$PATH:${HOME}/0.apps/HiC-Pro_installed/HiC-Pro_3.1.0/bin
    export PATH=$PATH:${HOME}/0.apps/hisat-3n_allType
    export PATH=$PATH:${HOME}/0.apps/bedops/bin

    # diy cmds for easily using slurm on polars
    func_delslrumlogs(){
        /bin/rm zhn*.err 2> /dev/null
        /bin/rm zhn*.out 2> /dev/null
        /bin/rm job.zhn* 2> /dev/null
    }
    alias rm.slurmlogs=func_delslrumlogs
    alias squeuez="for i in \`squeue -u hnzhao | grep -v 'QOS not permitted' | awk '{print \$1}'\`; do (pkujob | grep \$i | xargs echo); done | grep zhaohn | awk -F '=' '{print \$2}' | awk '{print \$1}'"
    alias squeuey="squeue -u hnzhao"
    
    alias salloc_gpu_a800_8="salloc -N 1 --job-name=nb_gui  --partition=gpu_a800 --gres=gpu:8 --overcommit --mincpus=64"
    alias salloc_gpu_l40_8="salloc -N 1 --job-name=nb_gui  --partition=gpu_l40 --gres=gpu:8 --overcommit --mincpus=64"

    # 开启反向代理隧道
    func_ssh.tunnels.on(){
        # 设置SSH隧道
        ssh -fCNR 8899:localhost:8888 zhaohuanan@162.105.250.206
        ssh -fCNR 8899:localhost:8888 zhaohuanan@zhaohuanan.cc
        echo "隧道已建立"
    }
    alias ssh.tunnels.on=func_ssh.tunnels.on
    # 关闭反向代理隧道
    func_ssh.tunnels.off(){
    # 清理SSH隧道
    tunnels=`ps -ef | grep zhaohuanan | grep ssh | grep localhost`
    echo "将清理以下隧道"
    echo $tunnels
    echo $tunnels | awk '{print "kill -9 "$2}' | sh
    echo "SSH隧道清理完成。"
    }
    alias ssh.tunnels.off=func_ssh.tunnels.off
    # 维持代理隧道服务
    func_ssh.keep.on(){
    # 每小时重启一次
    while true; do
        ssh.tunnels.off
        ssh.tunnels.on
        sleep 3600
    done
    }
    alias ssh.tunnels.keep.on=func_ssh.keep.on

    function run() {
    
    	local flag_a=0
    	local flag_n=0
    
    	local partitions="cn-long fat2way gpu_4l gpu_l40 gpu_l48 gpu_a800"
    	local in_partitions="long 2w 4l l40 l48 a800"
    	local hangflag=0
    	local name='None'
    	local afterflag=0
    	local after=0
    	local argumentnum=1
    	local partition=""
    	local node=0
    	local core=0
    	local account='d_cqyi'
    	local thecommand=""
    	local tmparg=""
    	while [ $# -gt 0 ]; do
    		case $1 in
    		-n | --name)
    			if [[ $flag_n == 0 ]]; then
    				name=$2
    				flag_n=1
    				shift
    				shift
    				continue
    			else
    				thecommand="${thecommand} $1"
    				shift
    			fi
    			;;
    		-a | --hang)
    			if [[ $flag_a == 0 ]]; then
    				hangflag=1
    				flag_a=1
    				shift
    			else
    				thecommand="${thecommand} $1"
    				shift
    			fi
    			;;
    		-h | --help)
    			echo "Usage: \n eg. 1. run [long|2w|         <nodes> <cores> [options] \"<command>\"\n eg. 2. run [4l|l40|l48|a800] <gpus>  <cores> [options] \"<command>\"\n\t-n|--name \tName of the job\n\t-a|--hang \tHang the task till submitted job finished.\nSupported partitions: ${partitions}"
    			return 0
    			;;
    		*)
    			tmparg=$1
    			if [[ $argumentnum == 1 ]]; then # partition
    				if [[ $in_partitions =~ $tmparg ]]; then
    					case $tmparg in
    					long)
    						partition="cn-long"
    						;;
    					2w)
    						partition="fat2way"
    						;;
    					4l)
    						partition="gpu_4l"
    						;;
    					4l)
    						partition="gpu_4l"
    						;;
    					l40)
    						partition="gpu_l40"
    						;;
    					l48)
    						partition="gpu_l48"
    						;;
    					a800)
    						partition="gpu_a800"
    						;;
    					*)
    						echo "No valid parittion"
    						return 1
    						;;
    					esac
    				else
    					echo "No valid partition"
    					return 1
    				fi
    				argumentnum=$(($argumentnum + 1))
    			elif [[ $argumentnum == 2 ]]; then
    				if [[ $tmparg =~ [0-9] ]]; then
    					node=$tmparg
    				else
    					echo "Node number must be like [0-9]"
    					return 1
    				fi
    				argumentnum=$(($argumentnum + 1))
    			elif [[ $argumentnum == 3 ]]; then
    				if [[ $tmparg =~ [0-9] ]]; then
    					core=$tmparg
    				else
    					echo "Core number must be like [0-9]"
    					return 1
    				fi
    				argumentnum=$(($argumentnum + 1))
    			elif [[ $argumentnum == 4 ]]; then
    				thecommand="${thecommand} ${tmparg}"
    			fi
    			shift
    			;;
    		esac
    
    	done
    
    	thetime=$(date "+%d%H%M%S")
    	thetimeident=$(date +%s%3N)
    
    	commandident=${thecommand:0:3}
    	commandidentf=${commandident// /}
    
    	if [[ $name == 'None' ]]; then
    		name="zhn${thetime}_${commandidentf}"
    	else
    		name="zhn_$name"
    	fi
    
    	if [[ ${partition} == "gpu_4l" || ${partition} == "gpu_l40" || ${partition} == "gpu_l48" || ${partition} == "gpu_a800" ]]; then
    		echo "#!/bin/bash\n#SBATCH -J ${name}\n#SBATCH -p ${partition}\n#SBATCH -o ${name}_${thetimeident}_%j.out\n#SBATCH -e ${name}_${thetimeident}_%j.err\n#SBATCH -A ${account}\n#SBATCH --mincpus=${core}\n#SBATCH --gres=gpu:${node}\nsrun ${thecommand}" >job.${name}.${thetimeident}
    	else
    		echo "#!/bin/bash\n#SBATCH -J ${name}\n#SBATCH -p ${partition}\n#SBATCH -N ${node}\n#SBATCH -o ${name}_${thetimeident}_%j.out\n#SBATCH -e ${name}_${thetimeident}_%j.err\n#SBATCH --no-requeue\n#SBATCH -A ${account}\n\n#SBATCH -c ${core}\nsrun ${thecommand}" >job.${name}.${thetimeident}
    	fi
    	chmod +x job.${name}.${thetimeident}
    	if [[ $hangflag == 0 ]]; then
    		sbatch job.${name}.${thetimeident}
    	elif [[ $hangflag == 1 ]]; then
    		srun -c ${core} -N ${node} -J ${name} -p ${partition} -A ${account} -o ${name}_${thetimeident}_%j.out -e ${name}_${thetimeident}_%j.err $(echo "$thecommand" | sed "s/['\"]//g")
    	fi
    	sleep 0.5
    }

# ------------------------------------------------------------------->>>>>>>>>>
elif [[ `hostname` == "zhaohuanan-Ubuntu" || `hostname` == "ThreadRipper" ]]; then
# ------------------------------------------------------------------->>>>>>>>>>
   echo -e '\tmatch my Server @' $HOST 

# ------------------------------------------------------------------->>>>>>>>>>
elif [[ `hostname` == *"Mac"* || `hostname` == "bogon" || `hostname` == "localhost" ]]; then
# ------------------------------------------------------------------->>>>>>>>>>
    echo -e '\tmatch my Mac @ ' $HOST

    # macox alias for surge app proxy replace clash
    alias proxy.on='export https_proxy=http://127.0.0.1:8234;export http_proxy=http://127.0.0.1:8234;export all_proxy=socks5://127.0.0.1:8235;export no_proxy="192.168.59.102,192.168.59.103"'
    
    proxy.on

    # alias on macos
    alias zcat="gunzip -d -c"  # fix zcat
    alias startsc.polaris="open -a DPSafeConnect.app 2> /dev/null || open -a SafeConnect 2> /dev/null && open -a Step\ Two.app"
    alias startsc.alioth="open -a SafeConnect.app 2> /dev/null && open -a Step\ Two.app"
    alias opena="open -a Sublime\ Text"
    alias code="/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code"
    # for arm64
    alias conda_rosetta_echo='\
    echo "CONDA_SUBDIR=osx-64 conda create -n rosetta_env conda python\n# ↑↑↑python_version conda is needed↑↑↑\n# <conda install conda> in the rosetta_env is the best choice\n# when alias micromamba as conda\n\nconda activate rosetta_env\n\n/path_of_python_version/conda env config vars set CONDA_SUBDIR=osx-64\n# ↑↑↑python_version conda is needed for setting CONDA_SUBDIR var↑↑↑\n\nconda deactivate\\nconda activate rosetta_env\n\npython -c \"import platform;print(platform.machine())\"  \n# should output x86_64"\
    '
    # set PATH
    export PATH=$PATH:/Library/TeX/texbin
    export PATH=/opt/homebrew/bin:/opt/homebrew/sbin:$PATH
    export PATH=$PATH:/opt/homebrew/opt/openjdk/bin

fi

# global settings
export PATH=$PATH:${HOME}/.local/bin
export PATH=$PATH:${HOME}/.cargo/bin
# ------------------------------------------------------------------->>>>>>>>>>
# 软件环境变量
# ------------------------------------------------------------------->>>>>>>>>>
# for R
unset R_HOME

# for perl
unset PERL5LIB
#

# C, CXX LIB
# if [ $LD_LIBRARY_PATH ]; then
#     export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${HOME}/.my_shell_envs/ld_lib:${HOME}/0.apps/micromamba/lib
# else
#     export LD_LIBRARY_PATH=${HOME}/.my_shell_envs/ld_lib:${HOME}/0.apps/micromamba/lib
# fi

# CUDA_HOME
# if [ $CUDA_HOME ]; then
#     export CUDA_HOME=$CUDA_HOME:${HOME}/0.apps/cuda/cuda
# else
#     export CUDA_HOME=${HOME}/0.apps/cuda/cuda
# fi

# set trash
export TRASH=${HOME}/.mytrash




