return {
	-- TODO: check following tools -> mypy types-requests types-docutils
	{
		"williamboman/mason.nvim",
		opts = function(_, opts)
			-- vim.list_extend(opts.ensure_installed, { "pyright", "black", "ruff-lsp", "ruff" })
			vim.list_extend(opts.ensure_installed, {
				-- "black",
				"ruff",
				"pyright",
				"debugpy",
			})
		end,
	},

	-- Add `python` debugger to mason DAP to auto-install
	-- Not absolutely necessary to declare adapter in `ensure_installed`, since `mason-nvim-dap`
	-- has `automatic-install = true` in LazyVim by default and it automatically installs adapters
	-- that are are set up (via dap) but not yet installed. Might as well skip the lines below as
	-- a whole.

	-- Add which-key namespace for Python debugging
	{
		"folke/which-key.nvim",
		optional = true,
		opts = {
			defaults = {
				["<leader>dP"] = { name = "+Python" },
			},
		},
	},

	-- Add `server` and setup lspconfig
	{
		"neovim/nvim-lspconfig",
		dependencies = {},
		opts = {
			servers = {
				pyright = {
					python = {
						analysis = {
							autoSearchPaths = true,
							diagnosticMode = "workspace",
							useLibraryCodeForTypes = true,
						},
					},
				},
			},
			setup = {
				pyright = function()
					require("lazyvim.util").lsp.on_attach(function(client, _)
						if client.name == "pyright" then
							-- disable hover in favor of jedi-language-server(if you have)
							client.server_capabilities.hoverProvider = true
						end
					end)
				end,
			},
		},
	},
	{
		"linux-cultist/venv-selector.nvim",
		branch = "regexp", -- Use this branch for the new version
		cmd = "VenvSelect",
		enabled = function()
			return LazyVim.has("telescope.nvim")
		end,
		opts = {
			settings = {
				options = {
					notify_user_on_venv_activation = true,
				},
			},
		},
		--  Call config for python files and load the cached venv automatically
		ft = "python",
		keys = { { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv", ft = "python" } },
	},

	-- python snippets
	{
		"garymjr/nvim-snippets",
		opts = {
			friendly_snippets = true,
		},
		dependencies = { "rafamadriz/friendly-snippets" },
	},

	-- setup nvim-cmp snippets activate
	{
		"nvim-cmp",
		optional = true,
		dependencies = {
			{
				"garymjr/nvim-snippets",
				opts = {
					friendly_snippets = true,
				},
				dependencies = { "rafamadriz/friendly-snippets" },
			},
		},
		opts = function(_, opts)
			opts.snippet = {
				expand = function(item)
					return LazyVim.cmp.expand(item.body)
				end,
			}
			if LazyVim.has("nvim-snippets") then
				table.insert(opts.sources, { name = "snippets" })
			end
		end,
		keys = {
			{
				"<Tab>",
				function()
					return vim.snippet.active({ direction = 1 }) and "<cmd>lua vim.snippet.jump(1)<cr>" or "<Tab>"
				end,
				expr = true,
				silent = true,
				mode = { "i", "s" },
			},
			{
				"<S-Tab>",
				function()
					return vim.snippet.active({ direction = -1 }) and "<cmd>lua vim.snippet.jump(-1)<cr>" or "<S-Tab>"
				end,
				expr = true,
				silent = true,
				mode = { "i", "s" },
			},
		},
	},

	-- Setup null-ls with `black`
	-- {
	--   "nvimtools/none-ls.nvim",
	--   opts = function(_, opts)
	--     local nls = require("null-ls")
	--     opts.sources = vim.list_extend(opts.sources, {
	--       -- Order of formatters matters. They are used in order of appearance.
	--       nls.builtins.formatting.ruff,
	--       nls.builtins.formatting.black,
	--       -- nls.builtins.formatting.black.with({
	--       --   extra_args = { "--preview" },
	--       -- }),
	--       -- nls.builtins.diagnostics.ruff,
	--     })
	--   end,
	-- },

	-- For selecting virtual envs
}
