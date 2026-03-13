local opts = {
	ensure_installed = {
		"efm",
		"lua_ls",
		-- bash/zsh
		"bashls",
		-- typescript/javascript
		"ts_ls",
		"eslint",
		-- python
		"pyright",
		"ruff",
		-- toml
		"taplo",
		-- markdown
		"marksman",
		-- rust (handled by rustaceanvim, but rust-analyzer installed via mason)
		"rust_analyzer",
		-- extras you had
		"jsonls",
		"emmet_ls",
		"tailwindcss",
		"clangd",
	},

	automatic_installation = true,
}

return {
	"williamboman/mason-lspconfig.nvim",
	opts = opts,
	event = "BufReadPre",
	dependencies = "williamboman/mason.nvim",
}
