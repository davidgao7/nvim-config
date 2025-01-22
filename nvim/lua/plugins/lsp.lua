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

    -- {
    --     "zbirenbaum/copilot.lua",
    --     cmd = "Copilot",
    --     event = "InsertEnter",
    --     config = function()
    --         require('copilot').setup({
    --             panel = {
    --                 enabled = true,
    --                 auto_refresh = false,
    --                 keymap = {
    --                     jump_prev = "<C-p>",
    --                     jump_next = "<C-n>",
    --                     accept = "<C-y>",
    --                     refresh = "gr",
    --                     open = "K"
    --                 },
    --                 layout = {
    --                     position = "bottom", -- | top | left | right | horizontal | vertical
    --                     ratio = 0.4
    --                 },
    --             },
    --             suggestion = {
    --                 enabled = true,
    --                 auto_trigger = false,
    --                 hide_during_completion = true,
    --                 debounce = 75,
    --                 keymap = {
    --                     accept = "<M-l>",
    --                     accept_word = false,
    --                     accept_line = false,
    --                     next = "<M-]>",
    --                     prev = "<M-[>",
    --                     dismiss = "<C-]>",
    --                 },
    --             },
    --             filetypes = {
    --                 yaml = true,
    --                 markdown = true,
    --                 help = true,
    --                 gitcommit = true,
    --                 gitrebase = true,
    --                 hgcommit = true,
    --                 svn = true,
    --                 cvs = true,
    --                 ["."] = true,
    --             },
    --             copilot_node_command = 'node', -- Node.js version must be > 18.x
    --             server_opts_overrides = {},
    --         })
    --     end,
    -- },

    {
        'saghen/blink.cmp',
        -- In case there are breaking changes and you want to go back to the last
        -- working release
        -- https://github.com/Saghen/blink.cmp/releases
        version = "*",
        dependencies = {
            "moyiz/blink-emoji.nvim",
            "Kaiser-Yang/blink-cmp-dictionary",
            -- "giuxtaposition/blink-cmp-copilot"
        },

        opts = {
            keymap = { preset = 'default' }, -- fk it enter will only do new line, it's going to do one thing and doing good
            -- Use a preset for snippets, check the snippets documentation for more information
            completion = {
                menu = {
                    enabled = true,
                    min_width = 15,
                    max_height = 10,
                    border = 'none',
                    winblend = 0,
                    winhighlight =
                    'Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None',
                    -- Keep the cursor X lines away from the top/bottom of the window
                    scrolloff = 2,
                    -- Note that the gutter will be disabled when border ~= 'none'
                    scrollbar = true,
                    -- Which directions to show the window,
                    -- falling back to the next direction when there's not enough space
                    direction_priority = { 's', 'n' },

                    -- Whether to automatically show the window when new completion items are available
                    auto_show = true,

                    -- Screen coordinates of the command line
                    cmdline_position = function()
                        if vim.g.ui_cmdline_pos ~= nil then
                            local pos = vim.g.ui_cmdline_pos -- (1, 0)-indexed
                            return { pos[1] - 1, pos[2] }
                        end
                        local height = (vim.o.cmdheight == 0) and 1 or vim.o.cmdheight
                        return { vim.o.lines - height, 0 }
                    end,
                    draw = {
                        align_to = 'label', -- or 'none' to disable, or 'cursor' to align to the cursor
                        -- Left and right padding, optionally { left, right } for different padding on each side
                        padding = 1,
                        -- Gap between columns
                        gap = 1,
                        -- Use treesitter to highlight the label text for the given list of sources
                        treesitter = { 'lsp' },
                        columns = {
                            { "kind_icon" },                                -- Displays the icon representing the kind of completion
                            { "label",      "label_description", gap = 1 }, -- Shows the completion text and its description
                            { "source_name" }                               -- Adds the source name to the menu
                        },
                        components = {
                            kind_icon = {
                                ellipsis = false,
                                text = function(ctx) return ctx.kind_icon .. ctx.icon_gap end,
                                highlight = function(ctx)
                                    return require('blink.cmp.completion.windows.render.tailwind').get_hl(ctx) or
                                        'BlinkCmpKind' .. ctx.kind
                                end,
                            },

                            kind = {
                                ellipsis = false,
                                width = { fill = true },
                                text = function(ctx) return ctx.kind end,
                                highlight = function(ctx)
                                    return require('blink.cmp.completion.windows.render.tailwind').get_hl(ctx) or
                                        'BlinkCmpKind' .. ctx.kind
                                end,
                            },

                            label = {
                                width = { fill = true, max = 60 },
                                text = function(ctx) return ctx.label .. ctx.label_detail end,
                                highlight = function(ctx)
                                    -- label and label details
                                    local highlights = {
                                        { 0, #ctx.label, group = ctx.deprecated and 'BlinkCmpLabelDeprecated' or 'BlinkCmpLabel' },
                                    }
                                    if ctx.label_detail then
                                        table.insert(highlights,
                                            { #ctx.label, #ctx.label + #ctx.label_detail, group = 'BlinkCmpLabelDetail' })
                                    end

                                    -- characters matched on the label by the fuzzy matcher
                                    for _, idx in ipairs(ctx.label_matched_indices) do
                                        table.insert(highlights, { idx, idx + 1, group = 'BlinkCmpLabelMatch' })
                                    end

                                    return highlights
                                end,
                            },

                            label_description = {
                                width = { max = 30 },
                                text = function(ctx) return ctx.label_description end,
                                highlight = 'BlinkCmpLabelDescription',
                            },

                            source_name = {
                                width = { max = 30 },
                                text = function(ctx) return ctx.source_name end,
                                highlight = 'BlinkCmpSource',
                            },
                        },
                    },
                },
                keyword = {
                    range = "prefix", -- fuzzy match on the text before the cursor
                },
                trigger = {
                    -- When true, will prefetch the completion items when entering insert mode
                    prefetch_on_insert = false,

                    -- When false, will not show the completion window automatically when in a snippet
                    show_in_snippet = true,

                    -- When true, will show the completion window after typing any of alphanumerics, `-` or `_`
                    show_on_keyword = true,

                    -- When true, will show the completion window after typing a trigger character
                    show_on_trigger_character = true,

                    -- LSPs can indicate when to show the completion window via trigger characters
                    -- however, some LSPs (i.e. tsserver) return characters that would essentially
                    -- always show the window. We block these by default.
                    show_on_blocked_trigger_characters = function()
                        if vim.api.nvim_get_mode().mode == 'c' then return {} end

                        -- you can also block per filetype, for example:
                        -- if vim.bo.filetype == 'markdown' then
                        --   return { ' ', '\n', '\t', '.', '/', '(', '[' }
                        -- end

                        return { ' ', '\n', '\t' }
                    end,

                    -- When both this and show_on_trigger_character are true, will show the completion window
                    -- when the cursor comes after a trigger character after accepting an item
                    show_on_accept_on_trigger_character = true,

                    -- When both this and show_on_trigger_character are true, will show the completion window
                    -- when the cursor comes after a trigger character when entering insert mode
                    show_on_insert_on_trigger_character = true,

                    -- List of trigger characters (on top of `show_on_blocked_trigger_characters`) that won't trigger
                    -- the completion window when the cursor comes after a trigger character when
                    -- entering insert mode/accepting an item
                    show_on_x_blocked_trigger_characters = { "'", '"', '(' },
                    -- or a function, similar to show_on_blocked_trigger_character
                },
                list = {
                    -- Maximum number of items to display
                    max_items = 200,

                    selection = {
                        -- When `true`, will automatically select the first item in the completion list
                        preselect = true,
                        -- preselect = function(ctx) return ctx.mode ~= 'cmdline' end,

                        -- When `true`, inserts the completion item automatically when selecting it
                        -- You may want to bind a key to the `cancel` command (default <C-e>) when using this option,
                        -- which will both undo the selection and hide the completion menu
                        auto_insert = true,
                        -- auto_insert = function(ctx) return ctx.mode ~= 'cmdline' end
                    },

                    cycle = {
                        -- When `true`, calling `select_next` at the *bottom* of the completion list
                        -- will select the *first* completion item.
                        from_bottom = true,
                        -- When `true`, calling `select_prev` at the *top* of the completion list
                        -- will select the *last* completion item.
                        from_top = true,
                    },
                },
                accept = {
                    -- Create an undo point when accepting a completion item
                    create_undo_point = true,
                    -- Experimental auto-brackets support
                    auto_brackets = {
                        -- Whether to auto-insert brackets for functions
                        enabled = true,
                        -- Default brackets to use for unknown languages
                        default_brackets = { '(', ')' },
                        -- Overrides the default blocked filetypes
                        override_brackets_for_filetypes = {},
                        -- Synchronously use the kind of the item to determine if brackets should be added
                        kind_resolution = {
                            enabled = true,
                            blocked_filetypes = { 'typescriptreact', 'javascriptreact', 'vue' },
                        },
                        -- Asynchronously use semantic token to determine if brackets should be added
                        semantic_token_resolution = {
                            enabled = true,
                            blocked_filetypes = { 'java' },
                            -- How long to wait for semantic tokens to return before assuming no brackets should be added
                            timeout_ms = 400,
                        },
                    },
                },
                documentation = {
                    -- Controls whether the documentation window will automatically show when selecting a completion item
                    auto_show = false,
                    -- Delay before showing the documentation window
                    auto_show_delay_ms = 500,
                    -- Delay before updating the documentation window when selecting a new item,
                    -- while an existing item is still visible
                    update_delay_ms = 50,
                    -- Whether to use treesitter highlighting, disable if you run into performance issues
                    treesitter_highlighting = true,
                    window = {
                        min_width = 10,
                        max_width = 80,
                        max_height = 20,
                        border = 'padded',
                        winblend = 0,
                        winhighlight = 'Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc',
                        -- Note that the gutter will be disabled when border ~= 'none'
                        scrollbar = true,
                        -- Which directions to show the documentation window,
                        -- for each of the possible menu window directions,
                        -- falling back to the next direction when there's not enough space
                        direction_priority = {
                            menu_north = { 'e', 'w', 'n', 's' },
                            menu_south = { 'e', 'w', 's', 'n' },
                        },
                    },
                },
                ghost_text = { enabled = false, },
            },
            sources = {
                default = { "lsp", "path", "snippets", "buffer", "dadbod", "emoji", "dictionary", "lazydev",
                    -- "copilot"
                },
                providers = {
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        -- make lazydev completions top priority (see `:h blink.cmp`)
                        score_offset = 100,
                    },
                    lsp = {
                        name = "LSP",
                        module = "blink.cmp.sources.lsp",
                        fallbacks = { "buffer" },
                        transform_items = function(_, items)
                            for _, item in ipairs(items) do
                                if item.kind == require('blink.cmp.types').CompletionItemKind.Snippet then
                                    item.score_offset = item.score_offset - 3
                                end
                            end

                            return vim.tbl_filter(
                                function(item) return item.kind ~= require('blink.cmp.types').CompletionItemKind.Text end,
                                items
                            )
                        end,
                        -- When linking markdown notes, I would get snippets and text in the
                        -- suggestions, I want those to show only if there are no LSP
                        -- suggestions
                        -- Disabling fallbacks as my snippets wouldn't show up
                        score_offset = 90, -- the higher the number, the higher the priority
                    },
                    path = {
                        name = "Path",
                        module = "blink.cmp.sources.path",
                        score_offset = 25,
                        -- When typing a path, I would get snippets and text in the
                        -- suggestions, I want those to show only if there are no path
                        -- suggestions
                        opts = {
                            trailing_slash = false,
                            label_trailing_slash = true,
                            get_cwd = function(context)
                                return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
                            end,
                            show_hidden_files_by_default = true,
                        },
                    },
                    snippets = {
                        name = "snippets",
                        module = "blink.cmp.sources.snippets",
                    },
                    buffer = {
                        name = "Buffer",
                        module = "blink.cmp.sources.buffer",
                        opts = {
                            -- default to all visible buffers
                            get_bufnrs = function()
                                return vim
                                    .iter(vim.api.nvim_list_wins())
                                    :map(function(win) return vim.api.nvim_win_get_buf(win) end)
                                    :filter(function(buf) return vim.bo[buf].buftype ~= 'nofile' end)
                                    :totable()
                            end,
                        },
                    },
                    dadbod = {
                        name = "Dadbod",
                        module = "vim_dadbod_completion.blink",
                        score_offset = 85, -- the higher the number, the higher the priority
                    },
                    -- https://github.com/moyiz/blink-emoji.nvim
                    -- how to trigger: type :
                    emoji = {
                        module = "blink-emoji",
                        name = "Emoji",
                        score_offset = 15,        -- the higher the number, the higher the priority
                        opts = { insert = true }, -- Insert emoji (default) or complete its name
                    },
                    -- https://github.com/Kaiser-Yang/blink-cmp-dictionary
                    -- In macOS to get started with a dictionary:
                    -- cp /usr/share/dict/words ~/github/dotfiles-latest/dictionaries
                    dictionary = {
                        module = "blink-cmp-dictionary",
                        name = "Dict",
                        score_offset = 20, -- the higher the number, the higher the priority
                        enabled = true,
                        max_items = 8,
                        min_keyword_length = 3,
                        opts = {
                            get_command = {
                                "rg", -- make sure this command is available in your system
                                "--color=never",
                                "--no-line-number",
                                "--no-messages",
                                "--no-filename",
                                "--ignore-case",
                                "--",
                                "${prefix}",                            -- this will be replaced by the result of 'get_prefix' function
                                vim.fn.expand("/usr/share/dict/words"), -- where you dictionary is
                            },
                            documentation = {
                                enable = true, -- enable documentation to show the definition of the word
                                get_command = {
                                    -- For the word definitions feature
                                    -- make sure "wn" is available in your system
                                    -- brew install wordnet
                                    "wn",
                                    "${word}", -- this will be replaced by the word to search
                                    "-over",
                                },
                            },
                        },
                    },
                    -- ai completion lowest priority
                    -- copilot = {
                    --     name = "copilot",
                    --     module = "blink-cmp-copilot",
                    --     score_offset = 10,
                    --     async = true,
                    --     transform_items = function(_, items)
                    --         local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
                    --         local kind_idx = #CompletionItemKind + 1
                    --         CompletionItemKind[kind_idx] = "Copilot"
                    --         for _, item in ipairs(items) do
                    --             item.kind = kind_idx
                    --         end
                    --         return items
                    --     end,
                    -- }
                },
                cmdline = function()
                    local type = vim.fn.getcmdtype()
                    if type == "/" or type == "?" then
                        return { "buffer" }
                    end
                    if type == ":" or type == '@' then
                        return { "cmdline" }
                    end
                    return {}
                end,

                -- Function to use when transforming the items before they're returned for all providers
                -- The default will lower the score for snippets to sort them lower in the list
                transform_items = function(_, items) return items end,

                -- Minimum number of characters in the keyword to trigger all providers
                -- May also be `function(ctx: blink.cmp.Context): number`
                min_keyword_length = 0,
            },
            appearance = {
                highlight_ns = vim.api.nvim_create_namespace('blink_cmp'),
                -- Sets the fallback highlight groups to nvim-cmp's highlight groups
                -- Useful for when your theme doesn't support blink.cmp
                -- Will be removed in a future release
                use_nvim_cmp_as_default = false,
                -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = 'mono',
                kind_icons = {
                    Text = '󰉿',
                    Method = '󰊕',
                    Function = '󰊕',
                    Constructor = '󰒓',

                    Field = '󰜢',
                    Variable = '󰆦',
                    Property = '󰖷',

                    Class = '󱡠',
                    Interface = '󱡠',
                    Struct = '󱡠',
                    Module = '󰅩',

                    Unit = '󰪚',
                    Value = '󰦨',
                    Enum = '󰦨',
                    EnumMember = '󰦨',

                    Keyword = '󰻾',
                    Constant = '󰏿',

                    Snippet = '󱄽',
                    Color = '󰏘',
                    File = '󰈔',
                    Reference = '󰬲',
                    Folder = '󰉋',
                    Event = '󱐋',
                    Operator = '󰪚',
                    TypeParameter = '󰬛',
                },
            },
        },
    },

    {
        'neovim/nvim-lspconfig',
        dependencies = {
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },
            { "jay-babu/mason-nvim-dap.nvim" },
            { "mfussenegger/nvim-dap" },
            { "mfussenegger/nvim-dap-python" },
            { "leoluz/nvim-dap-go" },
            { "saghen/blink.cmp" },
            {
                'folke/lazydev.nvim',
                ft = 'lua',
                opts = {
                    library = {
                        { path = "${3rd}/luv/library", words = { "vim%.uv" } }, -- Luv support for Lua files
                    },
                }
            },
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
            local lspconfig = require('lspconfig')
            for server, config in pairs(opts.servers) do
                -- passing config.capabilities to blink.cmp merges with the capabilities in your
                -- `opts[server].capabilities, if you've defined it
                config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
                lspconfig[server].setup(config)
            end

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

    -- copilot plugin, make sure copilot.lua is loaded after completion plugin (blink)
    -- {
    --     "zbirenbaum/copilot.lua",
    --     dependencies = { 'saghen/blink.cmp' },
    --     build = ":Copilot auth",
    --     opts = {
    --         suggestion = {
    --             enabled = false, -- disable virtual text suggestions
    --             auto_trigger = true,
    --             keymap = {
    --                 accept = false, -- handled by nvim-cmp / blink.cmp
    --                 next = "<C-n>",
    --                 prev = "<C-p>",
    --             },
    --         },
    --         panel = { enabled = false },
    --         filetypes = nil,
    --     },
    -- },

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
        ft = { "c", "cpp" },
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
            -- vim.keymap.set(
            --     "n",
            --     "K",
            --     function()
            --         vim.cmd.RustLsp({ "hover", "actions" })
            --     end,
            --     { silent = true, buffer = bufnr }
            -- )
        end
    },

}
