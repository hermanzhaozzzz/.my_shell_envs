-- https://github.com/akinsho/toggleterm.nvim
-- 一个 neovim 插件，用于在编辑会话期间保留和切换多个终端
return {
  'akinsho/toggleterm.nvim',
  config = function()
    require('toggleterm').setup {
      open_mapping = [[<c-\>]],
      direction = 'float',
      float_opts = {
        border = 'curved',
        width = 130,
        height = 30,
      },
    }
  end,
}
