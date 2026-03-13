return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false, -- nvim-treesitter v1 does not support lazy-loading
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      -- Install parsers (no-op if already installed)
      require("nvim-treesitter").install({
        "typescript", "tsx", "javascript",
        "rust",
        "c_sharp",
        "python",
        "lua", "luadoc",
        "toml",
        "markdown", "markdown_inline",
        "bash",
        "dockerfile",
        "go", "gomod", "gowork", "gosum",
        "json", "json5", "jsonc",
        "gitignore", "gitcommit", "git_config", "git_rebase",
        "ruby",
        "xml",
        "yaml",
        "html",
        "css",
        "scss",
        "vim", "vimdoc", "query",
        "regex",
        "sql",
        "graphql",
        "proto",
      })

      -- Configure textobjects
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move  = { set_jumps = true },
      })

      -- Textobject select keymaps
      local select = require("nvim-treesitter-textobjects.select")
      local map = vim.keymap.set
      local function sel(query) return function() select.select_textobject(query, "textobjects") end end

      map({ "x", "o" }, "af", sel("@function.outer"), { desc = "outer function" })
      map({ "x", "o" }, "if", sel("@function.inner"), { desc = "inner function" })
      map({ "x", "o" }, "ac", sel("@class.outer"),    { desc = "outer class" })
      map({ "x", "o" }, "ic", sel("@class.inner"),    { desc = "inner class" })
      map({ "x", "o" }, "aa", sel("@parameter.outer"),{ desc = "outer argument" })
      map({ "x", "o" }, "ia", sel("@parameter.inner"),{ desc = "inner argument" })

      -- Textobject move keymaps
      local move = require("nvim-treesitter-textobjects.move")
      local function goto_next_start(query)  return function() move.goto_next_start(query,  "textobjects") end end
      local function goto_next_end(query)    return function() move.goto_next_end(query,    "textobjects") end end
      local function goto_prev_start(query)  return function() move.goto_previous_start(query, "textobjects") end end
      local function goto_prev_end(query)    return function() move.goto_previous_end(query,   "textobjects") end end

      map("n", "]f", goto_next_start("@function.outer"), { desc = "Next function start" })
      map("n", "]c", goto_next_start("@class.outer"),    { desc = "Next class start" })
      map("n", "]F", goto_next_end("@function.outer"),   { desc = "Next function end" })
      map("n", "]C", goto_next_end("@class.outer"),      { desc = "Next class end" })
      map("n", "[f", goto_prev_start("@function.outer"), { desc = "Prev function start" })
      map("n", "[c", goto_prev_start("@class.outer"),    { desc = "Prev class start" })
      map("n", "[F", goto_prev_end("@function.outer"),   { desc = "Prev function end" })
      map("n", "[C", goto_prev_end("@class.outer"),      { desc = "Prev class end" })

      -- Re-attach treesitter to buffers that were opened before this plugin loaded
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
          pcall(vim.treesitter.start, buf)
        end
      end
    end,
  },
}
