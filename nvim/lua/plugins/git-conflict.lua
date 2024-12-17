return {
    {
        "rhysd/conflict-marker.vim",
        event = "VeryLazy",
        lazy = false,
        config = function()
            -- disable the default highlight group
            vim.g.conflict_marker_highlight_group = ""

            -- Include text after begin and end markers
            vim.g.conflict_marker_begin = "^<<<<<<<\\+ .*$"
            vim.g.conflict_marker_common_ancestors = "^|||||||\\+ .*$"
            vim.g.conflict_marker_end = "^>>>>>>>\\+ .*$"

            -- Define highlights
            vim.api.nvim_set_hl(0, "ConflictMarkerBegin", { background = "#2f7366" })
            vim.api.nvim_set_hl(0, "ConflictMarkerOurs", { background = "#2e5049" })
            vim.api.nvim_set_hl(0, "ConflictMarkerTheirs", { background = "#344f69" })
            vim.api.nvim_set_hl(0, "ConflictMarkerEnd", { background = "#2f628e" })
            vim.api.nvim_set_hl(0, "ConflictMarkerCommonAncestorsHunk", { background = "#754a81" })
        end,
        keys = {
            { "<leader>gdd", "<cmd>ConflictMarkerNext<cr>", desc = "next conflict" },
            { "<leader>gdD", "<cmd>ConflictMarkerPrev<cr>", desc = "prev conflict" },
        },
    },
    {
        "folke/which-key.nvim",
        opts = {
            defaults = {
                ["<leader>gd"] = { name = "git conflict+" },
            },
        },
    },
}
