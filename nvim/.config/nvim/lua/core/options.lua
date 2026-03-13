local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- Line wrapping
opt.wrap = false

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Cursor
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Appearance
opt.termguicolors = true
opt.signcolumn = "yes"
opt.colorcolumn = ""
opt.showmode = false
opt.cmdheight = 1
opt.pumheight = 10

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Clipboard
opt.clipboard = "unnamedplus"

-- Undo
opt.undofile = true
opt.undolevels = 10000

-- Files
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.updatetime = 200

-- Completion
opt.completeopt = "menu,menuone,noselect"
opt.shortmess:append("c")

-- Folding (using Neovim's built-in treesitter expression)
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldenable = false
opt.foldlevel = 99

-- Misc
opt.mouse = "a"
opt.timeoutlen = 300
opt.ttimeoutlen = 0
opt.hidden = true
opt.fileencoding = "utf-8"
opt.iskeyword:append("-")
opt.formatoptions:remove({ "c", "r", "o" })
opt.conceallevel = 0
opt.spell = false

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
