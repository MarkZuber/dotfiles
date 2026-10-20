-- Claude Code lives on <leader>a via the ai.claudecode extra (lazyvim.json). avante.nvim
-- talks to the Anthropic API directly (needs ANTHROPIC_API_KEY), so it gets <leader>A to stay
-- out of claudecode's way rather than using LazyVim's ai.avante extra, which also wants <leader>a.
return {
  {
    "yetone/avante.nvim",
    -- build.sh downloads the prebuilt release libraries; `make` compiles from source with cargo,
    -- which needs a gitlab.com dependency and fails behind SSH-only git URL rewrites.
    -- Run through sh: the repo doesn't always ship build.sh executable.
    build = "sh build.sh",
    event = "VeryLazy",
    version = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      -- avante's command parser (required since it moved to avante-corp/avante.nvim).
      { "ColinKennedy/mega.cmdparse", dependencies = { "ColinKennedy/mega.logging" } },
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
    },
    opts = {
      provider = "claude",
      providers = {
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-sonnet-5-5",
          extra_request_body = {
            temperature = 0,
            max_tokens = 8192,
          },
        },
      },
      selection = { hint_display = "none" },
      behaviour = {
        auto_suggestions = false,
        auto_set_keymaps = false,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = false,
      },
      windows = {
        position = "right",
        wrap = true,
        width = 30,
      },
    },
    keys = {
      { "<leader>A", "", desc = "+avante", mode = { "n", "v" } },
      { "<leader>Aa", "<cmd>AvanteAsk<cr>", mode = { "n", "v" }, desc = "Ask" },
      { "<leader>Ae", "<cmd>AvanteEdit<cr>", mode = "v", desc = "Edit selection" },
      { "<leader>Ac", "<cmd>AvanteChat<cr>", desc = "Chat" },
      { "<leader>An", "<cmd>AvanteChatNew<cr>", desc = "New chat" },
      { "<leader>Ar", "<cmd>AvanteRefresh<cr>", desc = "Refresh" },
      { "<leader>As", "<cmd>AvanteStop<cr>", desc = "Stop" },
      { "<leader>At", "<cmd>AvanteToggle<cr>", desc = "Toggle sidebar" },
      { "<leader>Am", "<cmd>AvanteModels<cr>", desc = "Select model" },
    },
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    optional = true,
    opts = { file_types = { "markdown", "Avante" } },
    ft = { "markdown", "Avante" },
  },
}
