-- https://github.com/nvim-lualine/lualine.nvim/wiki/Introduction
-- 为 neovim 编写的状态栏插件。它主要是用 lua 编写的。它的目标是提供一个易于定制和快速的状态栏
return {
  'nvim-lualine/lualine.nvim',
  config = function()
    require('lualine').setup {
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { { 'filename', path = 3 } },
        lualine_c = { 'diagnostics' },
        lualine_x = {},
        lualine_y = {},
        lualine_z = { 'filetype' },
      },
    }
  end,
}
