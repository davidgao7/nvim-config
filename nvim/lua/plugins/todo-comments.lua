return {
    {
        "folke/todo-comments.nvim",
        event = "BufEnter",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            highlight = {
                before = "",                     -- "fg" or "bg" or empty
                keyword = "wide",                -- "fg", "bg", "wide" or empty.
                after = "fg",                    -- "fg" or "bg" or empty
                pattern = [[.*<(KEYWORDS)\s*:]], -- Change if needed
                comments_only = true,            -- Only highlight inside comments
                max_line_len = 400,              -- Limit line length for parsing
                exclude = {},                    -- Exclude file types
            },
            colors = {
                error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
                warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
                info = { "DiagnosticInfo", "#2563EB" },
                hint = { "DiagnosticHint", "#10B981" },
                default = { "Identifier", "#7C3AED" },
                test = { "DiagnosticTest", "#FF00FF" }
            },
            keywords = {
                FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
                TODO = { icon = " ", color = "info", alt = { "TBD", "DO" } },
                HACK = { icon = " ", color = "warning" },
                WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
                PERF = { icon = " ", color = "default", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
                NOTE = { icon = " ", color = "hint", alt = { "INFO", "NOTE" } },
                TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } }
            }
        },
        config = function(opts)
            -- setup highlight group
            vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
                pattern = "*",
                callback = function()
                    vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#DC2626" }) -- Red
                    vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#FBBF24" })  -- Yellow
                    vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = "#2563EB" })  -- Blue
                    vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = "#10B981" })  -- Green
                    vim.api.nvim_set_hl(0, "Identifier", { fg = "#7C3AED" })      -- Purple
                    vim.api.nvim_set_hl(0, "DiagnosticTest", { fg = "#FF00FF" })  -- Magenta for "test" TODOs
                end
            })
            -- reload todo-comments on buffer enter
            vim.api.nvim_create_autocmd("BufEnter", {
                callback = function()
                    require("todo-comments").setup(opts)
                end
            })
        end,
        keys = {
            {
                "]t",
                function()
                    require("todo-comments").jump_next()
                end,
                { desc = "Next todo comment" }
            },
            {
                "[t",
                function()
                    require("todo-comments").jump_prev()
                end,
                { desc = "Previous todo comment" }
            },

        }
    }
}
