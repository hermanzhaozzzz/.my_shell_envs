-- 查找文件和代码 (依赖插件：telescope.builtin, 进入telescope页面会是插入模式，回到正常模式就可以用j和k来移动了)
-- 环境里要安装ripgrep!  brew install ripgrep
return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.5',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local builtin = require 'telescope.builtin'
    local keymap = vim.keymap
    -- ff: search file
    keymap.set('n', '<leader>ff', builtin.find_files, {})
    -- fc: search code
    keymap.set('n', '<leader>fc', builtin.live_grep, {})  -- 环境里要安装ripgrep
    -- fb: search buffer
    keymap.set('n', '<leader>fb', builtin.buffers, {})
    -- fh: search help
    keymap.set('n', '<leader>fh', builtin.help_tags, {})
    
    local actions = require 'telescope.actions'
    require('telescope').setup {
      defaults = {
        mappings = {
          i = {
            ['esc'] = actions.close,
          },
        },
        file_ignore_patterns = {
          'codegen.ts',
          '.git',
          'lazy-lock.json',
          'node_modules',
          '%.lock',
          'schema.gql',
        },
        dynamic_preview_title = true,
        path_display = { 'smart' },
      },
      pickers = {
        find_files = {
          hidden = true,
        },
      },
      layout_config = {
        horizontal = {
          preview_cutoff = 100,
          preview_width = 0.5,
        },
      },
    }
  end,
}
