return {
	"williamboman/mason.nvim",
	cmd = "Mason",
	event = "BufReadPre",
	config = function()
		require("mason").setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		-- Ensure tools are installed
		local ensure_installed = {
			-- LSP servers (handled by mason-lspconfig, but listed for reference)
			-- Formatters
			"stylua", -- lua
			"prettier", -- js/ts/md/json/yaml
			"shfmt", -- shell
			"black", -- python (fallback)
			"isort", -- python imports
			-- Linters
			"shellcheck", -- shell
			"luacheck", -- lua
			"markdownlint", -- markdown
			"hadolint", -- docker
		}

		local mr = require("mason-registry")
		for _, tool in ipairs(ensure_installed) do
			local p = mr.get_package(tool)
			if not p:is_installed() then
				p:install()
			end
		end
	end,
}
