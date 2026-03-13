local on_attach = require("util.lsp").on_attach
local diagnostic_signs = require("util.icons").diagnostic_signs
local typescript_organise_imports = require("util.lsp").typescript_organise_imports

local config = function()
	require("neoconf").setup({})
	local cmp_nvim_lsp = require("cmp_nvim_lsp")
	local lspconfig = require("lspconfig")
	local capabilities = cmp_nvim_lsp.default_capabilities()

	local function get_setup(name)
		if vim.lsp and vim.lsp.config and vim.lsp.config[name] and type(vim.lsp.config[name].setup) == "function" then
			return vim.lsp.config[name].setup
		end
		local ok, mod = pcall(require, "lspconfig.server_configurations." .. name)
		if ok and mod and type(mod.setup) == "function" then
			return mod.setup
		end
		return nil
	end

	for type, icon in pairs(diagnostic_signs) do
		local hl = "DiagnosticSign" .. type
		vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
	end

	-- lua
	do
		local _setup = get_setup("lua_ls")
		if _setup then
			_setup({
		capabilities = capabilities,
		on_attach = on_attach,
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					library = {
						[vim.fn.expand("$VIMRUNTIME/lua")] = true,
						[vim.fn.stdpath("config") .. "/lua"] = true,
					},
				},
			},
		},
			})
		end
	end

	-- json
	do
		local _setup = get_setup("jsonls")
		if _setup then
			_setup({
		capabilities = capabilities,
		on_attach = on_attach,
		filetypes = { "json", "jsonc" },
			})
		end
	end

	-- python (pyright for type checking)
	do
		local _setup = get_setup("pyright")
		if _setup then
			_setup({
		capabilities = capabilities,
		on_attach = on_attach,
		settings = {
			pyright = {
				disableOrganizeImports = true, -- use ruff for this
			},
			python = {
				analysis = {
					useLibraryCodeForTypes = true,
					autoSearchPaths = true,
					diagnosticMode = "workspace",
					autoImportCompletions = true,
					typeCheckingMode = "basic",
				},
			},
		},
			})
		end
	end

	-- python (ruff for linting/formatting - fast, modern)
	do
		local _setup = get_setup("ruff")
		if _setup then
			_setup({
		capabilities = capabilities,
		on_attach = function(client, bufnr)
			-- Disable hover in favor of pyright
			client.server_capabilities.hoverProvider = false
			on_attach(client, bufnr)
		end,
			})
		end
	end

	-- typescript/javascript
	do
		local _setup = get_setup("ts_ls")
		if _setup then
			_setup({
		on_attach = on_attach,
		capabilities = capabilities,
		filetypes = {
			"typescript",
			"javascript",
			"typescriptreact",
			"javascriptreact",
		},
		commands = {
			TypeScriptOrganizeImports = typescript_organise_imports,
		},
		settings = {
			typescript = {
				indentStyle = "space",
				indentSize = 2,
				inlayHints = {
					includeInlayParameterNameHints = "all",
					includeInlayParameterNameHintsWhenArgumentMatchesName = false,
					includeInlayFunctionParameterTypeHints = true,
					includeInlayVariableTypeHints = true,
					includeInlayPropertyDeclarationTypeHints = true,
					includeInlayFunctionLikeReturnTypeHints = true,
					includeInlayEnumMemberValueHints = true,
				},
			},
			javascript = {
				inlayHints = {
					includeInlayParameterNameHints = "all",
					includeInlayParameterNameHintsWhenArgumentMatchesName = false,
					includeInlayFunctionParameterTypeHints = true,
					includeInlayVariableTypeHints = true,
					includeInlayPropertyDeclarationTypeHints = true,
					includeInlayFunctionLikeReturnTypeHints = true,
					includeInlayEnumMemberValueHints = true,
				},
			},
		},
		root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", ".git"),
			})
		end
	end

	-- eslint (better integration for JS/TS linting)
	do
		local _setup = get_setup("eslint")
		if _setup then
			_setup({
		capabilities = capabilities,
		on_attach = function(client, bufnr)
			-- Auto-fix on save
			vim.api.nvim_create_autocmd("BufWritePre", {
				buffer = bufnr,
				command = "EslintFixAll",
			})
			on_attach(client, bufnr)
		end,
		filetypes = {
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"vue",
			"svelte",
		},
			})
		end
	end

	-- bash/zsh
	do
		local _setup = get_setup("bashls")
		if _setup then
			_setup({
		capabilities = capabilities,
		on_attach = on_attach,
		filetypes = { "sh", "bash", "zsh" },
			})
		end
	end

	-- toml
	do
		local _setup = get_setup("taplo")
		if _setup then
			_setup({
		capabilities = capabilities,
		on_attach = on_attach,
		settings = {
			taplo = {
				formatter = {
					alignEntries = false,
					alignComments = true,
					arrayTrailingComma = true,
					arrayAutoExpand = true,
					arrayAutoCollapse = true,
					compactArrays = true,
					compactInlineTables = false,
					indentTables = false,
					reorderKeys = true,
				},
			},
		},
			})
		end
	end

	-- markdown
	do
		local _setup = get_setup("marksman")
		if _setup then
			_setup({
		capabilities = capabilities,
		on_attach = on_attach,
		filetypes = { "markdown", "markdown.mdx" },
			})
		end
	end

	-- emmet for HTML/JSX
	do
		local _setup = get_setup("emmet_ls")
		if _setup then
			_setup({
		capabilities = capabilities,
		on_attach = on_attach,
		filetypes = {
			"typescriptreact",
			"javascriptreact",
			"javascript",
			"css",
			"sass",
			"scss",
			"less",
			"svelte",
			"vue",
			"html",
		},
			})
		end
	end

	-- docker
	do
		local _setup = get_setup("dockerls")
		if _setup then
			_setup({
		capabilities = capabilities,
		on_attach = on_attach,
			})
		end
	end

	-- C/C++
	do
		local _setup = get_setup("clangd")
		if _setup then
			_setup({
		capabilities = capabilities,
		on_attach = on_attach,
		cmd = {
			"clangd",
			"--offset-encoding=utf-16",
		},
			})
		end
	end

	-- EFM for additional linting/formatting
	local luacheck = require("efmls-configs.linters.luacheck")
	local stylua = require("efmls-configs.formatters.stylua")
	local prettier_d = require("efmls-configs.formatters.prettier_d")
	local fixjson = require("efmls-configs.formatters.fixjson")
	local shellcheck = require("efmls-configs.linters.shellcheck")
	local shfmt = require("efmls-configs.formatters.shfmt")
	local hadolint = require("efmls-configs.linters.hadolint")
	local clangformat = require("efmls-configs.formatters.clang_format")
	local cpplint = require("efmls-configs.linters.cpplint")

	do
		local _setup = get_setup("efm")
		if _setup then
			_setup({
		filetypes = {
			"lua",
			"json",
			"jsonc",
			"sh",
			"bash",
			"zsh",
			"markdown",
			"docker",
			"html",
			"css",
			"c",
			"cpp",
		},
		init_options = {
			documentFormatting = true,
			documentRangeFormatting = true,
			hover = true,
			documentSymbol = true,
			codeAction = true,
			completion = true,
		},
		settings = {
			languages = {
				lua = { luacheck, stylua },
				json = { fixjson },
				jsonc = { fixjson },
				sh = { shellcheck, shfmt },
				bash = { shellcheck, shfmt },
				zsh = { shellcheck, shfmt },
				markdown = { prettier_d },
				docker = { hadolint, prettier_d },
				html = { prettier_d },
				css = { prettier_d },
				c = { clangformat, cpplint },
				cpp = { clangformat, cpplint },
			},
		},
			})
		end
	end
end

return {
	"neovim/nvim-lspconfig",
	config = config,
	lazy = false,
	dependencies = {
		"windwp/nvim-autopairs",
		"williamboman/mason.nvim",
		"creativenull/efmls-configs-nvim",
		"hrsh7th/nvim-cmp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-nvim-lsp",
	},
}
