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
    ensure_installed = {
        "lua_ls",                          -- lua
        "awk_ls",                          -- awk
        "bashls",                          -- bash
        "dockerls",                        -- docker
        "docker_compose_language_service", -- docker compose
        "rust_analyzer",                   -- rust
        "marksman",                        -- markdown
        "html",                            -- html
        "jsonls",                          -- json
        "yamlls",                          -- yaml
        "r_language_server",               -- R
        "pylsp"                            -- for python, the best choice, dont use jedi, pyright!
        -- https://github.com/williamboman/mason-lspconfig.nvim/blob/main/lua/mason-lspconfig/server_configurations/pylsp/README.markdown
        -- :PylspInstall pyls-flake8 pylsp-mypy pyls-isort
    },
})

-- 我们将使用 nvim-cmp 来处理自动完成。
-- 因此，我们必须修改在我们使用的每个语言服务器中调用 capabilities 的选项。
-- 此选项告诉语言服务器 Neovim 支持的功能

-- 调用模块 cmp_nvim_lsp 并获取默认功能

local capabilities = require("cmp_nvim_lsp").default_capabilities()

require("lspconfig").lua_ls.setup {
    capabilities = capabilities,
}

-- 为了利用一些“LSP 功能”，我们需要创建一些键绑定。
-- 每当语言服务器附加到缓冲区时，Neovim 都会发出该事件 LspAttach ，这将使我们有机会创建键绑定
-- 此自动命令可以存在于我们配置中的任何位置
-- https://vonheikemen.github.io/devlog/tools/setup-nvim-lspconfig-plus-nvim-cmp/
vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function()
        local bufmap = function(mode, lhs, rhs)
            local opts = { buffer = true }
            vim.keymap.set(mode, lhs, rhs, opts)
        end
        -- Displays hover information about the symbol under the cursor
        -- 显示光标下符号的悬停信息
        bufmap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')

        -- Jump to the definition
        -- 跳转到定义
        bufmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')

        -- Jump to declaration
        -- 跳转到声明
        bufmap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')

        -- Lists all the implementations for the symbol under the cursor
        -- 列出光标下的符号的所有实现
        bufmap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')

        -- Jumps to the definition of the type symbol
        -- 跳转到类型符号的定义
        bufmap('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>')

        -- Lists all the references
        -- 列出所有引用项
        bufmap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')

        -- Displays a function's signature information
        -- 显示函数的签名信息
        bufmap('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>')

        -- Renames all references to the symbol under the cursor
        -- 重命名光标下对符号的所有引用
        bufmap('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>')

        -- Selects a code action available at the current cursor position
        -- 选择当前光标位置上可用的代码操作
        bufmap('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>')

        -- Show diagnostics in a floating window
        -- 在浮动窗口中显示诊断
        bufmap('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')

        -- Move to the previous diagnostic
        bufmap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')

        -- Move to the next diagnostic
        bufmap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')
    end
})

-- selfuse cmd for mason
-- custom cmd to install all mason binaries listed
-- 要设置在最后！
vim.api.nvim_create_user_command("MasonInstallAll", function()
        vim.cmd("MasonInstall " .. table.concat(opts.ensure_installed, " "))
    end,
    {}
)
