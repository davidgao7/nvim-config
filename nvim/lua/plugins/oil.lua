return {
    {
        "stevearc/oil.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("oil").setup({
                default_file_explorer = true,
                columns = {
                    "icon",
                    "permissions",
                    "size",
                    "mtime", -- last modified time
                },
                view_options = {
                    show_hidden = false, -- looks kinda messy
                },
                lsp_file_methods = {
                    -- Enable or disable LSP file operations
                    enabled = false,
                    -- Time to wait for LSP file operations to complete before skipping
                    timeout_ms = 1000,
                    -- Set to true to autosave buffers that are updated with LSP willRenameFiles
                    -- Set to "unmodified" to only save unmodified buffers
                    autosave_changes = false,
                },
            })
        end,
        keys = {
            -- vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" }),
            { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
        },
        --  <space>fo  hasn't used yet
    },
}
