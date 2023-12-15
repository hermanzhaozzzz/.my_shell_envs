local opt = vim.opt
-- ----------显示设置---------- --
opt.termguicolors = true -- 开启终端色彩功能

opt.signcolumn = 'yes' -- 显示左侧图标指示列

opt.colorcolumn = '120' -- 右侧参考线，超过表示代码太长了，考虑换行
opt.wrap = false -- 禁止折行 使长行的文本始终可见。 长线是那些超过屏幕宽度的线。 默认值是true

opt.cursorline = true -- 高亮所在行
opt.number = true -- 显示行号
opt.relativenumber = true -- 显示相对行号

opt.scrolloff = 5 -- 移动时光标周围保留5行
opt.sidescrolloff = 5 -- 移动时光标周围保留5行
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
opt.splitbelow = true -- 默认新建窗口位置（下）
opt.splitright = true -- 默认新建窗口位置（右）

opt.mouse:append 'a' -- 启用鼠标
opt.clipboard:append 'unnamedplus' -- 配置剪贴板

opt.autoread = true -- 当文件被外部程序修改时，自动加载
vim.bo.autoread = true -- 当文件被外部程序修改时，自动加载

opt.backup = false -- 禁止创建备份文件
opt.writebackup = false -- 禁止创建备份文件
opt.swapfile = false -- 禁止创建备份文件

-- ----------TODO不知道干嘛的---------- --
-- highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end,
})
