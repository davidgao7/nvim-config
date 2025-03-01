return {
    {
        "danymat/neogen",
        config = true,
        -- Uncomment next line if you want to follow only stable versions
        version = "*",
        opts = {
            noremap = true,
            silent = true,
        },
        keys = {
            {
                "<leader>nf",
                function()
                    require("neogen").generate({ type = "func" })
                end,
                desc = "Generate function annotation",
            },
            {
                "<leader>nc",
                function()
                    require("neogen").generate({ type = "class" })
                end,
                desc = "Generate class annotation",
            },
            {
                "<leader>nt",
                function()
                    require("neogen").generate({ type = "type" })
                end,
                desc = "Generate type annotation",
            },
            {
                "<leader>nF",
                function()
                    require("neogen").generate({ type = "file" })
                end,
                desc = "Generate file annotation",
            },

        }
    }
}
