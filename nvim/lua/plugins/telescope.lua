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

        -- view media files
        extensions = {
          media_files = {
            -- filetypes whitelist
            -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
            filetypes = { "png", "jpg", "gif", "mp4", "webm", "pdf" },
            find_cmd = "rg", -- find command (defaults to `fd`)
          },
        },
      })
      -- Enable Telescope extensions if they are installed
      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")
      pcall(require("telescope").load_extension, "media_files")
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
    "nvim-telescope/telescope-media-files.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/popup.nvim", "nvim-lua/plenary.nvim" },
    keys = {
      {
        "<leader>fd",
        function()
          require("telescope").extensions.media_files.media_files()
        end,
        desc = "copy media files path",
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
  {
    "aaronhallaert/advanced-git-search.nvim",
    dependencies = {
      --- See dependencies
      "nvim-telescope/telescope.nvim",
      -- to show diff splits and open commits in browser
      "tpope/vim-fugitive",
      -- to open commits in browser with fugitive
      "tpope/vim-rhubarb",
      -- optional: to replace the diff from fugitive with diffview.nvim
      -- (fugitive is still needed to open in browser)
      "sindrets/diffview.nvim",
    },
    cmd = { "AdvancedGitSearch" },
    config = function()
      -- optional: setup telescope before loading the extension
      require("telescope").setup({
        extensions = {
          -- advanced git search setup
          advanced_git_search = {
            -- Browse command to open commits in browser. Default fugitive GBrowse.
            -- {commit_hash} is the placeholder for the commit hash.
            browse_command = "GBrowse {commit_hash}",
            -- when {commit_hash} is not provided, the commit will be appended to the specified command seperated by a space
            -- browse_command = "GBrowse",
            -- => both will result in calling `:GBrowse commit`

            -- fugitive or diffview
            diff_plugin = "diffview",
            -- customize git in previewer
            -- e.g. flags such as { "--no-pager" }, or { "-c", "delta.side-by-side=false" }
            git_flags = {},
            -- customize git diff in previewer
            -- e.g. flags such as { "--raw" }
            git_diff_flags = {},
            -- Show builtin git pickers when executing "show_custom_functions" or :AdvancedGitSearch
            show_builtin_git_pickers = true,
            entry_default_author_or_date = "author", -- one of "author" or "date"
            keymaps = {
              -- following keymaps can be overridden
              toggle_date_author = "<C-w>", -- toggle between author and date showing on telescope
              open_commit_in_browser = "<C-o>",
              copy_commit_hash = "<C-y>",
              show_entire_commit = "<C-e>",
            },

            -- Telescope layout setup
            telescope_theme = {
              function_name_1 = {
                -- Theme options
              },
              function_name_2 = "dropdown",
              -- e.g. realistic example
              show_custom_functions = {
                layout_config = { width = 0.4, height = 0.4 },
              },
            },
          },
        },
      })

      require("telescope").load_extension("advanced_git_search")
    end,
    keys = {
      -- lets setup some features I might used often
      -- search current file commit history
      {
        "<leader>gS",
        "<cmd>Telescope advanced_git_search diff_commit_file<cr>",
        desc = "search current files commit history",
      },
    },
  },
}
