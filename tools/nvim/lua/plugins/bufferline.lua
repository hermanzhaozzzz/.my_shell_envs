-- https://github.com/akinsho/bufferline.nvim
-- 实现neovim中的标签页样式
return {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = 'VeryLazy',
    keys = {
        { '<leader>bp', '<Cmd>BufferLineTogglePin<CR>', desc = 'Toggle pin' },
        {
            '<leader>brp',
            '<Cmd>BufferLineGroupClose ungrouped<CR>',
            desc = 'Delete non-pinned buffers',
        },
        {
            '<leader>bro',
            '<Cmd>BufferLineCloseOthers<CR>',
            desc = 'Delete other buffers',
        },
        {
            '<leader>brd',
            '<Cmd>BufferLineCloseRight<CR>',
            desc = 'Delete buffers to the right',
        },
        {
            '<leader>ara',
            '<Cmd>BufferLineCloseLeft<CR>',
            desc = 'Delete buffers to the left',
        },
        { '<leader>ba', '<Cmd>BufferLineCyclePrev<CR>', desc = 'Prev buffer' },
        { '<leader>bd', '<Cmd>BufferLineCycleNext<CR>', desc = 'Next buffer' },
    },
    opts = {
        options = {
            -- 使用 nvim 内置lsp
            diagnostics = 'nvim_lsp',
            -- 左侧让出 nvim-tree 的位置
            offsets = {
                {
                    filetype = 'NvimTree',
                    text = 'File Explorer',
                    highlight = 'Directory',
                    text_align = 'left',
                },
            },
        },
    },
}
