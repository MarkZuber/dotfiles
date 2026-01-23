local maplazykey = require("util.keymapper").maplazykey

return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		modes = {
			diagnostics = {
				auto_close = false,
				auto_open = false,
				auto_preview = true,
				auto_refresh = true,
			},
		},
	},
	cmd = "Trouble",
	keys = {
		maplazykey("<leader>xx", function()
			require("trouble").toggle("diagnostics")
		end, "Toggle Diagnostics"),
		maplazykey("<leader>xw", function()
			require("trouble").toggle("diagnostics")
		end, "Show Workspace Diagnostics"),
		maplazykey("<leader>xd", function()
			require("trouble").toggle({
				mode = "diagnostics",
				filter = { buf = 0 },
			})
		end, "Show Document Diagnostics"),
		maplazykey("<leader>xq", function()
			require("trouble").toggle("quickfix")
		end, "Toggle Quickfix List"),
		maplazykey("<leader>xl", function()
			require("trouble").toggle("loclist")
		end, "Toggle Location List"),
		maplazykey("gR", function()
			require("trouble").toggle("lsp_references")
		end, "Toggle LSP References"),
	},
}
