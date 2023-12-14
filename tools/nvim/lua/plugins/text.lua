-- https://github.com/rmagatti/alternate-toggler
-- Alternate Toggler 是一个非常小的插件，用于切换备用“布尔”值。
return {
  'rmagatti/alternate-toggler',
  config = function()
    require('alternate-toggler').setup {
      alternates = {
        ['==='] = '!==',
        ['=='] = '!=',
        ['error'] = 'warn',
      },
    }

    local keymap = vim.keymap

    keymap.set('n', '<leader>i', '<cmd>ToggleAlternate<cr>')
  end,
}
