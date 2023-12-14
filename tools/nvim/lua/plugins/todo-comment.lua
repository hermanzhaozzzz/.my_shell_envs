-- https://github.com/folke/todo-comments.nvim
-- todo-comments 是 Neovim >= 0.8.0 的 lua 插件，用于 BUG 在代码库中突出显示和搜索 todo 注释，如 ， 。 TODO HACK
return {
  'folke/todo-comments.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    vim.keymap.set('n', ']t', function()
      require('todo-comments').jump_next()
    end, { desc = 'Next todo comment' })

    vim.keymap.set('n', '[t', function()
      require('todo-comments').jump_prev()
    end, { desc = 'Previous todo comment' })

    vim.keymap.set(
      'n',
      '<leader>td',
      '<cmd>TodoTelescope<cr>',
      { desc = 'Previous todo comment' }
    )

    require('todo-comments').setup()
  end,
}
