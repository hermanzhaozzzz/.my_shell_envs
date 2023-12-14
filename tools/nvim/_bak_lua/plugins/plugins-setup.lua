local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

-- 保存此文件自动更新安装软件
-- 注意PackerCompile改成了PackerSync
-- plugins.lua改成了plugins-setup.lua，适应本地文件名
vim.cmd([[
    augroup packer_user_config
        autocmd!
        autocmd BufWritePost plugins-setup.lua source <afile> | PackerSync
    augroup end
]])

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use 'folke/tokyonight.nvim' -- 主题
    use {
        'nvim-lualine/lualine.nvim', -- 状态栏
        requires = { -- 状态栏图标
            'kyazdani42/nvim-web-devicons',
            opt = true
        }
    }
    use {
        'nvim-tree/nvim-tree.lua',  -- 文档树
        requires = {
            'nvim-tree/nvim-web-devicons', -- 文档数图标
        }
    }
    use 'christoomey/vim-tmux-navigator' -- 用ctrl-hjkl来定位窗口
    use 'nvim-treesitter/nvim-treesitter' -- 语法高亮
    use 'p00f/nvim-ts-rainbow' -- 配合treesitter， 不同括号颜色区分
    use { -- 配置LSP
        'williamboman/mason.nvim',  -- 使用mason统一管理lsp服务
        'williamboman/mason-lspconfig.nvim',  -- 这个相当于mason.nvim和lspconfig的桥梁
        'neovim/nvim-lspconfig'  -- 配置lsp服务器
    }
    use { -- 配置自动补全!!!!!!!!!!!!!重要的部分
        'hrsh7th/nvim-cmp',
        'hrsh7th/cmp-nvim-lsp',
        'L3MON4D3/LuaSnip', -- snippets引擎，不装这个自动补全会出问题
        'saadparwaiz1/cmp_luasnip',
        -- 'rafamadriz/friendly-snippets',
        'hrsh7th/cmp-path',  -- 文件路径
    }
    use {
        'numToStr/Comment.nvim', -- gcc和gc注释
        'windwp/nvim-autopairs', -- 自动补全括号
    }
    use "akinsho/bufferline.nvim" -- buffer分割线
    use "lewis6991/gitsigns.nvim" -- 左则git提示
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.5',  -- 文件检索
        requires = {
            {'nvim-lua/plenary.nvim'}
        }
    }
    use 'rcarriga/nvim-notify'  -- 一个花哨的、可配置的、用于 NeoVim 的通知管理器

    if packer_bootstrap then
        require('packer').sync()
    end
end)
