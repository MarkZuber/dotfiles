return {
  -- Git signs in gutter
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = vim.keymap.set
        local opts = { noremap = true, silent = true, buffer = bufnr }

        -- Navigation
        map("n", "]h", function()
          if vim.wo.diff then return "]h" end
          vim.schedule(function() gs.next_hunk() end)
          return "<Ignore>"
        end, vim.tbl_extend("force", opts, { expr = true }))

        map("n", "[h", function()
          if vim.wo.diff then return "[h" end
          vim.schedule(function() gs.prev_hunk() end)
          return "<Ignore>"
        end, vim.tbl_extend("force", opts, { expr = true }))

        -- Actions
        map("n", "<leader>hs", gs.stage_hunk, opts)
        map("n", "<leader>hr", gs.reset_hunk, opts)
        map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, opts)
        map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, opts)
        map("n", "<leader>hS", gs.stage_buffer, opts)
        map("n", "<leader>hu", gs.undo_stage_hunk, opts)
        map("n", "<leader>hR", gs.reset_buffer, opts)
        map("n", "<leader>hp", gs.preview_hunk, opts)
        map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, opts)
        map("n", "<leader>hB", gs.toggle_current_line_blame, opts)
        map("n", "<leader>hd", gs.diffthis, opts)
        map("n", "<leader>hD", function() gs.diffthis("~") end, opts)

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", opts)
      end,
    },
  },

  -- Lazygit integration
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },
}
