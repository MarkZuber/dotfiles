-- Loaded on VeryLazy, on top of LazyVim's keymaps:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Only habits from the old hand-written config that LazyVim doesn't already cover live here.

local map = vim.keymap.set

-- Old LSP muscle memory, alongside LazyVim's <leader>cr / <leader>cf.
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename (LSP)" })
map({ "n", "v" }, "<leader>lf", function()
  LazyVim.format({ force = true })
end, { desc = "Format" })

-- Keep the cursor centred on half-page jumps and search hits.
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Paste over a selection without losing what was yanked.
map("x", "<leader>p", [["_dP]], { desc = "Paste without yank" })
