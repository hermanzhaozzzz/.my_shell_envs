-- https://github.com/MattesGroeger/vim-bookmarks
-- 太复杂，暂时不用
-- 这个 vim 插件允许切换每行的书签。快速修复窗口提供对所有书签的访问。也可以添加注释。这些是附有注释的特殊书签。它们对于准备代码审查很有用。所有书签将在下次启动时恢复。
return {
  -- 'MattesGroeger/vim-bookmarks',
  -- dependencies = {
  --   'tom-anders/telescope-vim-bookmarks.nvim',
  -- },

  -- config = function()
  --   vim.cmd [[highlight BookmarkSign ctermbg=NONE ctermfg=160]]
  --   vim.cmd [[highlight BookmarkLine ctermbg=194 ctermfg=NONE]]

  --   vim.g.bookmark_sign = '♥'
  --   vim.g.bookmark_highlight_lines = 1

  --   require('telescope').load_extension 'vim_bookmarks'

  --   local keymap = vim.keymap

  --   keymap.set(
  --     'n',
  --     'ma',
  --     '<cmd>lua require("telescope").extensions.vim_bookmarks.all()<cr>'
  --   )
  --   keymap.set(
  --     'n',
  --     'mc',
  --     '<cmd>lua require("telescope").extensions.vim_bookmarks.current_file()<cr>'
  --   )
  -- end,
}
