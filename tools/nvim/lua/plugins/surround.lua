-- https://github.com/kylechui/nvim-surround
-- 非常易用的选中代码边缘 的小工具，值得学习
return {
  {
    'kylechui/nvim-surround',
    version = '*', -- Use for stability; omit to use `main` branch for the latest features
    event = 'VeryLazy',
    config = function()
      require('nvim-surround').setup {}
    end,
  },
}
