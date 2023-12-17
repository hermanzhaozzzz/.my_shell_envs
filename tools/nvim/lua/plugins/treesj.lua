-- https://github.com/Wansmer/treesj
-- 用于拆分/连接数组、哈希、语句、对象、字典等代码块。
return {
    'Wansmer/treesj',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
        local tsj = require 'treesj'

        tsj.setup {
            use_default_keymaps = false,
        }
    end,
}
