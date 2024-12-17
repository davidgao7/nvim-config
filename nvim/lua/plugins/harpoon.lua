return {
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            require("harpoon"):setup()
        end,
        keys = {
            {
                "<leader>a",
                function()
                    require("harpoon"):list():add()
                end,
                desc = "harpoon append file",
            },
            {
                "<leader>A",
                function()
                    local harpoon = require("harpoon")
                    harpoon.ui:toggle_quick_menu(harpoon:list())
                end,
                desc = "harpoon quick menu",
            },
            {
                "<leader>1",
                function()
                    require("harpoon"):list():select(1)
                end,
                desc = "harpoon to file 1",
            },
            {
                "<leader>2",
                function()
                    require("harpoon"):list():select(2)
                end,
                desc = "harpoon to file 2",
            },
            {
                "<leader>3",
                function()
                    require("harpoon"):list():select(3)
                end,
                desc = "harpoon to file 3",
            },
            {
                "<leader>4",
                function()
                    require("harpoon"):list():select(4)
                end,
                desc = "harpoon to file 4",
            },
            {
                "<leader>5",
                function()
                    require("harpoon"):list():select(5)
                end,
                desc = "harpoon to file 5",
            },
            {
                "<leader>n",
                function()
                    local harpoon = require("harpoon")
                    harpoon:list():next({ ui_nav_wrap = true }) -- enable cycling through list
                end,
                desc = "harpoon to next file",
            },
            {
                "<leader>m",
                function()
                    local harpoon = require("harpoon")
                    harpoon:list():next({ ui_nav_wrap = true }) -- enable cycling through list
                end,
                desc = "harpoon to previous file",
            },
        },
    },
}
