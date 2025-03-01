return {
    -- sql plugins setup
    "kristijanhusak/vim-dadbod-ui", -- connect to a database

    dependencies = {
        { "tpope/vim-dadbod",                     lazy = true },                             -- for sql interaction
        { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true }, -- Optional
    },
    cmd = {
        "DBUI",
        "DBUIToggle",
        "DBUIAddConnection",
        "DBUIFindBuffer",
    },
    init = function()
        -- Your DBUI configuration
        vim.g.db_ui_use_nerd_fonts = 1
    end,
}
