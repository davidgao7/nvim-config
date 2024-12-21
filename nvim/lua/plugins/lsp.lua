local clangd_ext_opts = {
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
}

return {

    {
        'neovim/nvim-lspconfig',
        dependencies = {
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },
            { "jay-babu/mason-nvim-dap.nvim" },
            { "mfussenegger/nvim-dap" },
            { "mfussenegger/nvim-dap-python" },
            { "leoluz/nvim-dap-go" },
            {
                'folke/lazydev.nvim',
                ft = 'lua',
                opts = {
                    library = {
                        { path = "${3rd}/luv/library", words = { "vim%.uv" } }, -- Luv support for Lua files
                    },
                }
            },
            { 'saghen/blink.cmp' },
        },
        opts = {
            -- all lsp servers specifications goes here

            -- server specifications
            servers = {

                -- lua lsp server config
                lua_ls = {
                    settings = {
                        Lua = {
                            diagnostics = { globals = { 'vim' } },
                            workspace = { library = vim.api.nvim_get_runtime_file("", true) },
                            completion = {
                                callSnippet = 'Disable',
                                keywordSnippet = 'Disable',
                            },
                        },
                    },
                },

                -- python lsp server
                pyright = {
                    settings = {
                        python = {
                            analysis = {
                                typeCheckingMode = "basic",             -- "strict" is tooo strict
                                autoSearchPaths = true,                 -- use VenvSelect
                                useLibraryCodeForTypes = true,          -- use types from libraries
                                diagnosticSeverityOverrides = {
                                    reportUnknownVariableType = "none", -- Ignore "Unknown" variable type
                                    reportUnknownMemberType = "none",   -- Ignore "Unknown" member type
                                    reportMissingTypeStubs = "none",    -- Suppress missing type stub errors
                                },
                            },
                        }
                    }
                },

                -- cpp/c lsp
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
                            )(fname) or
                            require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(
                                fname
                            ) or
                            vim.fs.dirname(vim.fs.find('.git', { path = fname, upward = true })[1])
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

                -- tailwind
                tailwindcss = {
                    -- exclude a filetype from the default_config
                    filetypes_exclude = { "markdown" },
                    -- add additional filetypes to the default_config
                    filetypes_include = {},
                    -- to fully override the default_config, change the below
                    filetypes = { "html", "css", "javascript", "typescript", "vue", "svelte", "php", "htmldjango" },
                    settings = {
                        tailwindCSS = {
                            includeLanguages = {
                                elixir = "html-eex",
                                eelixir = "html-eex",
                                heex = "html-eex",
                            },
                        }
                    },
                },


                -- Go LSP settings
                gopls = {
                    settings = {
                        gopls = {
                            gofumpt = true,      -- Enforce gofumpt formatting
                            codelenses = {
                                generate = true, -- Enable code lens for generating methods
                                test = true,     -- Enable code lens for testing
                                tidy = true,     -- Enable code lens for 'go mod tidy'
                            },
                            hints = {
                                assignVariableTypes = true,    -- Show variable type hints
                                compositeLiteralFields = true, -- Show field names in composite literals
                                constantValues = true,         -- Show values of constants
                            },
                            analyses = {
                                fieldalignment = true,                       -- Check for optimal struct field alignment
                                nilness = true,                              -- Check for redundant or impossible nil comparisons
                                unusedparams = true,                         -- Check for unused parameters in functions
                                unusedwrite = true,                          -- Check for unused writes
                                useany = true,                               -- Check for usage of 'any' type
                            },
                            usePlaceholders = true,                          -- Use placeholders in completion
                            completeUnimported = true,                       -- Complete unimported packages
                            staticcheck = true,                              -- Enable static analysis checks
                            directoryFilters = { "-.git", "-node_modules" }, -- Exclude directories
                            semanticTokens = true,                           -- Enable semantic tokens for better syntax highlighting
                        },
                    },
                },

                -- java lsp settings
                jdtls = {
                    root_dir = function(fname)
                        return require("lspconfig.util").root_pattern("build.gradle", "pom.xml", ".git")(fname)
                    end,
                    cmd = { "jdtls" },
                    settings = {
                        java = {
                            home = os.getenv("JAVA_17_HOME") or os.getenv("JAVA_11_HOME") or os.getenv("JAVA_8_HOME"),
                            project = {
                                referencedLibraries = {
                                    "lib/**/*.jar",
                                    "build/libs/**/*.jar",
                                },
                            },
                            format = {
                                enabled = true,
                                settings = {
                                    profile = "GoogleStyle",
                                },
                            },
                        },
                    },
                },

                -- rust
                --[[
                --no need to setup rust-analyzer manually since installed `rustaceanvim`
                --]]
            },

            -- some particular setup steps
            setup = {

                -- tailwind
                tailwindcss = function(_, opts)
                    opts.filetypes = opts.filetypes or {}

                    -- Remove excluded filetypes
                    --- @param ft string
                    opts.filetypes = vim.tbl_filter(function(ft)
                        return not vim.tbl_contains(opts.filetypes_exclude or {}, ft)
                    end, opts.filetypes)

                    -- Additional settings for Phoenix projects
                    opts.settings = opts.settings

                    -- Add additional filetypes
                    vim.list_extend(opts.filetypes, opts.filetypes_include or {})
                end,

                -- clangd_extensions
                clangd = function(_, opts)
                    require("clangd_extensions").setup(vim.tbl_deep_extend("force", clangd_ext_opts or {},
                        { server = opts }))
                    return false
                end,
            },

            -- corresponding dap installations
            dap = {
                ensure_installed = {
                    "debugpy",
                    "delve",
                    "cppdbg",
                    "javadbg",
                    "codelldb",
                },

                adapters = {
                    python = {
                        type = 'executable',
                        command = 'python',
                        args = { '-m', 'debugpy.adapter' },
                    },
                    go = {
                        type = 'server',
                        port = '${port}',
                        executable = {
                            command = 'dlv',
                            args = { 'dap', '-l', '127.0.0.1:${port}' },
                        },
                    },
                    codelldb = {
                        type = "server",
                        port = "${port}",
                        executable = {
                            command = vim.fn.stdpath("data") .. "/mason/bin/codelldb", -- Auto-installed path
                            args = { "--port", "${port}" },
                        },
                    },
                    java = {
                        type = 'executable',
                        command = 'java',
                        args = { '-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=1044' },
                    },
                },

                configurations = {
                    python = {
                        {
                            type = 'python',
                            request = 'launch',
                            name = 'Launch file',
                            program = "${file}",
                            pythonPath = function()
                                local venv_selector = require("venv-selector")
                                local python_path = venv_selector.python()
                                if python_path then
                                    return python_path
                                else
                                    return vim.fn.exepath('python') -- Fallback to system python if no venv
                                end
                            end,

                        },
                    },
                    go = {
                        {
                            type = 'go',
                            name = 'Debug Package',
                            request = 'launch',
                            program = '${file}',
                        },
                    },
                    cpp = {
                        {
                            name = "Launch C++ File",
                            type = "codelldb",
                            request = "launch",
                            program = function()
                                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                            end,
                            cwd = "${workspaceFolder}",
                            stopOnEntry = false,
                        },
                    },
                    java = {
                        {
                            type = 'java',
                            name = 'Debug Main Class',
                            request = 'launch',
                            mainClass = '${file}'
                        }
                    },
                }
            },
        },

        config = function(_, opts)
            -- Ensure servers and DAP are initialized
            opts.servers = opts.servers or {}
            opts.dap = opts.dap or {}


            require('mason').setup()
            require('mason-lspconfig').setup({
                ensure_installed = vim.tbl_keys(opts.servers), -- Automatically install specified servers
                automatic_installation = true,                 -- Automatically install servers set up via lspconfig
            })

            -- automatically setup LSP servers
            require('mason-lspconfig').setup_handlers({
                -- The first entry (without a key) will be the default handler
                -- and will be called for each installed server that doesn't have
                -- a dedicated handler.
                function(server_name) -- default handler (optional)
                    local server_opts = opts.servers[server_name] or {}
                    -- vim.notify(server_name .. "  server setup complete!")
                    -- Merge blink.cmp capabilities
                    server_opts.capabilities = require('blink.cmp').get_lsp_capabilities({
                        textDocument = { completion = { completionItem = { snippetSupport = false } } },
                    })
                    -- Setup LSP server
                    -- apply lsp servers above in opts.servers[Language]
                    require('lspconfig')[server_name].setup(server_opts)
                    -- setup nvim-dap with mason
                end,
                -- Next, you can provide a dedicated handler for specific servers.
                -- For example, a handler override for the `rust_analyzer`:
                -- ["rust_analyzer"] = function ()
                --     require("rust-tools").setup {}
                -- end
            })

            -- set up mason dap
            require('mason-nvim-dap').setup({
                ensure_installed = opts.dap.ensure_installed, -- debug adapters to install
                automatic_installation = true
            })

            -- //////////// Language dap configuration /////////////////
            local dap = require('dap')
            dap.adapters = opts.dap.adapters
            dap.configurations = opts.dap.configurations

            vim.keymap.set("n", "<leader>cm", "<cmd>Mason<cr>", { desc = "mason" })
        end,
    },
    -- completion engine
    -- use the latest release, via version = '*', if you also use the latest release for blink.cmp
    { 'saghen/blink.compat', version = '*' },

    {
        'saghen/blink.cmp',
        version = 'v0.*',
        lazy = false, -- lazy loading handled internally
        dependencies = {
            -- add source
            { 'rafamadriz/friendly-snippets' },
        },
        --[[
        --Failed to run `config` for blink.cmp

...are/nvim/lazy/blink.cmp/lua/blink/cmp/config/sources.lua:132: attempt to index local 'provider' (a number value)

# stacktrace:
  - /blink.cmp/lua/blink/cmp/config/sources.lua:132 _in_ **validate_provider**
  - /blink.cmp/lua/blink/cmp/config/sources.lua:126 _in_ **validate**
  - /blink.cmp/lua/blink/cmp/config/init.lua:43 _in_ **validate**
  - /blink.cmp/lua/blink/cmp/config/init.lua:52 _in_ **merge_with**
  - /blink.cmp/lua/blink/cmp/init.lua:18 _in_ **setup**
  - .config/nvim/lua/config/lazy.lua:24
  - .config/nvim/init.lua:1

        --]]
        opts = {
            keymap = { preset = 'default' }, -- fk it enter will only do new line, it's going to do one thing and doing good
            sources = {
                -- Dynamically picking providers by treesitter node/filetype
                default = function(ctx)
                    local node = vim.treesitter.get_node()
                    if vim.bo.filetype == 'lua' then
                        return { 'lsp', 'path' }
                    elseif node and vim.tbl_contains({ 'comment', 'line_comment', 'block_comment' }, node:type()) then
                        return { 'buffer' }
                    else
                        return { 'lsp', 'path', 'snippets', 'buffer' }
                    end
                end,
                -- optionally disable cmdline completions
                -- cmdline = {}
                -- experimental signature help support
                -- signature = { enabled = true }
                providers = {
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        -- make lazydev completions top priority (see `:h blink.cmp`)
                        score_offset = 100,
                    },
                },
            },
        },
    },

    -- autopair
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({ check_ts = true })
        end,
    },

    -- todos,notes,etc in comments highlight
    {
        "folke/todo-comments.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim"
        },
        opts = {
            signs = false
        }
    },

    -- variable rename
    {
        "smjonas/inc-rename.nvim",
        config = function()
            require("inc_rename").setup({})
            vim.keymap.set("n", "<leader>rn", ":IncRename")
        end,
    },

    {
        -- python venv selector
        'linux-cultist/venv-selector.nvim',
        branch = "regexp",
        dependencies = {
            'neovim/nvim-lspconfig',
            'nvim-telescope/telescope.nvim',
            "mfussenegger/nvim-dap",
            'mfussenegger/nvim-dap-python',
            { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
        },
        lazy = false,
        config = function()
            require("venv-selector").setup({
                debug = true -- enables you to run the VenvSelectLog command to view debug logs
            })
        end,
        keys = {
            { '<leader>vs', '<cmd>VenvSelect<cr>' },
            { '<leader>vc', '<cmd>VenvSelectCached<cr>' },
        },
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
            vim.keymap.set("n", "<leader>cc", function() cppman.input() end, { desc = "open cpp search" })
            vim.keymap.set("n", "<leader>cp",
                "<cmd>lua require('cppman').open_cppman_for(vim.fn.expand('<cword>'))<cr>",
                { desc = "Open cppman for word under cursor" }
            )
        end,
    },
    -- clang
    {
        "p00f/clangd_extensions.nvim",
        lazy = true,
        config = function() end,
        opts = clangd_ext_opts,
    },

    -- rust
    {
        "mrcjkb/rustaceanvim",
        version = "^5", -- recommended
        -- [[
        -- It is suggested to pin to tagged releases if you would like to avoid breaking changes.
        -- ]]
        tag = "v5.19.2",
        lazy = false, -- this plugin is already lazy
        config = function()
            local bufnr = vim.api.nvim_get_current_buf()
            -- add some keymaps
            vim.keymap.set(
                "n", "<leader>ra",
                function()
                    vim.cmd.RustLsp('codeAction') -- supports rust-analyzer's grouping
                    -- vim.lsp.buf.codeAction() if you don't want grouping
                end,
                { silent = true, buffer = bufnr }
            )
            vim.keymap.set(
                "n",
                "K", -- Override Neovim's built-in hover keymap with rustaceanvim's hover actions
                function()
                    vim.cmd.RustLsp({ "hover", "actions" })
                end,
                { silent = true, buffer = bufnr }
            )
        end
    },

    -- lua
    {
        'saghen/blink.cmp',
        version = '*',
        -- !Important! Make sure you're using the latest release of LuaSnip
        -- `main` does not work at the moment
        dependencies = { 'L3MON4D3/LuaSnip', version = 'v2.*' },
        opts = {
            snippets = {
                expand = function(snippet) require('luasnip').lsp_expand(snippet) end,
                active = function(filter)
                    if filter and filter.direction then
                        return require('luasnip').jumpable(filter.direction)
                    end
                    return require('luasnip').in_snippet()
                end,
                jump = function(direction) require('luasnip').jump(direction) end,
            },
            sources = {
                default = { 'lsp', 'path', 'luasnip', 'buffer' },
            },
        }
    }


}
