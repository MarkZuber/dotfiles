return {
  -- Mason: LSP/tool installer
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    opts = {
      ensure_installed = {
        -- LSP servers
        "typescript-language-server",
        "rust-analyzer",
        "omnisharp",
        "pyright",
        "lua-language-server",
        "taplo",          -- TOML
        "marksman",       -- Markdown
        "bash-language-server",
        "dockerfile-language-server",
        "gopls",
        "json-lsp",
        "ruby-lsp",
        "lemminx",        -- XML
        "yaml-language-server",
        "html-lsp",
        "css-lsp",
        -- Formatters
        "prettier",
        "stylua",
        "black",
        "gofumpt",
        "shfmt",
        -- Linters
        "shellcheck",
      },
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local ok, p = pcall(mr.get_package, tool)
          if ok and not p:is_installed() then
            p:install()
          end
        end
      end
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  },

  -- Mason LSPconfig bridge
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {},
  },

  -- nvim-lspconfig: provides server configs for Neovim 0.11+ via lsp/ directory
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "b0o/schemastore.nvim",
      {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
          library = {
            { path = "luvit-meta/library", words = { "vim%.uv" } },
          },
        },
      },
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Diagnostic config
      vim.diagnostic.config({
        virtual_text = { prefix = "●" },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "always",
        },
      })

      -- Signs
      local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      -- LSP keymaps via LspAttach autocmd (Neovim 0.11 recommended approach)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local bufnr = ev.buf
          local map = vim.keymap.set
          local bopts = { noremap = true, silent = true, buffer = bufnr }

          map("n", "gd", vim.lsp.buf.definition, bopts)
          map("n", "gD", vim.lsp.buf.declaration, bopts)
          map("n", "gr", vim.lsp.buf.references, bopts)
          map("n", "gi", vim.lsp.buf.implementation, bopts)
          map("n", "gt", vim.lsp.buf.type_definition, bopts)
          map("n", "K", vim.lsp.buf.hover, bopts)
          map("n", "<leader>ls", vim.lsp.buf.signature_help, bopts)
          map("n", "<leader>ca", vim.lsp.buf.code_action, bopts)
          map("n", "<leader>rn", vim.lsp.buf.rename, bopts)
          map("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, bopts)
          map("n", "<leader>li", "<cmd>LspInfo<cr>", bopts)
          map("n", "<leader>lR", "<cmd>LspRestart<cr>", bopts)
        end,
      })

      -- Apply capabilities to all servers
      vim.lsp.config("*", { capabilities = capabilities })

      -- Server-specific configs (merged with lspconfig's lsp/ defaults)
      vim.lsp.config("rust_analyzer", {
        single_file_support = true,
        settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            checkOnSave = { command = "clippy" },
          },
        },
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = { checkThirdParty = false },
            completion = { callSnippet = "Replace" },
            telemetry = { enable = false },
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      vim.lsp.config("pyright", {
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      })

      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            analyses = { unusedparams = true, shadow = true },
            staticcheck = true,
            gofumpt = true,
          },
        },
      })

      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            validate = true,
            schemaStore = { enable = false, url = "" },
            schemas = require("schemastore").yaml.schemas(),
          },
        },
      })

      vim.lsp.config("jsonls", {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      })

      -- Enable all servers (lspconfig's lsp/ directory provides defaults)
      vim.lsp.enable({
        "ts_ls",
        "rust_analyzer",
        "omnisharp",
        "pyright",
        "lua_ls",
        "taplo",
        "marksman",
        "bashls",
        "dockerls",
        "gopls",
        "jsonls",
        "ruby_lsp",
        "lemminx",
        "yamlls",
        "html",
        "cssls",
      })
    end,
  },

  -- SchemaStore for JSON/YAML schemas
  {
    "b0o/schemastore.nvim",
    lazy = true,
  },

  -- Formatting
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>lf",
        function() require("conform").format({ async = true, lsp_fallback = true }) end,
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "black" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        javascriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        markdown = { "prettier" },
        go = { "gofumpt" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
      },
      format_on_save = {
        timeout_ms = 3000,
        lsp_fallback = true,
      },
    },
  },
}
