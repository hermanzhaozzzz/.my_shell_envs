-- 获取Vim的'data'目录的路径，并将其与'/lazy/lazy.nvim'这个相对路径连接起来，然后将结果存储在lazypath变量
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
-- vim.notify('lazypath @ ' .. lazypath)

if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    }
end
-- 设置 Vim 的运行时路径 (runtime path)
-- 这个路径是 Vim 搜索插件、颜色方案、语法文件等的目录
vim.opt.rtp:prepend(lazypath)

require 'base'
require 'utils'
require('lazy').setup 'plugins'
require 'keymap'
