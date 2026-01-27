local config = function()
	require("nvim-treesitter.configs").setup({
		build = ":TSUpdate",
		indent = {
			enable = true,
		},
		ensure_installed = {
			-- shells
			"bash",
			-- web
			"javascript",
			"typescript",
			"tsx",
			"html",
			"css",
			"scss",
			"vue",
			"svelte",
			-- data formats
			"json",
			"jsonc",
			"yaml",
			"toml",
			-- documentation
			"markdown",
			"markdown_inline",
			-- programming
			"python",
			"rust",
			"lua",
			"c",
			"cpp",
			-- config/other
			"dockerfile",
			"gitignore",
			"gitcommit",
			"diff",
			"regex",
			"vim",
			"vimdoc",
		},
		auto_install = true,
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = { "markdown" },
		},
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "<C-s>",
				node_incremental = "<C-s>",
				scope_incremental = false,
				node_decremental = "<BS>",
			},
		},
	})
end

return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	config = config,
	build = ":TSUpdate",
}
