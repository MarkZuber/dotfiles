-- Plugins from the old hand-written config that LazyVim has no equivalent for.
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = { flavour = "mocha" },
  },

  -- ys / ds / cs surround. LazyVim's mini-surround extra is left off so these keys stay.
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },

  -- jk / jj leave insert mode.
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    opts = {},
  },

  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    -- <leader>gv, not the old <leader>gd: LazyVim puts its git-diff picker there.
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diffview open" },
      { "<leader>gV", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview file history" },
    },
  },

  -- Plain-English TypeScript errors in diagnostics.
  {
    "dmmulroy/ts-error-translator.nvim",
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    opts = {},
  },

  { "mtdl9/vim-log-highlighting", ft = "log" },
  { "chrisbra/csv.vim", ft = "csv" },

  {
    "catgoose/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },
}
