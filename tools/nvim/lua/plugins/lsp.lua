-- lsp servers to install
local table_ensure_list = {
        "lua_ls",                          -- lua
        "awk_ls",                          -- awk
        "bashls",                          -- bash
        "dockerls",                        -- docker
        "docker_compose_language_service", -- docker compose
        "rust_analyzer",                   -- rust
        "marksman",                        -- markdown
        "html",                            -- html
        -- "jsonls",                          -- json
        -- "yamlls",                          -- yaml
        -- "r_language_server",            -- R, 安装非常耗时，如无必要不安装
        "pyright"                          -- Python
}



local utils = require("core.utils")
-- :h mason-default-settings
require('mason').setup({
    ui = {
        icons = {
            package_installed = "✔︎",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})

-- mason-lspconfig uses the `lspconfig` server names in the APIs it exposes - not `mason.nvim` package names
require("mason-lspconfig").setup({
    -- 确保安装，根据需要填写
    -- https://github.com/williamboman/mason-lspconfig.nvim
    ensure_installed = table_ensure_list,
})

-- 我们将使用 nvim-cmp 来处理自动完成。
-- 因此，我们必须修改在我们使用的每个语言服务器中调用 capabilities 的选项。
-- 此选项告诉语言服务器 Neovim 支持的功能

-- 调用模块 cmp_nvim_lsp 并获取默认功能
local capabilities = require("cmp_nvim_lsp").default_capabilities()
-- 调用lspconfig模块进行设置
local lspconfig = require("lspconfig")

lspconfig.lua_ls.setup({
    capabilities = capabilities,
})
if utils.executable('pyright') then
    lspconfig.pyright.setup({
        single_file_support = true,
        filetypes = { "python" },
        -- on_attach = function(client, bufnr) -- https://github.com/microsoft/pyright/blob/main/docs/settings.md
        --     client.server_capabilities.disableLanguageServices = false
        --     client.server_capabilities.disableOrganizeImports = false
        -- end,
        -- capabilities = capabilities,
        settings = {
            pyright = {
                disableLanguageServices = false,
                disableOrganizeImports = false,
            },
            python = {
                analysis = {
                    autoImportCompletions = true,  -- Determines whether pyright offers auto-import completions.
                    autoSearchPaths = true,        -- Determines whether pyright automatically adds common search paths like "src" if there are no execution environments defined in the config file
                    diagnosticMode = "workspace",  -- openFilesOnly, workspace:  Determines whether pyright analyzes (and reports errors for) all files in the workspace, as indicated by the config file. If this option is set to "openFilesOnly", pyright analyzes only open files
                    extraPaths = none,             -- Paths to add to the default execution environment extra paths if there are no execution environments defined in the config file.
                    typeCheckingMode = "basic",    -- “off”， “basic”， “standard”， “strict” 确定 pyright 使用的默认类型检查级别
                    useLibraryCodeForTypes = true, -- Determines whether pyright reads, parses and analyzes library code to extract type information in the absence of type stub files. Type information will typically be incomplete. We recommend using type stubs where possible. The default value for this option is true.
                },
                -- pythonPath = utils.exepath("python")
            }
        }
    })
    -- vim.notify(utils.exepath("python"), vim.log.levels.INFO, { title = 'lsp-info' })
else
    vim.notify("pyright not found!", vim.log.levels.WARN, { title = 'lsp-info' })
end

