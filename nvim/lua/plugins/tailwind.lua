return {
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

}
