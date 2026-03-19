# 用户全局编程习惯

> 路径：`~/.my_shell_envs/agents_prompts/coding_global.md`
> 作用：跨项目的通用 AI 助手行为规范

## 语言约定

- **与用户交互时全程使用中文**：所有回复、解释、问题、建议都必须使用中文
- **代码注释**：技术实现注释可使用英文，但用户可见的注释使用中文

## Git 工作流约定

- **我（AI）负责**：
  - 直接修改文件内容
  - 使用 git 命令辅助工作（如查看 `git status`、`git diff` 对比变更等）
  
- **用户负责**：
  - 所有会改变仓库状态的 git 操作（`git add`、`git commit`、`git push`、`git reset` 等）
  - 决定是否接受修改、如何分块提交、何时推送

- **边界约定**：
  - **严禁擅自提交**：未经用户明确允许，不得执行 `git commit`
  - **严禁擅自推送**：未经用户明确允许，不得执行 `git push`
  - 每次提交前必须征得用户同意，询问提交信息内容

## 绘图默认约定

- **论文级图件默认初始化方式**：若无项目内强约束，默认优先使用 `bioat.lib.libplot.init_matplotlib`
- **默认初始化模板**：
  ```python
  from bioat.lib.libplot import init_matplotlib

  SET_BACKEND_PDF = True
  SET_BACKEND_PS = True

  init_matplotlib(
      sns_style="white",
      sns_font_scale=1.0,
      set_backend_pdf=SET_BACKEND_PDF,
      set_backend_ps=SET_BACKEND_PS,
  )
  ```
- **默认尺寸**：`figsize` 的宽度强制设为 `7`，高度按内容与版式合理调整
- **默认分辨率**：`dpi` 设为 `300`
- **默认后端与输出考虑**：优先启用 `pdf` 和 `ps` backend，便于后期矢量编辑与版式微调

## 其他全局习惯（待补充）

- 可根据需要在此添加更多跨项目通用的工作习惯
