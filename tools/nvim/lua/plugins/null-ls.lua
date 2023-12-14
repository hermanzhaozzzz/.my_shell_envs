-- https://github.com/jose-elias-alvarez/null-ls.nvim
-- 使用 Neovim 作为语言服务器，通过 Lua 注入 LSP 诊断、代码操作等。
-- null-ls 现已存档，将不再接收更新。有关详细信息，请参阅此问题。
-- https://github.com/jose-elias-alvarez/null-ls.nvim/issues/1621
return {
  'jose-elias-alvarez/null-ls.nvim',
  config = function()
    require('null-ls').setup {
      null_ls = {
        enabled = true,
      },
    }
  end,
}
