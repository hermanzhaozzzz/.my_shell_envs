-- https://github.com/akinsho/bufferline.nvim
-- 实现neovim中的标签页样式
return {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = 'VeryLazy',
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
                    separator = true,
                },
            },
        },
    },
}
