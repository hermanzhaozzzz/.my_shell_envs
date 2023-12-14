vim.g.mapleader = " "

local keymap = vim.keymap
-- ---------- 全距快捷键 ---------- --
-- 使用ctrl a切换至行首, 使用ctrl e切换至行尾
keymap.set("i", "<C-a>", "<Home>")
keymap.set("i", "<C-e>", "<End>")
keymap.set("v", "<C-a>", "<Home>")
keymap.set("v", "<C-e>", "<End>")
keymap.set("n", "<C-a>", "<Home>")
keymap.set("n", "<C-e>", "<End>")
-- Shift+CMD+j/k 下/上移动当前行
keymap.set('n', '<D-J>', '<Cmd>m .+1<CR>==',        { silent = true, remap = false })
keymap.set('n', '<D-K>', '<Cmd>m .-2<CR>==',        { silent = true, remap = false })
keymap.set('i', '<D-J>', '<Esc><Cmd>m .+1<CR>==gi', { silent = true, remap = false })
keymap.set('i', '<D-K>', '<Esc><Cmd>m .-2<CR>==gi', { silent = true, remap = false })
keymap.set('v', '<D-J>', ':m \'>+1<CR>gv=gv',       { silent = true, remap = false })
keymap.set('v', '<D-K>', ':m \'<-2<CR>gv=gv',       { silent = true, remap = false })

-- ---------- 插入模式 ---------- --
keymap.set("i", "wq", "<ESC>")     -- 使用qw代替ESC键

-- ---------- 视觉模式 ---------- --
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- ---------- 正常模式 ---------- --
-- 
-- <leader>rn 切换相对行号

-- 窗口
keymap.set("n", "<leader>wv", vim.cmd.vsplit, { silent = true, remap = false })  -- 水平新增窗口
keymap.set("n", "<leader>wh", vim.cmd.split,  { silent = true, remap = false }) -- 垂直新增窗口
keymap.set(  -- 相对行号、绝对行号
    'n',
    '<Leader>wr', 
    function()
        vim.opt.relativenumber = not vim.opt.relativenumber:get()
    end,
    { silent = true, remap = false }
)
-- nvim-tree
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>") -- 使用leader键 + e调出目录

-- 取消高亮
keymap.set("n", "<leader>nh", ":nohl<CR>")

-- 切换buffer
keymap.set("n", "<leader>.", ":bnext<CR>")
keymap.set("n", "<leader>,", ":bprevious<CR>")

-- 格式化代码
-- cf: code format
keymap.set("n", "<leader>cf", ":lua vim.lsp.buf.format()<CR>")

-- 查找文件和代码 (依赖插件：telescope.builtin, 进入telescope页面会是插入模式，回到正常模式就可以用j和k来移动了) 
-- 环境里要安装ripgrep!
-- see lua/plugins/telescope.lua
local builtin = require('telescope.builtin')
-- ff: search file
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
-- fc: search code
vim.keymap.set('n', '<leader>fc', builtin.live_grep, {})  -- 环境里要安装ripgrep
-- fb: search buffer
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
-- fh: search help
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})


-- 补全代码相关快捷键
-- see lua/plugins/cmp.lua

-- 代码、函数、类的定义、声明、引用，代码间跳转
-- see lua/plugins/lsp.lua

-- 为了利用一些“LSP 功能”，我们需要创建一些键绑定。
-- 每当语言服务器附加到缓冲区时，Neovim 都会发出该事件 LspAttach ，这将使我们有机会创建键绑定
-- 此自动命令可以存在于我们配置中的任何位置
-- https://vonheikemen.github.io/devlog/tools/setup-nvim-lspconfig-plus-nvim-cmp/
vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function()
        local bufmap = function(mode, lhs, rhs)
            local opts = { buffer = true }
            vim.keymap.set(mode, lhs, rhs, opts)
        end
        -- Displays hover information about the symbol under the cursor
        -- 显示光标下符号的悬停信息
        bufmap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')

        -- Jump to the definition
        -- 跳转到定义
        bufmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')

        -- Jump to declaration
        -- 跳转到声明
        bufmap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')

        -- Lists all the implementations for the symbol under the cursor
        -- 列出光标下的符号的所有实现
        bufmap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')

        -- Jumps to the definition of the type symbol
        -- 跳转到类型符号的定义
        bufmap('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>')

        -- Lists all the references
        -- 列出所有引用项
        bufmap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')

        -- Displays a function's signature information
        -- 显示函数的签名信息
        bufmap('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>')

        -- Renames all references to the symbol under the cursor
        -- 重命名光标下对符号的所有引用
        bufmap('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>')

        -- Selects a code action available at the current cursor position
        -- 选择当前光标位置上可用的代码操作
        bufmap('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>')

        -- Show diagnostics in a floating window
        -- 在浮动窗口中显示诊断
        bufmap('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')

        -- Move to the previous diagnostic
        bufmap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')

        -- Move to the next diagnostic
        bufmap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')
    end
})
