#!/usr/bin/env python3

import subprocess
import sys


# 提取作业ID的最后一个部分
def extract_job_id(jobid_full):
    return jobid_full.strip().split()[-1]


# 获取JobState状态并映射为Snakemake预期的状态
def get_job_status(jobid):
    try:
        # 调用 scontrol 获取作业状态
        scontrol_output = subprocess.check_output(
            ["scontrol", "show", "job", jobid], text=True
        )

        # 从 scontrol 的输出中提取 JobState 的值
        for line in scontrol_output.splitlines():
            if "JobState" in line:
                job_state = line.split("=")[1].split()[0]
                if job_state == "RUNNING":
                    return "running"
                elif job_state == "COMPLETED":
                    return "success"
                else:
                    return "failed"
    except subprocess.CalledProcessError as e:
        print(f"Error executing scontrol: {e}")
        return "failed"


# 从 sacct 中获取更详细的状态
def get_sacct_status(jobid):
    try:
        # 调用 sacct 获取作业状态
        sacct_output = subprocess.check_output(
            ["sacct", "-P", "-b", "-j", jobid], text=True
        )

        # 从 sacct 的输出中提取作业状态
        for line in sacct_output.splitlines():
            status = line.split("|")[1].strip()
            if status == "BOOT_FAIL":
                return "failed"
            elif status == "OUT_OF_MEMORY":
                return "failed"
            elif status.startswith("CANCELLED"):
                return "failed"
            elif status == "DEADLINE":
                return "failed"
            elif status == "FAILED":
                return "failed"
            elif status == "NODE_FAIL":
                return "failed"
            elif status == "PREEMPTED":
                return "failed"
            elif status == "TIMEOUT":
                return "failed"
            elif status == "COMPLETED":
                return "success"
            elif status == "SUSPENDED":
                return "running"
            elif status == "PENDING":
                return "running"
            else:
                return "running"
    except subprocess.CalledProcessError as e:
        print(f"Error executing sacct: {e}")
        return "failed"


# 主程序
if __name__ == "__main__":
    # 获取输入的作业ID字符串
    if len(sys.argv) != 2:
        print("Usage: python3 mysjob.py <jobid>")
        sys.exit(1)

    jobid_full = sys.argv[1]
    jobid = extract_job_id(jobid_full)

    # 获取作业状态
    job_status = get_job_status(jobid)
    if job_status == "failed":
        # 如果 scontrol 结果为 failed，进一步调用 sacct 进行检查
        job_status = get_sacct_status(jobid)

    # 打印最终的状态
    print(job_status)
