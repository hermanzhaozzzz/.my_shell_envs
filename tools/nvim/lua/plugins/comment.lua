-- https://github.com/numToStr/Comment.nvim
-- 注释用的插件
-- 会用gcc就行，别的不重要
-- NORMAL mode
-- `gcc` - 行注释  eg.    -- local path = "test"
-- `gbc` - 块注释  eg.    --[[ local path = "test" ]]
-- `[count]gcc` - 使用linewise切换作为前缀计数给定的行数
-- `[count]gbc` - 使用块切换作为前缀计数给定的行数
-- `gc[count]{motion}` - (Op-pending)使用线性注释切换区域
-- `gb[count]{motion}` - (Op-pending)使用块注释切换区域
-- VISUAL mode
-- `gc` - 使用线性注释切换区域
-- `gb` - 使用块注释切换区域
return {
  'numToStr/Comment.nvim',
  dependencies = {
    'JoosepAlviste/nvim-ts-context-commentstring',
  },
  config = function()
    require('ts_context_commentstring').setup {
      enable_autocmd = false,
    }
    require('Comment').setup {
      pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
    }
  end,
}
