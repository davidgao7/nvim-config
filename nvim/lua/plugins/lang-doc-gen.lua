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
                "<leader>o",
                desc = "Annotation+",
            },
            {
                "<leader>of",
                function()
                    require("neogen").generate({ type = "func" })
                end,
                desc = "Generate function annotation",
            },
            {
                "<leader>oc",
                function()
                    require("neogen").generate({ type = "class" })
                end,
                desc = "Generate class annotation",
            },
            {
                "<leader>ot",
                function()
                    require("neogen").generate({ type = "type" })
                end,
                desc = "Generate type annotation",
            },
            {
                "<leader>oF",
                function()
                    require("neogen").generate({ type = "file" })
                end,
                desc = "Generate file annotation",
            },

        }
    }
}
