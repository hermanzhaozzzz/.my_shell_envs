return {
  'lewis6991/gitsigns.nvim', -- 左则git提示
  config = function()
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    }
  end,
}
