-- nvim-treesitter/nvim-treesitter
-- 突出显示代码
return {
  {
    'nvim-treesitter/nvim-treesitter', -- 语法高亮
    event = { 'BufReadPre', 'BufNewFile' },
    build = ':TSUpdate',
    dependencies = {
      'windwp/nvim-ts-autotag',
      'axelvc/template-string.nvim',
      'p00f/nvim-ts-rainbow', -- 配合treesitter， 不同括号颜色区分
    },
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          'bash',
          'c',
          'cpp',
          'lua',
          'vim',
          'javascript',
          'html',
          'css',
          'json',
          'regex',
          'rust',
          'markdown',
          'markdown_inline',
          'python',
          'r',
        },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        autotag = {
          enable = true,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<enter>',
            node_incremental = '<enter>',
            scope_incremental = false,
            node_decremental = '<bs>',
          },
        },
        indent = {
          enable = true
        },
        rainbow = {
          enable = true,
          extended_mode = true,
          max_file_lines = nil,
        },
      }

      require('template-string').setup {}

      -- fold
      local opt = vim.opt
      opt.foldmethod = 'expr'
      opt.foldexpr = 'nvim_treesitter#foldexpr()'
      opt.foldenable = false
    end,
  },
}
