return {
    {
        "folke/snacks.nvim",
        opts = {
            image = {
                -- your image configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
                doc = {
                    -- render the image in a floating window
                    -- only used if `opts.inline` is disabled
                    inline = false, -- render the image inline in the buffer
                    float = true,
                    max_width = 80,
                    max_height = 40
                }
            },
        }
    }
}
