vim.g.mapleader = " "

local keymap = vim.keymap

-- ---------- 插入模式 ---------- --
keymap.set("i", "wq", "<ESC>")     -- 使用qw代替ESC键
keymap.set("i", "<C-a>", "<Home>") -- 使用ctrl a切换至行首
keymap.set("i", "<C-e>", "<End>")  -- 使用ctrl e切换至行尾

-- ---------- 视觉模式 ---------- --
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")
keymap.set("v", "<C-a>", "<Home>") -- 使用ctrl a切换至行首
keymap.set("v", "<C-e>", "<End>")  -- 使用ctrl a切换至行尾

-- ---------- 正常模式 ---------- --
-- 窗口
keymap.set("n", "<leader>sv", "<C-w>v")  -- 水平新增窗口
keymap.set("n", "<leader>sh", "<C-w>os") -- 垂直新增窗口

keymap.set("n", "<C-a>", "<Home>")       -- 使用ctrl a切换至行首
keymap.set("n", "<C-e>", "<End>")        -- 使用ctrl a切换至行尾

-- nvim-tree
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>") -- 使用leader键 + e调出目录

-- 取消高亮
keymap.set("n", "<leader>nh", ":nohl<CR>")

-- 切换buffer
keymap.set("n", "<leader>we", ":bnext<CR>")
keymap.set("n", "<leader>wq", ":bprevious<CR>")

-- 格式化代码
-- cf: code format
keymap.set("n", "<leader>cf", ":lua vim.lsp.buf.format()<CR>")

-- 查找文件和代码 (依赖插件：telescope.builtin, 进入telescope页面会是插入模式，回到正常模式就可以用j和k来移动了) 
-- see lua/plugins/telescope.lua

-- 补全代码相关快捷键
-- see lua/plugins/cmp.lua

-- 代码、函数、类的定义、声明、引用，代码间跳转
-- see lua/plugins/lsp.lua