-- https://github.com/williamboman/mason.nvim
-- https://github.com/williamboman/mason-lspconfig.nvim
-- 非常重要，几乎所有的自动补全、LSP、格式化依赖项都在这里安装！
return {
    'williamboman/mason.nvim',
    dependencies = {
        'williamboman/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    config = function()
        require('mason').setup {
            ui = {
                icons = {
                    package_installed = '✔︎',
                    package_pending = '➜',
                    package_uninstalled = '✗',
                },
            },
        }

        require('mason-lspconfig').setup {}
        require('mason-tool-installer').setup {
            ensure_installed = {
                'bash-language-server',
                'marksman',
                'html-lsp',
                'json-lsp',
                'yaml-language-server',
                'lua-language-server',
                'stylua',
                'eslint_d',
                'prettierd',
                'rust-analyzer',
                'pylint', -- linter for python
                'debugpy', -- debugger
                'black', -- formatter
                'isort', -- organize imports
                'ruff', -- linter for python (includes flake8, pep8, etc.)
                'ruff-lsp', -- LSP for python with pyright
                'pyright', -- LSP for python with ruff
                'taplo', -- LSP for toml (for pyproject.toml files)
            },
        }
    end,
}
