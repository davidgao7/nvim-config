return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },

	{
		"williamboman/mason.nvim",
		opts = {
			ensure_installed = {
				"clang-format", -- c/cpp formatter
				"ruff", -- python formatter
				"cmakelang", -- cmake formatter
				"csharpier", -- C# formatter
				"docformatter", -- python docstring formatter
				"gofumpt", -- Go formatter
				"goimports", -- Updates your Go import lines, adding missing ones and removing unreferenced ones.
				"golines", -- A golang formatter that fixes long lines.
				"markdown-toc", --API and CLI for generating a markdown TOC (table of contents) for a README or any markdown files.
				"markdownlint-cli2", -- A fast, flexible, configuration-based command-line interface for linting Markdown/CommonMark files with the markdownlint library.
				"prettierd", -- prettier, as a daemon, for ludicrous formatting speed.
				"rubocop", -- Ruby static code analyzer and formatter, based on the community Ruby style guide.
				"shfmt", --  A shell parser, formatter, and interpreter with bash support.
				"stylua", -- An opinionated code formatter for Lua.
			},
		},
	},

	-- keys =  -- <leader> cf and <leader> cF are already taken by LazyVim
	-- 	{
	-- 		-- Customize or remove this keymap to your liking
	-- 		"<leader>f",
	-- 		function()
	-- 			require("conform").format({ async = true )
	-- 		end,
	-- 		mode = "",
	-- 		desc = "Format buffer",
	-- 	},
	-- },

	-- This will provide type hinting with LuaLS
	---@module "conform"
	---@type conform.setupOpts
	opts = {
		-- Define your formatters
		formatters_by_ft = {
			["lua"] = { "stylua" },
			["python"] = { "ruff", "docformatter" },
			["javascript"] = { "prettierd", stop_after_first = true },
			["typescript"] = { "prettierd", stop_after_first = true },
			["css"] = { "prettierd", stop_after_first = true },
			["html"] = { "prettierd", stop_after_first = true },
			["json"] = { "prettierd", stop_after_first = true },
			["ymal"] = { "prettierd", stop_after_first = true },
			["markdown"] = { "markdownlint-cli2", "markdown-toc", "prettierd" },
			["markdown.mdx"] = { "markdownlint-cli2", "markdown-toc", "prettierd" },
			["c"] = { "clang-format" },
			["cpp"] = { "clang-format" },
			["cmake"] = { "cmake_format" },
			["cs"] = { "csharpier" },
			["rb"] = { "rubocop" },
			["sh"] = { "shfmt" },
			["go"] = { "gofumpt", "goimports", "golines" },
		},
		-- Set default options
		default_format_opts = {
			lsp_format = "fallback",
		},
		-- Set up format-on-save
		format_on_save = { timeout_ms = 500 },
		-- Customize formatters
		formatters = {
			shfmt = {
				prepend_args = { "-i", "2" },
			},
		},
	},
	init = function()
		-- If you want the formatexpr, here is the place to set it
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	end,
}
