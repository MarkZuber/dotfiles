-- Loaded before lazy.nvim starts, on top of LazyVim's defaults:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- Python: basedpyright for types, ruff for lint + format (lang.python extra reads these).
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff"

local opt = vim.opt

opt.tabstop = 2
opt.shiftwidth = 2
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.timeoutlen = 300
opt.swapfile = false
opt.iskeyword:append("-")

-- Trailing whitespace is trimmed by .editorconfig (trim_trailing_whitespace), which Neovim
-- applies natively, so there is deliberately no global trim-on-save autocmd.

vim.filetype.add({
  pattern = {
    [".*%.env"] = "sh",
    [".*%.env%..*"] = "sh",
    ["Dockerfile.*"] = "dockerfile",
    [".*%.dockerfile"] = "dockerfile",
  },
})
