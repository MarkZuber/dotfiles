return {
  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
      ts_config = {
        lua = { "string" },
        javascript = { "template_string" },
      },
      fast_wrap = {
        map = "<M-e>",
        chars = { "{", "[", "(", '"', "'" },
        pattern = [=[[%'%"%>%]%)%}%,]]=],
        end_key = "$",
        before_key = "h",
        after_key = "l",
        cursor_pos_before = true,
        keys = "qwertyuiopzxcvbnmasdfghjkl",
        manual_position = true,
        highlight = "Search",
        highlight_grey = "Comment",
      },
    },
    config = function(_, opts)
      local autopairs = require("nvim-autopairs")
      autopairs.setup(opts)
      -- Integration with nvim-cmp
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- Surround
  {
    "kylechui/nvim-surround",
    event = { "BufReadPre", "BufNewFile" },
    version = "*",
    opts = {},
  },

  -- vim-illuminate: highlight word under cursor
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = { providers = { "lsp" } },
      providers = { "lsp", "treesitter", "regex" },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)
      local map = vim.keymap.set
      map("n", "]]", function() require("illuminate").goto_next_reference(false) end, { desc = "Next reference" })
      map("n", "[[", function() require("illuminate").goto_prev_reference(false) end, { desc = "Prev reference" })
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = { enabled = false },
      exclude = {
        filetypes = {
          "help", "alpha", "dashboard", "nvim-tree", "Trouble",
          "trouble", "lazy", "mason", "notify", "toggleterm", "lazyterm",
        },
      },
    },
  },

  -- Comment toggling
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    config = function()
      require("Comment").setup({
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })
    end,
  },

  -- Better escape
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    opts = {
      timeout = vim.o.timeoutlen,
      mappings = {
        i = { j = { k = "<Esc>", j = "<Esc>" } },
        v = { j = { k = "<Esc>" } },
        s = { j = { k = "<Esc>" } },
      },
    },
  },

  -- Which-key: shows keybindings popup
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = {
        spelling = { enabled = true },
      },
      spec = {
        { "<leader>f", group = "Find/Telescope" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Git hunks" },
        { "<leader>l", group = "LSP" },
        { "<leader>s", group = "Split" },
        { "<leader>b", group = "Buffer" },
        { "<leader>t", group = "Tabs" },
        { "<leader>e", group = "Explorer" },
        { "<leader>c", group = "Code/Tools" },
        { "<leader>d", group = "Delete" },
      },
    },
  },

  -- Trouble: diagnostics panel
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "Trouble", "TroubleToggle" },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                        desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",           desc = "Buffer Diagnostics" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                            desc = "Location List" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                             desc = "Quickfix List" },
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>",                desc = "Symbols (Trouble)" },
      { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Definitions" },
    },
    opts = {},
  },

  -- Todo comments
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      { "]t",         function() require("todo-comments").jump_next() end, desc = "Next todo" },
      { "[t",         function() require("todo-comments").jump_prev() end, desc = "Prev todo" },
      { "<leader>xt", "<cmd>Trouble todo toggle<cr>",                      desc = "Todo (Trouble)" },
      { "<leader>fT", "<cmd>TodoTelescope<cr>",                            desc = "Todo (Telescope)" },
    },
    opts = { signs = true },
  },

  -- Flash: better navigation / search
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,             desc = "Remote Flash" },
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end,  desc = "Treesitter Search" },
      { "<C-s>", mode = { "c" },           function() require("flash").toggle() end,             desc = "Toggle Flash Search" },
    },
    opts = {},
  },

  -- Mini.nvim utilities
  {
    "echasnovski/mini.nvim",
    version = false,
    config = function()
      -- mini.ai: better text objects
      require("mini.ai").setup({ n_lines = 500 })
      -- mini.bufremove: smart buffer close
      require("mini.bufremove").setup()
      vim.keymap.set("n", "<leader>bd", function()
        require("mini.bufremove").delete(0, false)
      end, { desc = "Delete buffer" })
    end,
  },

  -- Noice: better UI for messages, cmdline, popupmenu
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      routes = {
        {
          filter = { event = "msg_show", any = {
            { find = "%d+L, %d+B" },
            { find = "; after #%d+" },
            { find = "; before #%d+" },
          }},
          view = "mini",
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
    },
  },

  -- Dashboard
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function()
      local logo = [[
         ██████╗ ██╗      █████╗ ██╗   ██╗██████╗
        ██╔════╝ ██║     ██╔══██╗██║   ██║██╔══██╗
        ██║      ██║     ███████║██║   ██║██║  ██║
        ██║      ██║     ██╔══██║██║   ██║██║  ██║
        ╚██████╗ ███████╗██║  ██║╚██████╔╝██████╔╝
         ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝
      ]]
      logo = string.rep("\n", 4) .. logo .. "\n\n"

      return {
        theme = "doom",
        hide = { statusline = false },
        config = {
          header = vim.split(logo, "\n"),
          center = {
            { action = "Telescope find_files",   desc = " Find file",   icon = " ", key = "f" },
            { action = "ene | startinsert",       desc = " New file",    icon = " ", key = "n" },
            { action = "Telescope oldfiles",      desc = " Recent files",icon = " ", key = "r" },
            { action = "Telescope live_grep",     desc = " Find text",   icon = " ", key = "g" },
            { action = "Lazy",                    desc = " Lazy",        icon = "󰒲 ", key = "l" },
            { action = "Mason",                   desc = " Mason",       icon = " ", key = "m" },
            { action = "qa",                      desc = " Quit",        icon = " ", key = "q" },
          },
          footer = function()
            local stats = require("lazy").stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
          end,
        },
      }
    end,
  },
}
