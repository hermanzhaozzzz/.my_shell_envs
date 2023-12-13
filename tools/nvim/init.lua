require("plugins.plugins-setup")

require("core.options")
require("core.keymaps")

-- 插件
require("plugins.lualine")  -- 需要安装字体
require("plugins.nvim-tree")
require("plugins.treesitter")  -- 依赖gcc
require("plugins.lsp")  -- 需要什么语言就安装什么依赖，具体看plugins.lsp模块写了什么
require("plugins.cmp")  -- 自动补全插件设置！！
require("plugins/comment")  -- 注释代码
require("plugins/autopairs") -- 补全括号
require("plugins/bufferline")
require("plugins/gitsigns")
require("plugins/telescope") -- 环境要安装ripgrep
