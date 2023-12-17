return {
    'neovim/nvim-lspconfig',
    dependencies = {
        'rcarriga/nvim-notify', -- 一个花哨的、可配置的、用于 NeoVim 的通知管理器
    },
    config = function()
        -- 调用lspconfig模块进行设置
        local lspconfig = require 'lspconfig'
        local utils = require 'utils'
        local notify = require 'notify'
        -- 我们将使用 nvim-cmp 来处理自动完成。
        -- 因此，我们必须修改在我们使用的每个语言服务器中调用 capabilities 的选项。
        -- 此选项告诉语言服务器 Neovim 支持的功能
        -- 调用模块 cmp_nvim_lsp 并获取默认功能
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities =
            require('cmp_nvim_lsp').default_capabilities(capabilities)

        -- Define `root_dir` when needed
        -- See: https://github.com/neovim/nvim-lspconfig/issues/320
        -- This is a workaround, maybe not work with some servers.
        local root_dir = function()
            notify('root_dir @ ' .. vim.fn.getcwd())
            return vim.fn.getcwd()
        end

        local on_attach = function(client, bufnr)
            notify 'lsp server on attach'
            local bufopts = { noremap = true, silent = true, buffer = bufnr }
        end
        -- lua
        lspconfig['lua_ls'].setup {
            on_attach = on_attach,
            --  Your workspace is set to `/Users/zhaohuanan`. Lua language server refused to load this directory
            -- https://github.com/folke/neodev.nvim/issues/50
            capabilities = capabilities,
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { 'vim' },
                    },
                },
            },
        }
        lspconfig['taplo'].setup { -- for toml file
            on_attach = on_attach,
            capabilities = capabilities,
        }

        lspconfig['pyright'].setup {
            capabilities = capabilities,
            filetypes = { 'python' },
            on_attach = function(client) -- https://github.com/microsoft/pyright/blob/main/docs/settings.md
                notify('interpreter @ ' .. utils.exepath 'python')
                -- client.server_capabilities.disableLanguageServices = false
                -- client.server_capabilities.disableOrganizeImports = true
            end,
            settings = {
                pyright = {
                    disableLanguageServices = false,
                    disableOrganizeImports = true,
                },
                python = {
                    {
                        autoImportCompletions = true, -- Determines whether pyright offers auto-import completions.i
                        autoSearchPaths = true, -- Determines whether pyright automatically adds common search paths like "src" if there are no execution environments defined in the config file
                        -- extraPaths = none, -- Paths to add to the default execution environment extra paths if there are no execution environments defined in the config file.
                        typeCheckingMode = 'basic', -- “off”， “basic”， “standard”， “strict” 确定 pyright 使用的默认类型检查级别
                        useLibraryCodeForTypes = true, -- Determines whether pyright reads, parses and analyzes library code to extract type information in the absence of type stub files. Type information will typically be incomplete. We recommend using type stubs where possible. The default value for this option is true.
                    },
                    pythonPath = utils.exepath 'python',
                },
            },
        }
        lspconfig['ruff_lsp'].setup {
            capabilities = capabilities,
            root_dir = root_dir,
            on_attach = function(client)
                -- Disable hover in favor of Pyright
                client.server_capabilities.hoverProvider = false
            end,
            settings = {
                organizeImports = true,
            },
        }
    end,
}
