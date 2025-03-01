return {
    -- nvim v0.8.0
    "kdheepak/lazygit.nvim",
    lazy = false,
    cmd = {
        "LazyGit",
        "LazyGitConfig",
        "LazyGitCurrentFile",
        "LazyGitFilter",
        "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim",
    },
    config = function()
        require("telescope").load_extension("lazygit")
        vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
        vim.keymap.set("n", "<leader>gt", "<cmd>LazyGitConfig<cr>", { desc = "LazyGitConfig" })
        vim.keymap.set("n", "<leader>gf", "<cmd>LazyGitCurrentFile<cr>", { desc = "LazyGitCurrentFile" })
        vim.keymap.set("n", "<leader>gv", "<cmd>LazyGitFilterCurrentFile<cr>", { desc = "LazyGitFilterCurrentFile" })
    end,
}
