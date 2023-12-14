return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'hrsh7th/nvim-cmp', -- Autocompletion plugin
    'hrsh7th/cmp-nvim-lsp', -- LSP source for nvim-cmp
    'saadparwaiz1/cmp_luasnip', -- Snippets source for nvim-cmp
    'L3MON4D3/LuaSnip', -- snippets引擎，不装这个自动补全会出问题
    'rafamadriz/friendly-snippets',
    'hrsh7th/cmp-path', -- 文件路径
    'rcarriga/nvim-notify', -- 一个花哨的、可配置的、用于 NeoVim 的通知管理器
  },
  -- keys = {
  --     { "gd", vim.lsp.buf.definition, desc = "Goto Definition" },
  --     { "gr", vim.lsp.buf.references, desc = "Goto References" },
  --     { "<leader>c", vim.lsp.buf.code_action, desc = "Code Action" },
  -- },
  config = function()
    -- 我们将使用 nvim-cmp 来处理自动完成。
    -- 因此，我们必须修改在我们使用的每个语言服务器中调用 capabilities 的选项。
    -- 此选项告诉语言服务器 Neovim 支持的功能
    -- 调用模块 cmp_nvim_lsp 并获取默认功能
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    -- 调用lspconfig模块进行设置
    local lspconfig = require 'lspconfig'
    local utils = require 'utils'
    local notify = require 'notify'
    local opts = { noremap = true, silent = true }
    local bufopts = { noremap = true, silent = true, buffer = bufnr }

    -- lua
    lspconfig.lua_ls.setup {
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = {
            globals = { 'vim' },
          },
        },
      },
    }
    lspconfig.taplo.setup { -- for toml file
      capabilities = capabilities,
    }

    lspconfig.pyright.setup {
      capabilities = capabilities,
      -- single_file_support = true,
      filetypes = { 'python' },
      -- on_attach = function(client, bufnr) -- https://github.com/microsoft/pyright/blob/main/docs/settings.md
      -- notify('pythonPath' .. utils.exepath 'python')
      -- client.server_capabilities.disableLanguageServices = false
      -- client.server_capabilities.disableOrganizeImports = true
      -- end,
      settings = {
        pyright = {
          disableLanguageServices = false,
          disableOrganizeImports = true,
        },
        --     python = {
        --         analysis = {
        --             autoImportCompletions = true,  -- Determines whether pyright offers auto-import completions.
        --             autoSearchPaths = true,        -- Determines whether pyright automatically adds common search paths like "src" if there are no execution environments defined in the config file
        --             extraPaths = none,             -- Paths to add to the default execution environment extra paths if there are no execution environments defined in the config file.
        --             typeCheckingMode = "basic",    -- “off”， “basic”， “standard”， “strict” 确定 pyright 使用的默认类型检查级别
        --             useLibraryCodeForTypes = true, -- Determines whether pyright reads, parses and analyzes library code to extract type information in the absence of type stub files. Type information will typically be incomplete. We recommend using type stubs where possible. The default value for this option is true.
        --         },
        --         pythonPath = utils.exepath("python")
        --     }
      },
    }
    -- vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
    -- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    -- vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    -- vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)
    lspconfig.ruff_lsp.setup {
      capabilities = capabilities,
      -- on_attach = function(client, bufnr)
      -- Mappings.
      -- See `:help vim.lsp.*` for documentation on any of the below functions
      -- vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
      -- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
      -- vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
      -- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
      -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
      -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
      -- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
      -- vim.keymap.set('n', '<space>wl', function()
      --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      -- end, bufopts)
      -- vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
      -- vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
      -- vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
      -- vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
      -- vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
      -- end,
      on_attach = function(client, bufnr)
        -- Disable hover in favor of Pyright
        client.server_capabilities.hoverProvider = false
      end,
      settings = {
        organizeImports = true,
      },
    }
  end,
}
