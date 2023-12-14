-- echasnovski/mini.indentscope 是一个缩进竖线的指示器，非常好看
-- https://github.com/mg979/vim-visual-multi
-- sainnhe/everforest是一个主题
-- f-person/git-blame.nvim git仓库修改记录
-- windwp/nvim-autopairs 自动补全括号引号等
return {
  {
    'echasnovski/mini.indentscope',
    opts = {},
  },
  'mg979/vim-visual-multi',
  'f-person/git-blame.nvim',
  'github/copilot.vim',
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },
  {
    'sainnhe/everforest',
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.everforest_diagnostic_line_highlight = 1
      vim.cmd [[colorscheme everforest]]
    end,
  },
}
