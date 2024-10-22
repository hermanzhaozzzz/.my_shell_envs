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
        sacct_output = sacct_output.decode("utf8")
        # print(f"sacct_output = {sacct_output}")
        # 从 sacct 的输出中提取作业状态
        status = sacct_output.split("|")[-2].strip()
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
        print("Usage: python3 mysacct.py <jobid>")
        sys.exit(1)
    else:
        # print(sys.argv)
        pass

    jobid_full = sys.argv[1]
    jobid = extract_job_id(jobid_full)

    # print(f"jobid = {jobid}")
    # 获取作业状态
    job_status = get_sacct_status(jobid)

    # 打印最终的状态
    print(job_status)
