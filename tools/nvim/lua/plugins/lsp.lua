require('mason').setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})

require("mason-lspconfig").setup({
    -- 确保安装，根据需要填写
    -- https://github.com/williamboman/mason-lspconfig.nvim
    ensure_installed = {
        "lua_ls",  -- lua
        "rust_analyzer",  -- rust
        "marksman", -- markdown
        "pyright", -- python, npm is needed
        "r_language_server",  -- R
    },
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

require("lspconfig").lua_ls.setup {
    capabilities = capabilities,
}

