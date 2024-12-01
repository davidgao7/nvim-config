return {
	-- add blink.compat
	-- use the latest release, via version = '*', if you also use the latest release for blink.cmp
	{ "saghen/blink.compat", version = "*" },

	{
		"saghen/blink.cmp",
		version = "0.*",
		dependencies = {
			-- add source
			{ "dmitmel/cmp-digraphs" },
		},
		sources = {
			completion = {
				-- remember to enable your providers here
				enabled_providers = { "lsp", "path", "snippets", "buffer", "digraphs" },
			},

			providers = {
				-- create provider
				digraphs = {
					name = "digraphs", -- IMPORTANT: use the same name as you would for nvim-cmp
					module = "blink.compat.source",

					-- all blink.cmp source config options work as normal:
					score_offset = -3,

					opts = {
						-- this table is passed directly to the proxied completion source
						-- as the `option` field in nvim-cmp's source config

						-- this is an option from cmp-digraphs
						cache_digraphs_on_start = true,
						-- some plugins lazily register their completion source when nvim-cmp is
						-- loaded, so pretend that we are nvim-cmp, and that nvim-cmp is loaded.
						-- most plugins don't do this, so this option should rarely be needed
						-- NOTE: only has effect when using lazy.nvim plugin manager
						impersonate_nvim_cmp = true,

						-- print some debug information. Might be useful for troubleshooting
						debug = false,
					},
				},
			},
		},
	},
}
