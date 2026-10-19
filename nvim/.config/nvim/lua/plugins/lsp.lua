-- Language-server tweaks layered over the lang.* extras in lazyvim.json. Each table here is
-- deep-merged into the extra's own settings, so only the differences are listed.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              analyses = { shadow = true },
            },
          },
        },
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = { typeCheckingMode = "basic" },
            },
          },
        },
        -- Servers the old config had that no enabled extra brings along.
        bashls = {},
        html = {},
        cssls = {},
        lemminx = {},
      },
    },
  },

  {
    "mrcjkb/rustaceanvim",
    opts = {
      server = {
        default_settings = {
          ["rust-analyzer"] = {
            check = { command = "clippy" },
          },
        },
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      -- lang.clangd only adds cpp; plain C headers and sources want their own parser.
      ensure_installed = { "c", "graphql", "proto", "scss" },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = { "shellcheck", "shfmt" },
    },
  },
}
