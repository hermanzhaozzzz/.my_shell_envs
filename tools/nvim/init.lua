require("plugins.plugins-setup") -- 先引用配置插件所用的setup，即packer

require("core.options")          -- 然后加载neovim的基本设置
-- require("core.utils")  -- 辅助模块

-- 引用各种插件
require("plugins.lualine")    -- 需要安装字体
require("plugins.nvim-tree")  -- 目录插件
require("plugins.treesitter") -- 依赖gcc
require("plugins.lsp")        -- 需要什么语言就安装什么依赖，具体看plugins.lsp模块写了什么
require("plugins.cmp")        -- 自动补全插件设置！！
require("plugins/comment")    -- 注释代码
require("plugins/autopairs")  -- 补全括号
require("plugins/bufferline")
require("plugins/gitsigns")
require("plugins/telescope") -- 环境要安装ripgrep
-- 全局设置快捷键
require("core.keymaps")      -- 放最后的原因是，这里也设置了许多插件的相关快捷键
