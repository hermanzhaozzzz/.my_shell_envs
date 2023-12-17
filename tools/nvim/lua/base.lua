local opt = vim.opt
vim.g.mapleader = ' ' -- 设置导航键为空格
-- ----------显示设置---------- --
opt.termguicolors = true -- 开启终端色彩功能
vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1 -- 开启neovim终端彩色功能
opt.signcolumn = 'yes' -- 显示左侧图标指示列

opt.colorcolumn = '120' -- 右侧参考线，超过表示代码太长了，考虑换行
opt.wrap = false -- 禁止折行 使长行的文本始终可见。 长线是那些超过屏幕宽度的线。 默认值是true

opt.cursorline = true -- 高亮所在行
opt.number = true -- 显示行号
opt.relativenumber = true -- 显示相对行号

opt.scrolloff = 5 -- 移动时光标周围保留5行
opt.sidescrolloff = 5 -- 移动时光标周围保留5行

opt.showtabline = 3 -- 显示tab行（顶部）,0不显示
opt.laststatus = 3 -- 显示底部smartline, 0不显示

opt.list = true
opt.listchars = 'tab:»·,nbsp:+,trail:·,extends:→,precedes:←' -- 显示多余字符

opt.cmdheight = 1 -- 命令输入行的行高，一行行高

opt.updatetime = 1000 -- 鼠标停留多久相应动作，ms

-- ----------搜索相关---------- --
opt.hlsearch = true -- 搜索高亮, <leader>nh关闭高亮
opt.incsearch = true -- 边输入边搜索
opt.ignorecase = true -- 搜索大小写不敏感，除非包含大写
opt.smartcase = true -- 搜索大小写不敏感，除非包含大写

-- ----------排版相关---------- --
opt.tabstop = 4 -- 缩进时Tab在屏幕上可以占据的空间，四个字符长度
opt.expandtab = true -- 配合tabstop，使用四个空格替代tab
opt.softtabstop = 4 -- 这个选项用于设置软制表符的停止位置。软制表符是 Vim 中一种特殊的缩进方式，它允许你在一个制表位的位置上插入多个空格。softtabstop 选项允许你指定一个数字，这个数字表示在按下 Tab 键时，Vim 会插入多少个空格。例如，如果 softtabstop 设置为 2，那么在按下 Tab 键时，Vim 会插入两个空格。
opt.shiftwidth = 4 -- Neovim 用于缩进一行的字符数。 此选项会影响键绑定 << 和 >>。 默认值为 8。大多数时候我们希望将其设置为与 tabstop 相同的值
opt.shiftround = true -- 这个选项用于控制 Vim 在进行缩进操作时是否自动调整行之间的对齐。当 shiftround 设置为 true 时，Vim 会尽量保持行之间的对齐，即使这需要增加或减少一些空格。例如，如果一行代码的缩进是 2 个空格，而另一行的代码需要缩进 4 个空格，当 shiftround 设置为 true 时，Vim 会自动调整第二行的缩进为 4 个空格，以保持行之间的对齐

opt.autoindent = true -- 新行对齐当前行
opt.breakindent = true -- 保留虚拟行的缩进。 这些“虚拟线”只有在启用换行时才可见

-- ----------系统设置---------- --
opt.autochdir = true -- 自动切换工作目录

opt.mouse:append 'a' -- 启用鼠标
opt.clipboard:append 'unnamedplus' -- 配置剪贴板

opt.splitright = true --  默认水平方向在右侧打开窗口而不是左侧
opt.splitbelow = true --  默认垂直方向在下方打开窗口而不是上方

opt.autoread = true -- 当文件被外部程序修改时，自动加载
vim.bo.autoread = true -- 当文件被外部程序修改时，自动加载

opt.backup = false -- 禁止创建备份文件
opt.writebackup = false -- 禁止创建备份文件
opt.swapfile = false -- 禁止创建备份文件

opt.ttimeoutlen = 0 -- 快捷键超时时间 ms，如<leader>c, <leader>cc中间的等待时间
opt.timeout = true

-- opt.virtualedit = 'block'  -- 虚拟文本？
opt.conceallevel = 0 -- markdown显示渲染后还是直接显示符号

opt.undofile = true -- 重要，撤销永久化，退出文件再进入，仍能继续undo

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile', 'FileType' }, {
    -- 对于以下指定的文件，缩进变为2空格
    pattern = { 'lua' },
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
        vim.opt_local.softtabstop = 2
    end,
})
vim.api.nvim_create_autocmd(
    -- 打开terminal会自动insert模式
    'TermOpen',
    { pattern = 'term://*', command = [[startinsert]] }
)
vim.api.nvim_create_autocmd(
    -- 打开markdown或者纯文本时超出屏幕长度自动换行（上文设置了代码中超出屏幕长度不换行）
    { 'BufRead', 'BufNewFile' },
    { pattern = '*.md, *.txt', command = 'setlocal wrap' }
)
vim.api.nvim_create_autocmd('BufReadPost', {
    -- 打开文件时将光标定位在上次退出时的位置
    pattern = '*',
    callback = function()
        local line = vim.fn.line
        if line '\'"' > 1 and line '\'"' <= line '$' then
            vim.cmd 'normal! g\'"'
        end
    end,
})
vim.api.nvim_create_autocmd('TextYankPost', {
    -- 复制选中内容的时候高亮闪烁一下，用来提示文本已复制
    callback = function()
        vim.highlight.on_yank { higroup = 'Visual', timeout = 200 }
    end,
})
