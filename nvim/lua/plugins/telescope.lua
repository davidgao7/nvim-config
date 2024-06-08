return {
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>r"] = { name = "rename+" },
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    event = "VeryLazy",
    config = function()
      -- local actions = require("telescope.actions")
      require("telescope").setup({
        -- Default configuration for telescope goes here:
        -- config_key = value,
        -- defaults = {
        --   mappings = {
        --     i = {
        --       ["C-f"] = actions.preview_scrolling_up(5),
        --       ["C-k"] = actions.preview_scrolling_right(5),
        --       ["<C-f>"] = actions.results_scrolling_left(5),
        --       ["<C-k>"] = actions.results_scrolling_right(5),
        --     },
        --   },
        -- },
      })
      -- Enable Telescope extensions if they are installed
      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")
    end,
    keys = {
      {
        "<leader>gI",
        function()
          require("telescope.builtin").lsp_implementations()
        end,
        desc = "goto implementation",
      },
      {
        "<leader>gr",
        function()
          require("telescope.builtin").lsp_references()
        end,
        desc = "goto references",
      },
      {
        "<leader>D",
        function()
          require("telescope.builtin").lsp_type_definitions()
        end,
        desc = "goto word type definition",
      },
      {
        "<leader>fa",
        function()
          require("telescope.builtin").lsp_document_symbols()
        end,
        desc = "fz find symbols current buffer",
      },
      {
        "<leader>fw",
        function()
          require("telescope.builtin").lsp_dynamic_workspace_symbols()
        end,
        desc = "workspace fzf symbols",
      },
      {
        "<leader>rn",
        function()
          vim.lsp.buf.rename()
        end,
        desc = "rename symbol accross project", -- if lsp server supports it
      },
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
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    keys = {
      {
        "<leader>fi",
        function()
          require("telescope").setup({
            defaults = {
              layout_config = {
                horizontal = {
                  preview_cutoff = 0,
                },
              },
            },
          })
          require("telescope").extensions.file_browser.file_browser()
        end,
        desc = "file browser",
      },
    },
  },
}
