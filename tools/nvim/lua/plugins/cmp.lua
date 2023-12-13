-- Before we start, nvim-cmp's documentation says we should set completeopt with the following values
vim.opt.completeopt = {'menu', 'menuone', 'noselect'}

-- To configure nvim-cmp we will use two modules cmp and luasnip.
local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
    return
end

local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
    return
end

-- 配置代码片段引擎(snippets engine)
-- 这一部分与language servers和LSP等无关
-- 加载已经安装的代码片段(snippets)
require("luasnip.loaders.from_vscode").lazy_load()

-- cmp.setup用到的临时函数和临时变量
local check_backspace = function()
    local col = vim.fn.col "." - 1
    return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
end

local select_opts = { behavior = cmp.SelectBehavior.Select }
-- /临时函数和临时变量


-- 开始进行cmp配置
cmp.setup({
    snippet = {
        expand = function(args)
            -- Callback function, it receives data from a snippet.
            -- This is where nvim-cmp expect us to provide a thing that 
            -- can expand snippets, and we do that with `luasnip.lsp_expand`
            -- require('luasnip').lsp_expand(args.body)
            luasnip.lsp_expand(args.body)
        end,
    },
    window = {
        -- Controls the appearance and settings for the documentation window.
        -- To configure this quickly nvim-cmp offers a preset 
        -- we can use to add some borders.
        documentation = cmp.config.window.bordered()
    },
    formatting = {  -- List of strings that determines the order of the elements in an item.
        fields = {'menu', 'abbr', 'kind'},
        -- abbr is the content of the suggestion.
        -- kind is the type of data, this can be text, class, function, etc.
        -- menu is empty by default.
        format = function (entry, item)
            local menu_icon = {
                nvim_lsp = '𝕃𝕤𝕡',
                luasnip = '❪❫',
                buffer = '♽',
                path = '☡',
            }
            item.menu = menu_icon[entry.source.name]
            return item
        end,
    },
    mapping = cmp.mapping.preset.insert({  -- 按键的映射！！！
        -- 在建议的补全之间移动的快捷键设定
        -- ↑
        ['<Up>'] = cmp.mapping.select_prev_item(select_opts),
        -- ↓
        ['<Down>'] = cmp.mapping.select_next_item(select_opts),
        -- 在弹出的文档帮助中上下文滚动
        ['<C-n>'] = cmp.mapping.scroll_docs(-4),
        ['<C-p>'] = cmp.mapping.scroll_docs(4),
        -- ['<C-e>'] = cmp.mapping.abort(),  -- 取消补全，esc也可以退出, 这个和移动到行尾撞车，后期再优化
        -- <CR>是回车的意思, select=true则确定选择
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        -- 跳转到补全条目的下一个
        ["<Tab>"] = cmp.mapping(
            function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif luasnip.expandable() then
                    luasnip.expand()
                elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                elseif check_backspace() then
                    fallback()
                else
                    fallback()
                end
            end, {
                "i",
                "s",
            }
        ),
        -- shift + tab跳转到上一个
        ["<S-Tab>"] = cmp.mapping(
            function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end, {
                "i",
                "s",
            }
        ),
    }),

    -- 在这里罗列 nvim-cmp 将用于自动补全时的所有数据源
    -- name: 每个source的name属性必须是该source创建源代码时插件使用的id，而非其插件名, id一般可在插件文档中找到
    -- priority: 定义了该source在补全中的优先级, 如果不设置, 则source的顺序将决定优先级
    -- keyword_length: 定义了触发查询此source所需要的代码字符个数
    --
    -- 如果需要添加更多自动补全插件，就在这里添加
    sources = cmp.config.sources(
        {
            -- 自动完成文件路径
            { name = "path", priority = 1, keyword_length = 1 },
            -- 根据语言服务器的响应显示建议
            { name = "nvim_lsp", priority = 2, keyword_length = 1 },
            -- 在当前缓冲区中找到的词条建议
            { name = "buffer", priority = 3, keyword_length = 3 },
            -- 显示可用的snippets代码段建议, 如果选用他们，则展开他们
            { name = "luasnip", priority = 4, keyword_length = 2 },
        }
    )
})

