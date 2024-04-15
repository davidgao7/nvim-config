return {
  {
    "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>fs",
        -- grep file content to find files
        function()
          require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") })
        end,
        desc = "project content search regex",
      },
      {
        "<leader>fv",
        function()
          require("telescope.builtin").help_tags()
        end,
        desc = "find all vim packages help",
      },
      {
        "<leader>fp",
        function()
          require("telescope.builtin").live_grep()
        end,
        desc = "project content live grep",
      },
      {
        "<leader>f$",
        function()
          require("telescope.builtin").registers()
        end,
        desc = "search vim registers, <cr> to paste",
      },
      {
        "<leader>fz",
        function()
          require("telescope.builtin").current_buffer_fuzzy_find()
        end,
        desc = "search current buffer",
      },
    },
  },
}
