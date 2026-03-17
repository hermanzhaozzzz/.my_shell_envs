# 用户全局编程习惯

> 路径：`~/.my_shell_envs/agents_prompts/coding_global.md`
> 作用：跨项目的通用 AI 助手行为规范

## Git 工作流约定

- **我（AI）负责**：直接修改文件内容
- **用户负责**：所有 git 操作（`git status`、`git diff`、`git add`、`git commit`、`git push` 等）
- **边界约定**：
  - 我可以提醒修改完成、建议使用 `git diff` 查看
  - 我不会执行任何 git 命令（包括 `git add`、`git commit`、`git reset` 等）
  - 用户自行决定是否接受修改、如何分块添加到暂存区、何时提交

## 其他全局习惯（待补充）

- 可根据需要在此添加更多跨项目通用的工作习惯
