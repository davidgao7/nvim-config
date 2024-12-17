return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"fredrikaverpil/neotest-golang",
			"nvim-lua/plenary.nvim",
			"alfaix/neotest-gtest",
		},
		opts = {
			-- Can be a list of adapters like what neotest expects,
			-- or a list of adapter names,
			-- or a table of adapter names, mapped to adapter configs.
			-- The adapter will then be automatically loaded with the config.
			-- Example for loading neotest-golang with a custom config
			adapters = {
				-- go test
				["neotest-golang"] = {
					go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" },
					dap_go_enabled = true,
				},
				-- python pytest
				["neotest-python"] = {
					runner = "pytest",
					python = function()
						require("dap-python").test_runner = "pytest"
						local path = require("mason-registry").get_package("debugpy"):get_install_path()
						return path .. "/venv/bin/python"
					end,
				},
			},
			status = { virtual_text = true },
			output = { open_on_run = true },
			quickfix = {
				open = function()
					if LazyVim.has("trouble.nvim") then
						require("trouble").open({ mode = "quickfix", focus = false })
					else
						vim.cmd("copen")
					end
				end,
			},
		},
		config = function(_, opts)
			local neotest_ns = vim.api.nvim_create_namespace("neotest")
			vim.diagnostic.config({
				virtual_text = {
					format = function(diagnostic)
						-- Replace newline and tab characters with space for more compact diagnostics
						local message =
							diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
						return message
					end,
				},
			}, neotest_ns)

			if LazyVim.has("trouble.nvim") then
				opts.consumers = opts.consumers or {}
				-- Refresh and auto close trouble after running tests
				---@type neotest.Consumer
				opts.consumers.trouble = function(client)
					client.listeners.results = function(adapter_id, results, partial)
						if partial then
							return
						end
						local tree = assert(client:get_position(nil, { adapter = adapter_id }))

						local failed = 0
						for pos_id, result in pairs(results) do
							if result.status == "failed" and tree:get_key(pos_id) then
								failed = failed + 1
							end
						end
						vim.schedule(function()
							local trouble = require("trouble")
							if trouble.is_open() then
								trouble.refresh()
								if failed == 0 then
									trouble.close()
								end
							end
						end)
						return {}
					end
				end
			end

			if opts.adapters then
				local adapters = {}
				for name, config in pairs(opts.adapters or {}) do
					if type(name) == "number" then
						if type(config) == "string" then
							config = require(config)
						end
						adapters[#adapters + 1] = config
					elseif config ~= false then
						local adapter = require(name)
						if type(config) == "table" and not vim.tbl_isempty(config) then
							local meta = getmetatable(adapter)
							if adapter.setup then
								adapter.setup(config)
							elseif adapter.adapter then
								adapter.adapter(config)
								adapter = adapter.adapter
							elseif meta and meta.__call then
								adapter(config)
							else
								error("Adapter " .. name .. " does not support setup")
							end
						end
						adapters[#adapters + 1] = adapter
					end
				end
				opts.adapters = adapters
			end

			require("neotest").setup(opts)

			-- cpp test
			local utils = require("neotest-gtest.utils")
			local lib = require("neotest.lib")

			require("neotest-gtest").setup({
				-- fun(string) -> string: takes a file path as string and returns its project root
				-- directory
				-- neotest.lib.files.match_root_pattern() is a convenient factory for these functions:
				-- it returns a function that returns true if the directory contains any entries
				-- with matching names
				root = lib.files.match_root_pattern(
					"compile_commands.json",
					"compile_flags.txt",
					"WORKSPACE",
					".clangd",
					"init.lua",
					"init.vim",
					"build",
					".git"
				),
				-- which debug adapter to use? dap.adapters.<this debug_adapter> must be defined.
				debug_adapter = "codelldb",
				-- fun(string) -> bool: takes a file path as string and returns true if it contains
				-- tests
				is_test_file = function(file)
					-- by default, returns true if the file stem starts with test_ or ends with _test
					-- the extension must be cpp/cppm/cc/cxx/c++
				end,
				-- How many old test results to keep on disk (stored in stdpath('data')/neotest-gtest/runs)
				history_size = 3,
				-- To prevent large projects from freezing your computer, there's some throttling
				-- for -- parsing test files. Decrease if your parsing is slow and you have a
				-- monster PC.
				parsing_throttle_ms = 10,
				-- set configure to a normal mode key which will run :ConfigureGtest (suggested:
				-- "C", nil by default)
				mappings = { configure = nil },
				summary_view = {
					-- How long should the header be in tests short summary?
					-- ________TestNamespace.TestName___________ <- this is the header
					header_length = 80,
					-- Your shell's colors, if the default ones don't work.
					shell_palette = {
						passed = "\27[32m",
						skipped = "\27[33m",
						failed = "\27[31m",
						stop = "\27[0m",
						bold = "\27[1m",
					},
				},
				-- What extra args should ALWAYS be sent to google test?
				-- if you want to send them for one given invocation only,
				-- send them to `neotest.run({extra_args = ...})`
				-- see :h neotest.RunArgs for details
				extra_args = {},
				-- see :h neotest.Config.discovery. Best to keep this as-is and set
				-- per-project settings in neotest instead.
				filter_dir = function(name, rel_path, root)
					-- see :h neotest.Config.discovery for defaults
				end,
			})
		end,
  -- stylua: ignore
  keys = {
    {"<leader>t", "", desc = "+test"},
    { "<leader>tt", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run File" },
    { "<leader>tT", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "Run All Test Files" },
    { "<leader>tr", function() require("neotest").run.run() end, desc = "Run Nearest" },
    { "<leader>tl", function() require("neotest").run.run_last() end, desc = "Run Last" },
    { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle Summary" },
    { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show Output" },
    { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Toggle Output Panel" },
    { "<leader>tS", function() require("neotest").run.stop() end, desc = "Stop" },
    { "<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, desc = "Toggle Watch" },
  },
	},
}
