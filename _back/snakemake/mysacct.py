#!/usr/bin/env python3

import subprocess
import sys


# 提取作业ID的最后一个部分
def extract_job_id(jobid_full):
    return jobid_full.strip().split()[-1]


# 从 sacct 中获取更详细的状态
def get_sacct_status(jobid):
    try:
        # 调用 sacct 获取作业状态
        sacct_output = subprocess.check_output(["sacct", "-P", "-b", "-n", "-j", jobid])
        sacct_output = sacct_output.decode("utf8").strip()

        # 没有任何输出：通常是 sacct 里暂时还查不到这个 job
        if not sacct_output:
            return "running"

        # 取第一行非空行再解析，避免多行/奇怪输出
        lines = [l for l in sacct_output.splitlines() if l.strip()]
        if not lines:
            return "running"

        first_line = lines[0]
        parts = first_line.split("|")

        # 格式不对，没有足够的字段，保守认为还在跑，避免脚本崩
        if len(parts) < 2:
            return "running"

        # 正常情况下倒数第二个字段是 State
        status = parts[-2].strip()

        if status in {
            "BOOT_FAIL",
            "OUT_OF_MEMORY",
            "DEADLINE",
            "FAILED",
            "NODE_FAIL",
            "PREEMPTED",
            "TIMEOUT",
        } or status.startswith("CANCELLED"):
            return "failed"
        elif status == "COMPLETED":
            return "success"
        elif status in {"SUSPENDED", "PENDING", "RUNNING", "CONFIGURING", "COMPLETING"}:
            return "running"
        else:
            # 不认识的状态一律当作 running，避免误杀
            return "running"

    except subprocess.CalledProcessError:
        # sacct 本身执行失败（比如 slurmdbd 挂了）
        # 这里不要 print，直接保守返回 running，让 Snakemake 继续轮询
        return "running"


# 主程序
if __name__ == "__main__":
    # 获取输入的作业ID字符串
    if len(sys.argv) != 2:
        print("failed")
        sys.exit(1)

    jobid_full = sys.argv[1]
    jobid = extract_job_id(jobid_full)

    # 获取作业状态
    job_status = get_sacct_status(jobid)

    # 打印最终的状态（Snakemake 只允许这一行）
    print(job_status)
