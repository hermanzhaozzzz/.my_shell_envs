local mode_n = { 'n' }
local mode_v = { 'v' }
local mode_i = { 'i' }
local mode_t = { 't' }
local mode_t = { 't' }
local mode_nv = { 'n', 'v' }
local mode_global = { 'n', 'i', 'x', 's', 'v' }
local opt_n = { noremap = true }
local opt_nb = { noremap = true, buffer = true }
-- dependencies
local telescope_builtin = require 'telescope.builtin'
local treesj_toggle = require('treesj').toggle
local todo_comments = require 'todo-comments'
local conform_format = require('conform').format
-- /dependencies
--
local nmappings = {
    --keymap.set('n', '<leader>wr', function()
    --   vim.opt.relativenumber = not vim.opt.relativenumber:get()
    --end, { silent = true, remap = false })

    ----------------------------------------------------------------

    -- --------------------------------------------------
    -- -- basic setting
    -- --------------------------------------------------
    -- shift + a                                     全选
    -- keymap.set('n', 'A', 'ggVG')
    -- base
    -- keymap.set('i', 'wq', '<ESC>') -- 使用qw代替ESC键
    { -- easy key for key ESC
        from = 'wq',
        to = '<ESC><ESC>',
        mode = mode_global,
        opt = opt_n,
    },
    { -- turn off highlight of searched things
        from = '<leader>nh',
        to = ':nohl<CR>',
        mode = mode_n,
        opt = opt_n,
    },
    { -- exit without saving
        from = '<leader>-q>',
        to = ':q<CR>',
        mode = mode_n,
        opt = opt_n,
    },
    { -- save
        from = '<leader>s',
        to = ':w<CR>:lua vim.notify("exec save file.")<CR>',
        mode = mode_n,
        opt = opt_nb,
    },
    { -- drop this shortkey!
        from = '<leader>ud',
        to = '<nop>',
        mode = mode_n,
        opt = opt_n,
    },
    { -- undo
        from = '<leader>z',
        to = ':undo<CR>==',
        mode = mode_n,
        opt = opt_n,
    },
    { -- redo
        from = '<leader>Z',
        to = ':redo<CR>==',
        mode = mode_n,
        opt = opt_n,
    },

    -- {
    --     from = 'ca',
    --     to = ':! xclip -sel c %<CR><CR>:lua vim.notify("exec line copy!")<CR>',
    --     mode = mode_nv,
    --     opt = opt_n,
    -- },
    -- { -- 禁用文本高亮显示
    --     from = '<leader><cr>',
    --     to = ':noh<CR>',
    --     mode = mode_n,
    --     opt = opt_n,
    -- },

    -- --------------------------------------------------
    -- -- move
    -- --------------------------------------------------
    { -- 使用ctrl a切换至行首
        from = '<C-a>',
        to = '<Home>',
        mode = mode_global,
        opt = opt_n,
    },
    { -- 使用ctrl e切换至行尾
        from = '<C-e>',
        to = '<End>',
        mode = mode_global,
        opt = opt_n,
    },
    { -- 使用j切换到下一行
        from = 'j',
        to = 'gj',
        mode = mode_nv,
        opt = opt_n,
    },
    { -- 使用k切换到上一行
        from = 'k',
        to = 'gk',
        mode = mode_nv,
        opt = opt_n,
    },
    { -- 使用H切换到行首第一个可见字符前
        from = 'H',
        to = '^',
        mode = mode_nv,
        opt = opt_n,
    },
    { -- 使用L切换到行末最后一个可见字符前 TODO 这里还没想好用什么方法完成，暂时占个空
        from = 'L',
        to = '$',
        mode = mode_nv,
        opt = opt_n,
    },
    { -- 使用J切换到下10行
        from = 'J',
        to = '10j',
        mode = mode_nv,
        opt = opt_n,
    },
    { -- 使用K切换到上10行
        from = 'K',
        to = '10k',
        mode = mode_nv,
        opt = opt_n,
    },
    { -- 使用ctrl l在输入模式下向右移动
        from = '<C-l>',
        to = '<Right>',
        mode = mode_i,
        opt = opt_n,
    },
    { -- 使用ctrl h在输入模式下向左移动
        from = '<C-h>',
        to = '<Left>',
        mode = mode_i,
        opt = opt_n,
    },
    { -- 使用ctrl k在可视模式上移一行
        from = '<C-k>',
        to = '<cmd>m .-2<cr>gv=gv',
        mode = mode_i,
        opt = opt_n,
    },
    { -- 使用ctrl j在可视模式下移一行

        from = '<C-j>',
        to = ":m '>+1<cr>gv=gv",
        mode = mode_i,
        opt = opt_n,
    },
    { -- 使用ctrl k在普通模式上移一行
        from = '<C-k>',
        to = ':m .-2<CR>==',
        mode = mode_n,
        opt = opt_n,
    },
    { -- 使用ctrl j在普通模式下移一行
        from = '<C-j>',
        to = ':m .+1<CR>==',
        mode = mode_n,
        opt = opt_n,
    },

    -- --------------------------------------------------
    -- -- toc supported by nvim-tree
    -- --------------------------------------------------
    { -- toggle toc open/close
        from = '<leader>e',
        to = ':NvimTreeToggle<CR>',
        mode = mode_n,
        opt = opt_n,
    },
    --  --------------------------------------------------
    --  -- buffers and windows: split/goto/resize/list window/buffers
    --  --------------------------------------------------
    { -- 右侧新增窗口(光标停留在右侧)
        from = '<leader>wl',
        to = ':set splitright<CR>:vsplit<CR>',
        mode = mode_n,
        opt = opt_n,
    },
    { -- 下方新增窗口（光标停留在下方）
        from = '<leader>wj',
        to = ':set splitbelow<CR>:split<CR>',
        mode = mode_n,
        opt = opt_n,
    },
    { -- 左侧新增窗口（光标停留在左侧）
        from = '<leader>wh',
        to = ':set nosplitright<CR>:vsplit<CR>',
        mode = mode_n,
        opt = opt_n,
    },
    { -- 上方新增窗口（光标停留在上方）
        from = '<leader>wk',
        to = ':set nosplitbelow<CR>:split<CR>',
        mode = mode_n,
        opt = opt_n,
    },

    { -- 保存并退出本窗口
        from = '<leader>wq',
        to = ':w<CR>:bd<CR>',
        mode = mode_n,
        opt = opt_n,
    },
    { -- turn left buffer
        from = '<leader>w,',
        to = ':BufferLineCyclePrev<CR>',
        mode = mode_n,
        opt = opt_n,
    },
    { -- turn right buffer
        from = '<leader>w.',
        to = ':BufferLineCycleNext<CR>',
        mode = mode_n,
        opt = opt_n,
    },
    { -- new bufferline
        from = '<leader>wn',
        to = ':tabnew<CR>',
        mode = mode_n,
        opt = opt_n,
    },
    { -- list all bufferlines
        from = '<leader>wa',
        to = ':tabs<CR>',
        mode = mode_n,
        opt = opt_n,
    },
    { -- pin or un-pin a buffer
        from = '<leader>wp',
        to = ':BufferLineTogglePin<CR>',
        mode = mode_n,
        opt = opt_n,
    },
    { -- close un-pinned buffers
        from = '<leader>wrg',
        to = ':BufferLineGroupClose ungrouped<CR>',
        mode = mode_n,
        opt = opt_n,
    },
    { -- close other buffers except this buffer
        from = '<leader>wro',
        to = ':BufferLineCloseOthers<CR>',
        mode = mode_n,
        opt = opt_n,
    },
    { -- close all buffers to the right
        from = '<leader>wrl',
        to = ':BufferLineCloseRight<CR>',
        mode = mode_n,
        opt = opt_n,
    },
    { -- close all buffers to the left
        from = '<leader>wrh',
        to = ':BufferLineCloseLeft<CR>',
        mode = mode_n,
        opt = opt_n,
    },

    -- --------------------------------------------------
    -- -- telescope: find files / codes / bufferlines
    -- --------------------------------------------------
    { -- ff: search file
        from = '<leader>ff',
        to = telescope_builtin.find_files,
        mode = mode_n,
        opt = opt_n,
    },
    { -- fc: search code, -- 环境里要安装ripgrep
        from = '<leader>fc',
        to = telescope_builtin.live_grep,
        mode = mode_n,
        opt = opt_n,
    },
    { -- fw: search window (buffer)
        from = '<leader>fw',
        to = telescope_builtin.buffers,
        mode = mode_n,
        opt = opt_n,
    },
    { -- fh: search help
        from = '<leader>fh',
        to = telescope_builtin.help_tags,
        mode = mode_n,
        opt = opt_n,
    },
    -- --------------------------------------------------
    -- -- treesj
    -- --------------------------------------------------
    { -- toggle collapse or uncollapse
        from = '<leader>fj',
        to = treesj_toggle,
        mode = mode_n,
        opt = opt_n,
    },
    { -- toggle recursive collapse or uncollapse
        from = '<leader>fJ',
        to = function()
            treesj_toggle { split = { recursive = true } }
        end,
        mode = mode_n,
        opt = opt_n,
    },
    -- --------------------------------------------------
    -- -- todo-comments
    -- --------------------------------------------------
    { -- jump to next TODO
        from = '<leader>dj',
        to = function()
            todo_comments.jump_next()
        end,
        mode = mode_n,
        opt = opt_n,
    },
    { -- jump to previous TODO
        from = '<leader>dk',
        to = function()
            todo_comments.jump_prev()
        end,
        mode = mode_n,
        opt = opt_n,
    },
    { -- telescope search TODO in this project
        from = '<leader>da',
        to = ':TodoTelescope<CR>',
        mode = mode_n,
        opt = opt_n,
    },
    -- --------------------------------------------------
    -- -- conform
    -- --------------------------------------------------
    { -- format code
        from = '<leader>ff',
        to = function()
            conform_format { async = false, lsp_fallback = true }
            vim.notify 'code formated by conform.'
        end,
        mode = mode_n,
        opt = opt_n,
    },

    -- --------------------------------------------------
    -- --alternate-toggler
    -- --------------------------------------------------
    { -- toggle for alternative bool value
        from = '<leader>fb',
        to = ':ToggleAlternate<CR>',
        mode = mode_n,
        opt = opt_n,
    },
}
-- brew install neovide
-- TODO
-- 这里发现设置了neovide也无效,回头研究为什么
if vim.g.neovide then
    -- only work in neovide! zoom in and zoom out
    vim.o.guifont = 'JetbrainsMono Nerd Font:h14:i'
    vim.g.neovide_scale_factor = 1.15
    -- dynamic scale
    local change_scale_factor = function(delta)
        vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
    end
    vim.keymap.set('n', '<CMD-=', function()
        change_scale_factor(1.1)
    end)
    vim.keymap.set('n', '<CMD--', function()
        change_scale_factor(1 / 1.1)
    end)
    -- 在neovide中需要重新设置CMD + v,因为在iterm2中使用的是系统级的CMD+vim
    -- 而在neovide中初始化就屏蔽掉了系统级按键,于是需要自己设置
    vim.api.nvim_set_keymap(
        '',
        '<CMD-v>',
        '+p<CR>',
        { noremap = true, silent = true }
    )
    vim.api.nvim_set_keymap(
        '!',
        '<CMD-v>',
        '<C-R>+',
        { noremap = true, silent = true }
    )
    vim.api.nvim_set_keymap(
        't',
        '<CMD-v>',
        '<C-R>+',
        { noremap = true, silent = true }
    )
    vim.api.nvim_set_keymap(
        'v',
        '<CMD-v>',
        '<C-R>+',
        { noremap = true, silent = true }
    )
end
-- -- Allow clipboard copy paste in neovim

-- 为了利用一些“LSP 功能”，我们需要创建一些键绑定。
-- 每当语言服务器附加到缓冲区时，Neovim 都会发出该事件 LspAttach ，这将使我们有机会创建键绑定
-- 此自动命令可以存在于我们配置中的任何位置
-- https://vonheikemen.github.io/devlog/tools/setup-nvim-lspconfig-plus-nvim-cmp/
-- vim.api.nvim_create_autocmd('LspAttach', {
--     desc = 'LSP actions',
--     callback = function()
--         local bufmap = function(mode, lhs, rhs)
--             local opts = { buffer = true }
--             vim.keymap.set(mode, lhs, rhs, opts)
--         end
--         -- Displays hover information about the symbol under the cursor
--         -- 显示光标下符号的悬停信息
--         bufmap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')

--         -- Jump to the definition
--         -- 跳转到定义
--         bufmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')

--         -- Jump to declaration
--         -- 跳转到声明
--         bufmap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')

--         -- Lists all the implementations for the symbol under the cursor
--         -- 列出光标下的符号的所有实现
--         bufmap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')

--         -- Jumps to the definition of the type symbol
--         -- 跳转到类型符号的定义
--         bufmap('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>')

--         -- Lists all the references
--         -- 列出所有引用项
--         bufmap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')

--         -- Displays a function's signature information
--         -- 显示函数的签名信息
--         bufmap('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>')

--         -- Renames all references to the symbol under the cursor
--         -- 重命名光标下对符号的所有引用
--         bufmap('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>')

--         -- Selects a code action available at the current cursor position
--         -- 选择当前光标位置上可用的代码操作
--         bufmap('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>')

--         -- Show diagnostics in a floating window
--         -- 在浮动窗口中显示诊断
--         bufmap('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')

--         -- Move to the previous diagnostic
--         bufmap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')

--         -- Move to the next diagnostic
--         bufmap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')
--     end,
-- })
-- 注册所有快捷键
for _, mapping in ipairs(nmappings) do
    vim.keymap.set(mapping.mode or 'n', mapping.from, mapping.to, mapping.opt)
end

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    pattern = '*.md',
    callback = function()
        for _, mapping in ipairs(MarkdownSnippets) do
            vim.keymap.set(
                mapping.mode or 'n',
                mapping.from,
                mapping.to,
                mapping.opt
            )
        end
    end,
})
