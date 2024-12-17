return {
    "mbbill/undotree",
    lazy = false, -- needs to be explicitly set because of the keys property
    config = function()
        -- see all undotree layout options:
        -- https://github.com/mbbill/undotree/blob/master/plugin/undotree.vim#L27
        vim.g.undotree_WindowLayout = 4

        -- auto open diff window
        vim.g.undotree_DiffAutoOpen = 1

        -- tree node shape
        vim.g.undotree_TreeNodeShape = "*"

        -- tree vertical shape
        vim.g.undotree_TreeVertShape = "│"

        -- tree split shape
        vim.g.undotree_TreeSplitShape = "/"

        -- tree return shape
        vim.g.undotree_TreeReturnShape = "\\"

        -- tree diff command
        vim.g.undotree_DiffCommand = "diff"

        -- relative timestamp
        vim.g.undotree_RelativeTimestamp = 1

        -- highlight linked sytax type
        -- You may chose your favorite through ":hi" command
        vim.g.undotree_HighlightSyntaxAdd = "DiffAdd"

        vim.g.undotree_HighlightSyntaxChange = "DiffChange"

        vim.g.undotree_HighlightSyntaxDel = "DiffDelete"

        vim.g.undotree_HighlightChangedText = 1

        -- show help line
        vim.g.undotree_HelpLine = 1

        -- show cursorline
        vim.g.undotree_CursorLine = 1

        -- use relative timesstamp
        vim.g.undotree_RelativeTimestamp = 1
    end,
    -- https://github.com/mbbill/undotree/blob/master/doc/undotree.txt#L297-L302
    keys = {
        {
            "<leader>U",
            "<cmd>UndotreeToggle<CR>",
            desc = "undotree toggle",
        },
    },
}
