-- https://github.com/coffebar/neovim-project
-- Neovim 项目插件通过维护项目历史记录并
-- 通过 Telescope 提供对已保存会话的快速访问来简化项目管理。
-- 它运行在 Neovim 会话管理器之上，需要它来存储每个项目的所有打开的选项卡和缓冲区。
return {
  'coffebar/neovim-project',
  opts = {
    projects = { -- define project roots
      '~/workspace/*',
      '~/.config/*',
    },
  },
  init = function()
    -- enable saving the state of plugins in the session
    vim.opt.sessionoptions:append 'globals' -- save global variables that start with an uppercase letter and contain at least one lowercase letter.
  end,
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
    { 'Shatur/neovim-session-manager' },
  },
  lazy = false,
  priority = 100,
}
