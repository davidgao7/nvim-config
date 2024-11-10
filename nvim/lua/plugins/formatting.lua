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
				"google-java-format", -- Google's Java code formatter
				"yamlfmt", -- A YAML formatter
			},
		},
	},

	-- <leader> cf and <leader> cF are already taken by LazyVim
	keys = {
		-- 		-- Customize or remove this keymap to your liking
		-- 		"<leader>f",
		-- 		function()
		-- 			require("conform").format({ async = true )
		-- 		end,
		-- 		mode = "",
		-- 		desc = "Format buffer",
		-- 	},
		-- set disable_autorformat
		{
			"<leader>cj",
			function()
				vim.g.disable_autoformat = not vim.g.disable_autoformat
				vim.notify("Autoformat is now " .. (vim.g.disable_autoformat and "disabled" or "enabled"))
			end,
			desc = "Toggle autoformat",
		},
	},

	-- This will provide type hinting with LuaLS
	---@module "conform"
	---@type conform.setupOpts
	opts = {
		-- Define your formatters
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "ruff", "docformatter" },
			javascript = { "prettierd", stop_after_first = true },
			typescript = { "prettierd", stop_after_first = true },
			css = { "prettierd", stop_after_first = true },
			html = { "prettierd", stop_after_first = true },
			json = { "prettierd", stop_after_first = true },
			ymal = { "yamlfmt", stop_after_first = true },
			markdown = { "markdownlint-cli2", "markdown-toc", "prettierd" },
			c = { "clang-format" },
			cpp = { "clang-format" },
			cmake = { "cmake_format" },
			cs = { "csharpier" },
			rb = { "rubocop" },
			sh = { "shfmt" },
			go = { "gofumpt", "goimports", "golines" },
			java = { "google-java-format" },
		},
		-- Set default options
		default_format_opts = {
			lsp_format = "fallback",
		},

		-- Set up format-on-save
		-- NOTE: autofromat on save might skew you up when working in a team
		format_on_save = function(bufnr)
			-- Disable with a global or buffer-local variable
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return nil
			end
			-- Disable autoformat for files in a certain path
			local bufname = vim.api.nvim_buf_get_name(bufnr)
			if bufname:match("/node_modules/") then
				return nil
			end
			if bufname:match("/vendor/") then
				return nil
			end
			if bufname:match("/.git/") then
				return nil
			end
			if bufname:match("/.hg/") then
				return nil
			end
			if bufname:match("/.svn/") then
				return nil
			end
			if bufname:match("/.bzr/") then
				return nil
			end
			if bufname:match("/.fossil/") then
				return nil
			end
			if bufname:match("/.idea/") then
				return nil
			end
			if bufname:match("/.vscode/") then
				return nil
			end
			if bufname:match("/.emacs.d/") then
				return nil
			end
			if bufname:match("/.vim/") then
				return nil
			end
			if bufname:match("/.vimwiki/") then
				return nil
			end
			if bufname:match("/.gitlab/") then
				return nil
			end
			if bufname:match("/.github/") then
				return nil
			end
			if bufname:match("/.gitignore") then
				return nil
			end
			if bufname:match("/.gitmodules") then
				return nil
			end
			if bufname:match("/.gitattributes") then
				return nil
			end
			if bufname:match("/.gitconfig") then
				return nil
			end
			if bufname:match("/.gitkeep") then
				return nil
			end
			if bufname:match("/.gitmessage") then
				return nil
			end
			if bufname:match("/.gitignore_global") then
				return nil
			end
			if bufname:match("/.idea") then
				return nil
			end
			if bufname:match("/.vscode") then
				return nil
			end
			if bufname:match("/__pycache__/") then
				return nil
			end
			if bufname:match("/.pytest_cache/") then
				return nil
			end
			if bufname:match("*.py[cod]") then
				return nil
			end
			if bufname:match("*$py.class") then
				return nil
			end
			if bufname:match("*.so") then
				return nil
			end
			if bufname:match(".Python") then
				return nil
			end
			if bufname:match("/build/") then
				return nil
			end
			if bufname:match("/develop-eggs/") then
				return nil
			end
			if bufname:match("/dist/") then
				return nil
			end
			if bufname:match("/lib/") then
				return nil
			end
			if bufname:match("/lib64/") then
				return nil
			end
			if bufname:match("/parts/") then
				return nil
			end
			if bufname:match("/sdist/") then
				return nil
			end
			if bufname:match("/var/") then
				return nil
			end
			if bufname:match("/wheels/") then
				return nil
			end
			if bufname:match("/share/python-wheels/") then
				return nil
			end
			if bufname:match("/*.egg-info/") then
				return nil
			end
			if bufname:match("*.egg") then
				return nil
			end
			if bufname:match(".installed.cfg") then
				return nil
			end
			if bufname:match("MANIFEST") then
				return nil
			end
			if bufname:match(".ipynb_checkpoints") then
				return nil
			end
			if bufname:match(".venv") then
				return nil
			end
			if bufname:match("venv/") then
				return nil
			end
			return { timeout_ms = 500, lsp_format = "fallback" }
		end,
		-- Customize formatters
		formatters = {
			shfmt = {
				prepend_args = { "-i", "2" },
			},
		},
	},
}
