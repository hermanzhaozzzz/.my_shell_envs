# AGENTS.md - AI 编程助手指南

> **⚠️ 全局提示文件**
> 
> 路径：`~/.my_shell_envs/agents_prompts/coding_global.md`  
> 作用：跨项目的通用 AI 助手行为规范  
> 
> 这是全局提示，在为本仓库工作时请首先阅读。

---

> 本文件为在 `.my_shell_envs` 项目上工作的 AI 编程助手提供必要信息。
> 
> **项目**：Shell 环境快速部署  
> **作者**：Hua-nan Herman ZHAO (hermanzhaozzzz@gmail.com)  
> **仓库**：https://github.com/hermanzhaozzzz/.my_shell_envs

---

## 项目概述

这是一个**个人 shell 环境配置仓库**，旨在快速部署一致的跨平台开发环境（Linux、macOS、Windows）。它使用符号链接将本仓库中的配置文件连接到系统位置。

### 核心理念

- **版本控制的环境**：所有 shell 配置都在 git 中跟踪
- **跨平台**：支持 Linux、macOS（Intel/ARM）和 Windows（PowerShell）
- **安全且可恢复**：在替换前备份现有配置
- **Micromamba 为中心**：使用 micromamba 作为 conda/miniconda 的更快替代品

---

## 项目结构

```
.my_shell_envs/
├── mse                           # 主部署/更新脚本
├── README.md                     # 用户文档
├── AGENTS.md                     # 本文件
│
├── zsh/                          # ZSH shell 配置
│   ├── zshrc                     # 主 zsh 配置（在 zprofile 后加载）
│   └── zprofile_hermanzhaozzzz_demo  # 私人设置模板（登录 shell）
│
├── powershell/                   # Windows PowerShell 配置
│   └── Microsoft.PowerShell_profile.ps1  # PowerShell 配置文件
│
├── conda/                        # Conda 环境定义
│   ├── condarc                   # Conda 配置
│   ├── Linux/                    # Linux 环境 YAML 文件
│   ├── MacOS/                    # macOS 环境 YAML 文件
│   ├── Windows/                  # Windows 环境 YAML 文件
│   └── micromamba-pycharm/       # PyCharm micromamba 集成
│
├── spyder/                       # Spyder IDE 配置
│   └── general/spyder-py3/       # Spyder 设置目录
│
├── pip/                          # Pip 配置
│   └── pip.conf                  # Pip 配置（空，使用默认）
│
├── bin/                          # 自定义二进制文件和符号链接
│   ├── mse                       # 指向仓库主脚本的入口
│   └── [各种工具的符号链接]
│
├── tools/                        # 工具配置和源代码
│   ├── jcat/                     # Jupyter notebook 查看器（C++）
│   ├── nvim/                     # Neovim 配置
│   └── foldx/                    # FoldX 工具配置
│
├── fonts/                        # Helvetica 字体文件
├── vscode/                       # VSCode 相关配置
├── agents_prompts/               # AI 助手行为提示
│   └── coding_global.md          # 全局编码规范
└── _back/                        # 备份/遗留文件
```

---

## 技术栈

### Shell 与环境
| 组件 | 技术 |
|-----------|------------|
| 主 Shell | ZSH + Oh-My-Zsh |
| Shell 主题 | `fino` |
| 关键插件 | zsh-syntax-highlighting, zsh-autosuggestions, z |
| 包管理器 | micromamba（conda 替代品） |
| Windows Shell | PowerShell 7+ |

### 编辑器与 IDE
| 编辑器 | 配置来源 |
|--------|---------------------|
| Vim | [vim-for-coding](https://github.com/hermanzhaozzzz/vim-for-coding) |
| Neovim | [MyLazyVim](https://github.com/hermanzhaozzzz/MyLazyVim) |
| Spyder | 本地配置在 `spyder/general/` |

### 外部工具
| 工具 | 用途 | 语言 |
|------|---------|----------|
| jcat | 在终端中查看 Jupyter notebooks | C++ |
| wd | 终端词典 | Python |
| tldr | 简化的 man 页面 | - |
| eza | 现代 ls 替代品 | - |
| bat | 更友好的 `cat` / 文件预览工具 | Rust |
| ripgrep | 终端搜索工具（`rg`） | Rust |

---

## 构建与部署

### 主部署命令

```bash
# 克隆并部署
cd $HOME
git clone https://github.com/hermanzhaozzzz/.my_shell_envs.git
cd ~/.my_shell_envs
./mse deploy                     # Linux/macOS
# 或
git-bash ./mse deploy            # Windows（在 PowerShell 中）
```

### 部署脚本行为 (`mse deploy`)

1. **平台检测**：检测 Linux、macOS（x86_64/ARM64）或 Windows
2. **基础环境检查**：检查 `zsh`，配置 Oh My Zsh、主题、插件、`~/.zshrc`
3. **配置符号链接**：为以下文件创建符号链接：
   - `~/.zshrc` → `zsh/zshrc`
   - `~/.condarc` → `conda/condarc`
   - `~/.pip/pip.conf` → `pip/pip.conf`
   - Vim/Neovim 配置（从外部仓库克隆）
4. **工具构建**：从源代码编译 jcat
5. **默认工具依赖**：准备 Rust 工具链和 repo-managed CLI 工具

### 更新命令

```bash
./mse update
```

该命令：
1. 切换到仓库目录
2. 运行 `git fetch && git pull --rebase`
3. 重新运行 `./mse deploy`

---

## 代码组织

### Shell 配置加载顺序

ZSH 按以下顺序加载配置：
```
.zshenv → .zprofile (login) → .zshrc (interactive) → .zlogin (login) → .zlogout
```

本项目使用：
- **`.zprofile`** (`zsh/zprofile_hermanzhaozzzz_demo`)：私人设置、代理配置、PATH 添加、SSH 别名
- **`.zshrc`** (`zsh/zshrc`)：公共设置、oh-my-zsh、插件、自定义函数、conda 初始化

### 关键自定义函数（在 zshrc 中）

| 函数 | 用途 |
|----------|---------|
| `func_delfile` | 安全删除（移动到回收站而不是 rm） |
| `func_dellist` | 列出回收站中的文件 |
| `func_delback` | 从回收站恢复文件 |
| `func_delclear` | 永久清空回收站 |

### 回收站系统别名

```bash
rm           # 别名到 func_delfile（安全删除）
rrm          # 真实的 /bin/rm 命令
rm.trash.show    # 列出回收站中的文件
rm.trash.back    # 从回收站恢复文件
rm.trash.clear   # 永久删除所有回收站内容
```

---

## 开发规范

### 文件修改规则

1. **切勿直接修改 `zprofile_hermanzhaozzzz_demo`** - 它是个人模板
   - 用户应创建自己的 `~/.zprofile`

2. **向 `bin/` 添加新工具**：
   - 为外部工具创建符号链接：`ln -s /absolute/path/to/tool ~/.my_shell_envs/bin/toolname`
   - 或将编译好的二进制文件直接放在 `bin/` 中

3. **添加 conda 环境**：
   - 将 `.yml` 文件添加到 `conda/<platform>/`
   - 它们将自动符号链接到 `conda_local_env_settings/`

### Git 工作流

- **AI 职责**：仅直接修改文件
- **用户职责**：所有 git 操作（add、commit、push）
- 详见 `agents_prompts/coding_global.md`

### 注释风格

- 用户可见的消息和文档使用中文注释
- 技术/代码注释使用英文
- 使用装饰性分隔符：`# ------------------------------------------------------------------->>>>>>>>`

---

## 测试策略

本项目**没有**自动化测试。测试是手动的：

1. **部署测试**：在新系统上运行 `./mse deploy`
2. **Shell 测试**：打开新终端，验证：
   - ZSH 无错误加载
   - Oh-my-zsh 插件工作正常
   - 别名可用
3. **Conda 测试**：`conda --version` 应显示 micromamba
4. **工具测试**：测试各个工具（jcat、wd 等）

---

## 安全注意事项

### 敏感信息

以下文件可能包含敏感数据：
- `zsh/zprofile_hermanzhaozzzz_demo`：包含 API 密钥（TWENTYFIRST_API_KEY、MORPH_API_KEY）
- `bin/devtunnel`：二进制工具

### 安全最佳实践

1. **API 密钥**：目前硬编码在 zprofile 中 - 考虑使用环境特定文件
2. **代理设置**：配置为特定端口（8234、7890）- 部署前验证
3. **SSH 配置**：zprofile 中的服务器 IP 和主机名

---

## 平台特定说明

### Linux
- Micromamba 安装位置：`$HOME/0.apps/micromamba`
- 支持 Slurm HPC 调度器别名
- 平台特定配置在 `conda/Linux/`

### macOS
- Micromamba 安装位置：`$HOME/micromamba`
- zprofile 中的 Homebrew PATH 设置
- 支持 Intel（x86_64）和 Apple Silicon（ARM64）

### Windows
- 使用 PowerShell 配置文件：`C:\Program Files\PowerShell\7\profile.ps1`
- 需要 Scoop 包管理器
- 使用 Starship 提示符
- PSReadLine 使用 Emacs 键绑定

---

## 添加新功能

### 添加新工具

1. 如果是外部二进制文件：
   ```bash
   cd ~/.my_shell_envs/bin
   ln -s /path/to/binary toolname
   ```

2. 如果需要编译（如 jcat）：
   - 将源代码添加到 `tools/toolname/`
   - 在 `mse` 中添加构建逻辑
   - 在 `bin/` 中创建符号链接

3. 如果是 conda 包：
   - 添加到相应的 `conda/<platform>/base.yml`

### 添加新别名

- **系统范围别名**：添加到 `zsh/zshrc` 的"自定义alias"部分
- **个人别名**：添加到个人 `~/.zprofile`

### 添加新 Conda 环境

在 `conda/<platform>/` 中创建 YAML 文件：
```yaml
name: myenv
channels:
  - conda-forge
dependencies:
  - python=3.x
  - ...
```

---

## 故障排除

### 常见问题

1. **ZSH 无法加载**：确保首先安装 oh-my-zsh
2. **找不到 Micromamba**：检查 zshrc 中的平台特定路径
3. **权限错误**：确保 `mse` 可执行
4. **更新时的 Git 冲突**：手动解决，然后重新运行 `./mse update`

### 恢复

如果出现问题：
1. 检查备份文件（`~/.zshrc_bak`、`~/.condarc_bak` 等）
2. 手动恢复：`mv ~/.zshrc_bak ~/.zshrc`
3. 重新运行部署脚本

---

## 外部依赖

### 部署前必需
- `zsh` 和 `oh-my-zsh`（用于 ZSH 配置）
- `git`
- `bzip2`（用于 micromamba 安装）
- `make`（用于编译 jcat）

### 可选
- `scoop`（Windows 包管理器）

---

## 许可证

自由使用 - 详见 README.md。

---

*最后更新：2026-03-17*
