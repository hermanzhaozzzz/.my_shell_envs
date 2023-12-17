-- https://github.com/folke/todo-comments.nvim
-- todo-comments 是 Neovim >= 0.8.0 的 lua 插件，用于 BUG 在代码库中突出显示和搜索 todo 注释，如 ， 。 TODO HACK
return {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        require('todo-comments').setup()
    end,
}
