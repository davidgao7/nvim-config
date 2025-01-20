return {
    "sindrets/diffview.nvim",
    cmd = {
        "DiffviewOpen",
        "DiffviewFileHistory",
        "DiffviewClose",
        "DiffviewToggleFiles",
        "DiffviewFocusFiles",
        "DiffviewRefresh"
    },
    keys = {
        { "<leader>dvb", "<cmd>DiffviewFileHistory<cr>",   desc = "file history (current branch)" },
        { "<leader>dvf", "<cmd>DiffviewFileHistory %<cr>", desc = "file history (current file)" }
    }
}
