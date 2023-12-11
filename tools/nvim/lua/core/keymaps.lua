vim.g.mapleader = " "

local keymap = vim.keymap

-- ---------- 插入模式 ---------- --
keymap.set("i", "qw", "<ESC>") -- 使用qw代替ESC键
keymap.set("i", "<C-a>", "<Home>")  -- 使用ctrl a切换至行首
keymap.set("i", "<C-e>", "<End>") -- 使用ctrl e切换至行尾

-- ---------- 视觉模式 ---------- --
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")
keymap.set("v", "<C-a>", "<Home>")  -- 使用ctrl a切换至行首
keymap.set("v", "<C-e>", "<End>")  -- 使用ctrl a切换至行尾

-- ---------- 正常模式 ---------- --
-- 窗口
keymap.set("n", "<leader>sv", "<C-w>v") -- 水平新增窗口
keymap.set("n", "<leader>sh", "<C-w>os") -- 垂直新增窗口

keymap.set("n", "<C-a>", "<Home>")  -- 使用ctrl a切换至行首
keymap.set("n", "<C-e>", "<End>")  -- 使用ctrl a切换至行尾

-- nvim-tree
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")  -- 使用leader键 + e调出目录

-- 取消高亮
keymap.set("n", "<leader>nh", ":nohl<CR>")

-- 切换buffer
keymap.set("n", "<C-l>", ":bnext<CR>")
keymap.set("n", "<C-h>", ":bprevious<CR>")

