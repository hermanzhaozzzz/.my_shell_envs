-- https://github.com/stevearc/conform.nvim
-- 轻量级但功能强大的 Neovim 格式化程序插件
-- brew install isort black
-- brew install fsouza/prettierd/prettierd

return {
  'stevearc/conform.nvim',
  lazy = true,
  event = { 'BufReadPre', 'BufNewFile' }, -- to disable, comment this out
  keys = {
    { -- Customize or remove this keymap to your liking
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_fallback = true }
      end,
      mode = '',
      desc = 'Format buffer',
    },
  },
  config = function()
    require('conform').setup {
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'prettierd' },
        typescript = { 'prettierd' },
        javascriptreact = { 'prettierd' },
        typescriptreact = { 'prettierd' },
        css = { 'prettierd' },
        html = { 'prettierd' },
        json = { 'prettierd' },
        yaml = { 'prettierd' },
        markdown = { 'prettierd' },
        graphql = { 'prettierd' },
        -- python = { "isort", "black" },
        python = function(bufnr)
          if
            require('conform').get_formatter_info('ruff_format', bufnr).available
          then
            return { 'ruff_format' }
          else
            return { 'isort', 'black' }
          end
        end,
      },
      format_on_save = {
        timeout_ms = 500,
        async = false,
        lsp_fallback = true,
      },
    }
  end,
}
