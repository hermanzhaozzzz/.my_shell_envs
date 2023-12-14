-- https://github.com/mfussenegger/nvim-lint
-- Neovim 的异步 linter 插件 （>= 0.6.0） 是对内置 Language Server 的补充
-- nvim-lint 对内置语言服务器客户端的补充，适用于没有语言服务器或独立 linter 提供更好结果的语言
-- 非常重要的插件，一定要启用
-- vim
return {
  'mfussenegger/nvim-lint',
  config = function()
    require('lint').linters_by_ft = {
      javascript = { 'eslint_d' },
      typescript = { 'eslint_d' },
      javascriptreact = { 'eslint_d' },
      typescriptreact = { 'eslint_d' },
      python = { 'pylint' },
    }
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      callback = function()
        require('lint').try_lint()
      end,
    })
  end,
}
