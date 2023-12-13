local builtin = require('telescope.builtin')

-- 环境里要安装ripgrep!
-- ff: search file
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
-- fc: search code
vim.keymap.set('n', '<leader>fc', builtin.live_grep, {})  -- 环境里要安装ripgrep
-- fb: search buffer
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
-- fh: search help
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})