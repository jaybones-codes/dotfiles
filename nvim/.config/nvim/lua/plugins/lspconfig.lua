---@module "plugins.lsp"
---@type LazySpec
local spec = {

	-- Mason: tool manager
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		config = true,
	},

	-- Mason-LSP bridge
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			ensure_installed = { "lua_ls", "clangd", "pyright" },
			automatic_installation = true,
		},
	},

	-- Core LSP (no longer needs nvim-lspconfig plugin for nvim 0.11+)
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "williamboman/mason-lspconfig.nvim" },
		config = function()
			local mason_lspconfig = require("mason-lspconfig")

			-- Gruvbox-style LSP floating diagnostics
			vim.diagnostic.config({
				virtual_text = false,
				signs = true,
				underline = true,
				severity_sort = true,
				float = {
					border = "single",
					focusable = false,
					source = "always",
					header = "",
					prefix = "",
					style = "minimal",
				},
			})

			-- Gruvbox floating colors
			local guibg = "#282828"
			vim.api.nvim_set_hl(0, "DiagnosticFloatingError", { fg = "#fb4934", bg = guibg })
			vim.api.nvim_set_hl(0, "DiagnosticFloatingWarn", { fg = "#fabd2f", bg = guibg })
			vim.api.nvim_set_hl(0, "DiagnosticFloatingInfo", { fg = "#83a598", bg = guibg })
			vim.api.nvim_set_hl(0, "DiagnosticFloatingHint", { fg = "#8ec07c", bg = guibg })

			-- Shared on_attach
			local on_attach = function(client, bufnr)
				local opts = { noremap = true, silent = true, buffer = bufnr }
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
				vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

				-- Floating diagnostics on CursorHold
				vim.api.nvim_create_autocmd("CursorHold", {
					buffer = bufnr,
					callback = function()
						vim.diagnostic.open_float(nil, { focusable = false })
					end,
				})
			end

			-- Shared capabilities for completion
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			if has_cmp then
				capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
			end

			-- Setup LSP servers using new nvim 0.11+ API
			for _, server_name in ipairs(mason_lspconfig.get_installed_servers()) do
				-- Configure the LSP server
				vim.lsp.config(server_name, {
					cmd = vim.lsp.config[server_name] and vim.lsp.config[server_name].cmd or nil,
					root_markers = vim.lsp.config[server_name] and vim.lsp.config[server_name].root_markers or nil,
					capabilities = capabilities,
					on_attach = on_attach,
				})
			end

			-- Enable all configured LSP servers
			local servers = mason_lspconfig.get_installed_servers()
			if #servers > 0 then
				vim.lsp.enable(servers)
			end
		end,
	},

	-- Blink: completion
	{
		"saghen/blink.cmp",
		build = "cargo build --release",
		event = "InsertEnter",
		dependencies = {
			"L3MON4D3/LuaSnip",
			"rafamadriz/friendly-snippets",
		},
		opts = {
			keymap = { preset = "default" },
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
			completion = {
				documentation = { auto_show = true, auto_show_delay_ms = 200 },
			},
			signature = { enabled = true },
		},
	},
	-- Conform: formatting
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					cpp = { "clang_format" },
					c = { "clang_format" },
					python = { "black" },
				},
				formatters = {
					clang_format = {
						prepend_args = {
							"--style={BasedOnStyle: Microsoft, IndentWidth: 4, ColumnLimit: 120}",
						},
					},
					2,
				},
				format_on_save = {
					timeout_ms = 500,
					lsp_fallback = true,
				},
			})
		end,
	},
}

return spec
