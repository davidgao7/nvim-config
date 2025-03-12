return {
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
            bigfile = { enabled = false },
            dashboard = { enabled = false },
            indent = { enabled = true },
            input = { enabled = false },
            notifier = { enabled = false },
            quickfile = { enabled = false },
            scroll = { enabled = false },
            statuscolumn = { enabled = false },
            words = { enabled = false },
        },
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        opts = function()
            -- Define custom highlight groups for scope
            vim.api.nvim_set_hl(0, "IndentBlanklineScopeStart", { fg = "#483D8B", bold = true }) -- Change color
            vim.api.nvim_set_hl(0, "IndentBlanklineScopeEnd", { fg = "#483D8B", bold = true })   -- Change color

            Snacks = require("snacks")
            Snacks.toggle({
                name = "Indention Guides",
                get = function()
                    return require("ibl.config").get_config(0).enabled
                end,
                set = function(state)
                    require("ibl").setup_buffer(0, { enabled = state })
                end,
            }):map("<leader>ug")

            return {
                indent = {
                    char = "│",
                    tab_char = "│",
                },
                scope = {
                    show_start = true,
                    show_end = true,
                    highlight = {
                        "IndentBlanklineScopeStart",
                        "IndentBlanklineScopeEnd"
                    }
                },
                exclude = {
                    filetypes = {
                        "Trouble",
                        "alpha",
                        "dashboard",
                        "help",
                        "lazy",
                        "mason",
                        "neo-tree",
                        "notify",
                        "snacks_dashboard",
                        "snacks_notif",
                        "snacks_terminal",
                        "snacks_win",
                        "toggleterm",
                        "trouble",
                    },
                },
            }
        end,
        main = "ibl",
    } }
