return {
    {
        'nvim-tree/nvim-tree.lua',
        dependencies = {
            'nvim-tree/nvim-web-devicons',
            'christoomey/vim-tmux-navigator',
        },
        config = function()
            -- 默认不开启nvim-tree
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1
            -- vim.g.netrw_browse_split = 3
            -- vim.g.netrw_liststyle = 3
            -- vim.g.netrw_banner = 0

            local api = require 'nvim-tree.api'
            local function my_on_attach(bufnr)
                local function opts(desc)
                    return {
                        desc = 'nvim-tree: ' .. desc,
                        buffer = bufnr,
                        noremap = true,
                        silent = true,
                        nowait = true,
                    }
                end

                -- default mappings
                api.config.mappings.default_on_attach(bufnr)
                -- 在目录模式下按shift + ?调出帮助
                vim.keymap.set('n', '?', api.tree.toggle_help, opts 'Help')
            end

            require('nvim-tree').setup {
                view = {
                    width = 35,
                },
                on_attach = my_on_attach,
                filters = {
                    custom = { '^.git$' },
                },
                actions = {
                    open_file = { quit_on_open = true },
                },
                update_focused_file = {
                    enable = true,
                    update_cwd = true,
                },
                git = {
                    enable = true,
                },
                diagnostics = {
                    enable = true,
                    show_on_dirs = true,
                    icons = {
                        hint = '',
                        info = '',
                        warning = '',
                        error = '',
                    },
                },
            }
        end,
    },
}
