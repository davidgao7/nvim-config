local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

return {
  {
    -- setup debug config
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    opts = {
      handlers = {},
      ensure_installed = {
        "codelldb",
      },
    },
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "clangd",
        "clang-format",
        "codelldb",
      },
    },
  },

  {
    "jose-elias-alvarez/null-ls.nvim",
    event = "VeryLazy",
    opts = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        on_init = function(new_client, _)
          new_client.offset_encoding = "utf-32"
        end,
      })
      local opts = {
        sources = {
          null_ls.builtins.formatting.clang_format,
        },
        on_attach = function(client, bufnr)
          -- check if the client supports the formatting method
          if client.supports_method("textDocument/formatting") then
            -- clear the autocmds for the buffer
            vim.api.nvim_clear_autocmds({
              group = augroup,
              buffer = bufnr,
            })
            -- initialize the autocmds wheneve we save the buffer
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = augroup,
              buffer = bufnr,
              -- call lsp format command on save
              callback = function()
                vim.lsp.buf.format({
                  bufnr = bufnr,
                })
              end,
            })
          end
        end,
      }
      return opts
    end,
  },

  -- clangd extensions
  {
    "p00f/clangd_extensions.nvim",
    lazy = true,
    config = function() end,
    opts = {
      inlay_hints = {
        inline = false,
      },
      ast = {
        --These require codicons (https://github.com/microsoft/vscode-codicons)
        role_icons = {
          type = "",
          declaration = "",
          expression = "",
          specifier = "",
          statement = "",
          ["template argument"] = "",
        },
        kind_icons = {
          Compound = "",
          Recovery = "",
          TranslationUnit = "",
          PackExpansion = "",
          TemplateTypeParm = "",
          TemplateTemplateParm = "",
          TemplateParamObject = "",
        },
      },
    },
  },

  -- lspconfig for clangd
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Ensure mason installs the server
        clangd = {
          keys = {
            { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
          },
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern(
              "Makefile",
              "configure.ac",
              "configure.in",
              "config.h.in",
              "meson.build",
              "meson_options.txt",
              "build.ninja"
            )(fname) or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(
              fname
            ) or require("lspconfig.util").find_git_ancestor(fname)
          end,
          capabilities = {
            offsetEncoding = { "utf-16" },
          },
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
          },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
        },
      },
      setup = {
        clangd = function(_, opts)
          local clangd_ext_opts = LazyVim.opts("clangd_extensions.nvim")
          require("clangd_extensions").setup(vim.tbl_deep_extend("force", clangd_ext_opts or {}, { server = opts }))
          return false
        end,
      },
    },
  },

  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "cpp",
      },
    },
  },

  -- nvim-cmp
  {
    "nvim-cmp",
    opts = function(_, opts)
      table.insert(opts.sorting.comparators, 1, require("clangd_extensions.cmp_scores"))
    end,
  },
  
  -- snippets
  {
    "rafamadriz/friendly-snippets",
  },

  -- cpp man from cplusplus.com and cppreference.com without ever leaving neovim
  {
    "madskjeldgaard/cppman.nvim",
    dependencies = {
      { "MunifTanjim/nui.nvim" },
    },
    config = function()
      local cppman = require("cppman")
      cppman.setup()

      -- -- Make a keymap to open the word under cursor in CPPman
      -- vim.keymap.set("n", "<leader>cp", function()
      --   cppman.open_cppman_for(vim.fn.expand("<cword>"))
      -- end)
      --
      -- -- Open search box
      -- vim.keymap.set("n", "<leader>cc", function()
      --   cppman.input()
      -- end)
    end,
    keys = {
      {
        "<leader>cp",
        "<cmd>lua require('cppman').open_cppman_for(vim.fn.expand('<cword>'))<cr>",
        desc = "Open cppman for word under cursor",
      },
      { "<leader>cb", "<cmd>lua require('cppman').input()<cr>", desc = "Open cppman search box" },
    },
  },

}
