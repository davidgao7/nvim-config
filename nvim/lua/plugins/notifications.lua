return {
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        opts = {},
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        config = function()
            require("notify").setup({
                background_colour = "#000000",
            })

            require("noice").setup({
                routes = {
                    {
                        filter = {
                            event = "notify",
                            find = "No information available",
                        },
                        opts = { skip = true },
                    },
                },
                lsp = {
                    override = {
                        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                        ["vim.lsp.util.stylize_markdown"] = true,
                    },
                },
                presets = {
                    bottom_search = true,
                    command_palette = true,
                    long_message_to_split = true,
                    inc_rename = true,
                    lsp_doc_border = false,
                },
                views = {
                    history = {
                        backend = "fzf_lua",
                    },
                },
            })

            -- currently <>Noice<> and <>Noice history<> don't work, not sure why...
            vim.keymap.set("n", "<leader>sh", "<cmd>messages<cr>", { desc = "Show notification history" })
        end,
    },
}
