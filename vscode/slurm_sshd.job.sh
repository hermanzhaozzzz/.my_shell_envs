#!/bin/bash
# sbatch --partition=gpu_l40 --cpus-per-task=20 --gres=gpu:1 --mincpus=10 --job-name=🐶code ~/.my_shell_envs/vscode/slurm_sshd.job.sh
#
PORT=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')
PORT=32985

echo "Listening on:" $PORT

/usr/sbin/sshd -D -p ${PORT} -f /dev/null -h ${HOME}/.ssh/id_rsa
