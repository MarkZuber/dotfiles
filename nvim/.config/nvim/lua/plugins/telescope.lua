return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
      "nvim-telescope/telescope-file-browser.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>",                desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",                 desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",                   desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",                 desc = "Help tags" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",                  desc = "Recent files" },
      { "<leader>fs", "<cmd>Telescope grep_string<cr>",               desc = "Grep string" },
      { "<leader>fc", "<cmd>Telescope colorscheme<cr>",               desc = "Colorschemes" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>",                   desc = "Keymaps" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>",               desc = "Diagnostics" },
      { "<leader>fw", "<cmd>Telescope lsp_workspace_symbols<cr>",     desc = "Workspace symbols" },
      { "<leader>fo", "<cmd>Telescope lsp_document_symbols<cr>",      desc = "Document symbols" },
      { "<leader>fi", "<cmd>Telescope lsp_implementations<cr>",       desc = "Implementations" },
      { "<leader>ft", "<cmd>Telescope treesitter<cr>",                desc = "Treesitter" },
      { "<leader>gc", "<cmd>Telescope git_commits<cr>",               desc = "Git commits" },
      { "<leader>gb", "<cmd>Telescope git_branches<cr>",              desc = "Git branches" },
      { "<leader>gs", "<cmd>Telescope git_status<cr>",                desc = "Git status" },
      { "<leader><leader>", "<cmd>Telescope find_files<cr>",          desc = "Find files" },
      { "<leader>/",  "<cmd>Telescope live_grep<cr>",                 desc = "Live grep" },
    },
    opts = function()
      local actions = require("telescope.actions")
      return {
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          path_display = { "smart" },
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = { prompt_position = "top", preview_width = 0.55 },
            vertical = { mirror = false },
            width = 0.87,
            height = 0.80,
          },
          mappings = {
            i = {
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<esc>"] = actions.close,
            },
          },
          file_ignore_patterns = {
            "node_modules", ".git/", "dist/", "build/", "target/",
            "%.lock", "lazy%-lock%.json",
          },
        },
        pickers = {
          find_files = { hidden = true },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      }
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      telescope.load_extension("fzf")
      pcall(telescope.load_extension, "file_browser")
    end,
  },
}
