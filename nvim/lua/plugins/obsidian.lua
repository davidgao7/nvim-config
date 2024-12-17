return {
	-- Obsidian.nvim plugin
	{
		"epwalsh/obsidian.nvim",
		version = "*", -- Use the latest release
		lazy = true,
		cmd = {
			"ObsidianOpen",
			"ObsidianQuickSwitch",
			"ObsidianNew",
			"ObsidianSearch",
			"ObsidianTemplate",
			"ObsidianToday",
			"ObsidianTomorrow",
			"ObsidianYesterday",
		},
		event = {
			"BufReadPre /Users/tengjungao/Documents/Obsidian_Vault/*.md",
			"BufNewFile /Users/tengjungao/Documents/Obsidian_Vault/*.md",
		},
		ft = "markdown",
		dependencies = {
			-- Required dependency
			"nvim-lua/plenary.nvim",
			-- Optional dependencies for enhanced functionality
			"nvim-telescope/telescope.nvim", -- Fuzzy finder
			"nvim-treesitter/nvim-treesitter", -- Syntax highlighting
		},
		opts = {
			-- Define your Obsidian vaults
			workspaces = {
				{
					name = "notes",
					path = "~/Documents/Obsidian_Vault",
				},
				-- Add more workspaces if needed
			},
			-- Set the log level for obsidian.nvim
			log_level = vim.log.levels.INFO,
			-- Configuration for daily notes
			daily_notes = {
				folder = "notes/dailies",
				date_format = "%Y-%m-%d",
				alias_format = "%B %-d, %Y",
				default_tags = { "daily-notes" },
				template = "daily_template.md", -- Specify your daily note template
			},
			-- User interface settings
			ui = {
				enable = false, -- Set to true to enable Obsidian's UI features
			},
			-- Completion settings
			completion = {
				nvim_cmp = false, -- Enable nvim-cmp for autocompletion
				-- min_chars = 2, -- Trigger completion after 2 characters
			},
			-- Key mappings
			mappings = {
				["gd"] = { -- lets always to go to definition
					action = function()
						return require("obsidian").util.gf_passthrough()
					end,
					opts = { noremap = false, expr = true, buffer = true },
				},
				["<leader>ch"] = {
					action = function()
						return require("obsidian").util.toggle_checkbox()
					end,
					opts = { buffer = true },
				},
				["<cr>"] = {
					action = function()
						return require("obsidian").util.smart_action()
					end,
					opts = { buffer = true, expr = true },
				},
			},
			-- Function to generate note IDs
			note_id_func = function(title)
				local suffix = ""
				if title ~= nil then
					suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
				else
					for _ = 1, 4 do
						suffix = suffix .. string.char(math.random(65, 90))
					end
				end
				return tostring(os.time()) .. "-" .. suffix
			end,
			-- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
			-- URL it will be ignored but you can customize this behavior here.
			---@param url string
			follow_url_func = function(url)
				-- Open the URL in the default web browser.
				vim.fn.jobstart({ "open", url }) -- Mac OS
				-- vim.fn.jobstart({"xdg-open", url})  -- linux
			end,
			-- Template settings
			templates = {
				folder = "templates",
				date_format = "%Y-%m-%d-%a",
				time_format = "%H:%M",
				substitutions = {},
			},
			-- Optional, boolean or a function that takes a filename and returns a boolean.
			-- `true` indicates that you don't want obsidian.nvim to manage frontmatter.
			disable_frontmatter = false,
		},
	},
}