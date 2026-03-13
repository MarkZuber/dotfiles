return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin/nvim" },
    event = "VeryLazy",
    opts = function()
      local icons = {
        diagnostics = {
          Error = " ",
          Warn  = " ",
          Hint  = "󰠠 ",
          Info  = " ",
        },
        git = {
          added    = " ",
          modified = " ",
          removed  = " ",
        },
      }

      return {
        options = {
          theme = "catppuccin-mocha",
          globalstatus = true,
          disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
          component_separators = { left = "", right = "" },
          section_separators   = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = {
            {
              "diagnostics",
              symbols = {
                error = icons.diagnostics.Error,
                warn  = icons.diagnostics.Warn,
                info  = icons.diagnostics.Info,
                hint  = icons.diagnostics.Hint,
              },
            },
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            { "filename", path = 1, symbols = { modified = "  ", readonly = "", unnamed = "" } },
          },
          lualine_x = {
            {
              "diff",
              symbols = {
                added    = icons.git.added,
                modified = icons.git.modified,
                removed  = icons.git.removed,
              },
            },
            "encoding",
            { "fileformat", symbols = { unix = "LF", dos = "CRLF", mac = "CR" } },
          },
          lualine_y = {
            { "progress", separator = " ", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
          },
          lualine_z = {
            function() return " " .. os.date("%R") end,
          },
        },
        extensions = { "nvim-tree", "lazy", "mason", "quickfix" },
      }
    end,
  },

  -- Tabline / buffer tabs
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>bp", "<cmd>BufferLineTogglePin<cr>",            desc = "Toggle pin" },
      { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<cr>", desc = "Close unpinned buffers" },
    },
    opts = {
      options = {
        mode = "buffers",
        themable = true,
        numbers = "none",
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(_, _, diag)
          local icons = { error = " ", warning = " ", info = " " }
          local ret = (diag.error and icons.error .. diag.error .. " " or "")
            .. (diag.warning and icons.warning .. diag.warning or "")
          return vim.trim(ret)
        end,
        offsets = {
          {
            filetype = "NvimTree",
            text = "File Explorer",
            highlight = "Directory",
            separator = true,
          },
        },
        show_buffer_close_icons = true,
        show_close_icon = false,
        separator_style = "slant",
        always_show_bufferline = false,
      },
    },
  },
}
