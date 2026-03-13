-- Claude Code integration via terminal
-- Uses the `claude` CLI tool if available
return {
  {
    "akinsho/toggleterm.nvim",
    -- already loaded via extras.lua, this just adds Claude-specific keymaps
    optional = true,
    keys = {
      {
        "<leader>ac",
        function()
          if vim.fn.executable("claude") == 0 then
            vim.notify("claude CLI not found. Install with: npm install -g @anthropic-ai/claude-code", vim.log.levels.WARN)
            return
          end
          local Terminal = require("toggleterm.terminal").Terminal
          local claude = Terminal:new({
            cmd = "claude",
            dir = "git_dir",
            direction = "float",
            float_opts = { border = "curved" },
            close_on_exit = false,
            on_open = function(term)
              vim.cmd("startinsert!")
              vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-\\>", "<cmd>ToggleTerm<CR>", { noremap = true })
            end,
          })
          claude:toggle()
        end,
        desc = "Claude Code",
      },
      -- Open Claude with current file context
      {
        "<leader>af",
        function()
          if vim.fn.executable("claude") == 0 then
            vim.notify("claude CLI not found.", vim.log.levels.WARN)
            return
          end
          local file = vim.fn.expand("%:p")
          local Terminal = require("toggleterm.terminal").Terminal
          local claude = Terminal:new({
            cmd = "claude 'Please help me with this file: " .. file .. "'",
            dir = "git_dir",
            direction = "float",
            float_opts = { border = "curved" },
            close_on_exit = false,
          })
          claude:toggle()
        end,
        desc = "Claude with current file",
      },
    },
  },

  -- avante.nvim: AI pair programming (ChatGPT/Claude in nvim)
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    build = "make",
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      "hrsh7th/nvim-cmp",
      "nvim-telescope/telescope.nvim",
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = { insert_mode = true },
            use_absolute_path = true,
          },
        },
      },
      {
        "MeanderingProgrammer/render-markdown.nvim",
        optional = true,
      },
    },
    opts = {
      provider = "claude",
      auto_suggestions_provider = "claude",
      providers = {
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-sonnet-4-5",
          extra_request_body = {
            temperature = 0,
            max_tokens = 8192,
          },
        },
      },
      behaviour = {
        auto_suggestions = false,
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = false,
      },
      mappings = {
        diff = {
          ours    = "co",
          theirs  = "ct",
          all_theirs = "ca",
          both    = "cb",
          cursor  = "cc",
          next    = "]x",
          prev    = "[x",
        },
        suggestion = {
          accept = "<M-l>",
          next   = "<M-]>",
          prev   = "<M-[>",
          dismiss = "<C-]>",
        },
        jump = { next = "]]", prev = "[[" },
        submit = { normal = "<CR>", insert = "<C-s>" },
        sidebar = {
          apply_all     = "A",
          apply_cursor  = "a",
          switch_windows = "<Tab>",
          reverse_switch_windows = "<S-Tab>",
        },
      },
      windows = {
        position = "right",
        wrap = true,
        width = 30,
        sidebar_header = {
          enabled = true,
          align = "center",
          rounded = true,
        },
        input = {
          prefix = "> ",
          height = 8,
        },
        edit = { border = "rounded", start_insert = true },
        ask = {
          floating = false,
          start_insert = true,
          border = "rounded",
          focused_on_apply = "ours",
        },
      },
      highlights = {
        diff = {
          current = "DiffText",
          incoming = "DiffAdd",
        },
      },
      diff = {
        autojump = true,
        list_opener = "copen",
        override_timeoutlen = 500,
      },
    },
    keys = {
      { "<leader>aa", "<cmd>AvanteAsk<cr>",    mode = { "n", "v" }, desc = "Avante Ask" },
      { "<leader>ae", "<cmd>AvanteEdit<cr>",   mode = { "v" },      desc = "Avante Edit" },
      { "<leader>ar", "<cmd>AvanteRefresh<cr>",                     desc = "Avante Refresh" },
      { "<leader>at", "<cmd>AvanteToggle<cr>",                      desc = "Avante Toggle" },
    },
  },
}
