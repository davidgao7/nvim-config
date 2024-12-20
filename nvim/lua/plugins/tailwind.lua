-- tailwindcss config
local tw = {
    default_config = {
        filetypes = { "html", "css", "javascript", "typescript", "vue", "svelte", "php", "markdown", "htmldjango" },
    }
}

local ts_ops = {
    highlight = { enable = true },
    indent = { enable = true },
    ensure_installed = {
        "bash",
        "c",
        "diff",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "jsonc",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "printf",
        "python",
        "query",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "css",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
        },
    },
    textobjects = {
        move = {
            enable = true,
            goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
            goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
            goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
            goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
        },
    },
}

return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                tailwindcss = {
                    -- exclude a filetype from the default_config
                    filetypes_exclude = { "markdown" },
                    -- add additional filetypes to the default_config
                    filetypes_include = {},
                    -- to fully override the default_config, change the below
                    -- filetypes = {}
                },
            },
            setup = {
                tailwindcss = function(_, opts)
                    opts.filetypes = opts.filetypes or {}

                    -- Add default filetypes
                    vim.list_extend(opts.filetypes, tw.default_config.filetypes)

                    -- Remove excluded filetypes
                    --- @param ft string
                    opts.filetypes = vim.tbl_filter(function(ft)
                        return not vim.tbl_contains(opts.filetypes_exclude or {}, ft)
                    end, opts.filetypes)

                    -- Additional settings for Phoenix projects
                    opts.settings = {
                        tailwindCSS = {
                            includeLanguages = {
                                elixir = "html-eex",
                                eelixir = "html-eex",
                                heex = "html-eex",
                            },
                        },
                    }

                    -- Add additional filetypes
                    vim.list_extend(opts.filetypes, opts.filetypes_include or {})
                end,
            },
        },
    },
    {
        "hrsh7th/nvim-cmp",
        optional = true,
        dependencies = {
            { "roobert/tailwindcss-colorizer-cmp.nvim", opts = {} },
        },
        opts = function(_, opts)
            -- original LazyVim kind icon formatter
            local format_kinds = opts.formatting.format
            opts.formatting.format = function(entry, item)
                format_kinds(entry, item) -- add icons
                return require("tailwindcss-colorizer-cmp").formatter(entry, item)
            end
        end,
    },

    -- display the color you mention
    {
        "echasnovski/mini.hipatterns",
        version = '*',
        event = "BufReadPre",
        opts = function()
            local hipatterns = require("mini.hipatterns")
            return {
                highlighters = {
                    hex_color = hipatterns.gen_highlighter.hex_color(),
                },
            }
        end,
    },

    -- install treesitter
    {
        "folke/which-key.nvim",
        opts = {
            spec = {
                { "<BS>",      desc = "Decrement Selection", mode = "x" },
                { "<c-space>", desc = "Increment Selection", mode = { "x", "n" } },
            },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter",
        version = false, -- last release is way too old and doesn't work on Windows
        build = ":TSUpdate",
        event = { "VeryLazy" },
        lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
        init = function(plugin)
            -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
            -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
            -- no longer trigger the **nvim-treesitter** module to be loaded in time.
            -- Luckily, the only things that those plugins need are the custom queries, which we make available
            -- during startup.
            require("lazy.core.loader").add_to_rtp(plugin)
            require("nvim-treesitter.query_predicates")
        end,
        cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
        keys = {
            { "<c-space>", desc = "Increment Selection" },
            { "<bs>",      desc = "Decrement Selection", mode = "x" },
        },
        opts_extend = { "ensure_installed" },
        ---@type TSConfig
        ---@diagnostic disable-next-line: missing-fields
        opts = ts_ops,
        ---@param opts TSConfig
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
    },
}
