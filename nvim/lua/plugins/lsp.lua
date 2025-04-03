local clangd_ext_opts = {
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
        'saghen/blink.cmp',
        -- In case there are breaking changes and you want to go back to the last
        -- working release
        -- https://github.com/Saghen/blink.cmp/releases
        -- version = "v0.10.0",
        version = "v1.1.1", -- if anything get fucked, back to v0.12.4
        build = "cargo build --release",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "ibhagwan/fzf-lua",
            "moyiz/blink-emoji.nvim",
            'Kaiser-Yang/blink-cmp-git',
            "echasnovski/mini.icons",
            "giuxtaposition/blink-cmp-copilot",
            {
                "echasnovski/mini.snippets",
                event = "InsertEnter",
                dependencies = {
                    "rafamadriz/friendly-snippets",
                    { "echasnovski/mini.extra", version = "*" },
                },
                opts = function(_, opts)
                    local snippets = require("mini.snippets")
                    local config_path = vim.fn.stdpath("config")
                    local custom_snip_dir = config_path .. "/snippets"

                    -- Optional: override select popup to prevent virtual text artifacts
                    local expand_select_override = function(snips, insert)
                        require("blink.cmp").cancel()
                        vim.schedule(function()
                            snippets.default_select(snips, insert)
                        end)
                    end

                    local snippet_sources = {}

                    -- Load global.json first (shared across languages)
                    local global_path = custom_snip_dir .. "/global.json"
                    if vim.fn.filereadable(global_path) == 1 then
                        table.insert(snippet_sources, snippets.gen_loader.from_file(global_path))
                    end

                    -- Automatically load language-specific snippets like `python.json`
                    for _, file in ipairs(vim.fn.readdir(custom_snip_dir)) do
                        if file:match("%.json$") and file ~= "global.json" then
                            table.insert(snippet_sources, snippets.gen_loader.from_file(custom_snip_dir .. "/" .. file))
                        end
                    end

                    -- Add built-in mini.extra snippets
                    local ok, extra = pcall(require, "mini.extra")
                    if ok and extra.gen_snippets then
                        table.insert(snippet_sources, extra.gen_snippets(extra.default_snippets))
                    end

                    -- Final opts
                    opts.snippets = snippet_sources
                    opts.expand = {
                        snippets = { snippets.gen_loader.from_lang() },
                        select = function(local_snips, insert)
                            local select = expand_select_override or snippets.default_select
                            select(local_snips, insert)
                        end,
                    }
                end,
            },
            { "garymjr/nvim-snippets" }, -- vscode style snippets, has builtin friendly-snippets
            {
                "saghen/blink.compat",
                optional = true, -- make optional so it's only enabled if any extras need it
                opts = {},
                version = "*",
            },
        },
        event = "InsertEnter",
        opts_extend = {
            "sources.completion.enabled_providers",
            "sources.compat",
            "sources.default",
        },
        optional = true,
        opts = {
            keymap = {
                preset = 'enter',
                ["<C-y>"] = { "select_and_accept" },
            },
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
                                text = function(ctx)
                                    local kind_icon, _, _ = require('mini.icons').get('lsp', ctx.kind)

                                    -- If mini.icons fails, manually return Copilot icon
                                    if ctx.kind == "Copilot" then
                                        return ""
                                    end
                                    return kind_icon
                                end,
                                highlight = function(ctx)
                                    local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                                    return hl
                                end,
                            },

                            kind = {
                                ellipsis = false,
                                width = { fill = true },
                                text = function(ctx) return ctx.kind end,
                                highlight = function(ctx)
                                    return require('blink.cmp.completion.windows.render.tailwind').get_hl(ctx) or
                                        'PmenuKind' .. ctx.kind
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
                        preselect = false,
                        -- preselect = function(ctx) return ctx.mode ~= 'cmdline' end,

                        -- When `true`, inserts the completion item automatically when selecting it
                        -- You may want to bind a key to the `cancel` command (default <C-e>) when using this option,
                        -- which will both undo the selection and hide the completion menu
                        auto_insert = false,
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
                    auto_show = true,
                    -- Delay before showing the documentation window
                    auto_show_delay_ms = 200,
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
                ghost_text = {
                    enabled = false,
                },
            },
            sources = {
                -- adding any nvim-cmp sources here will enable them
                -- with blink.compat
                compat = {},
                default = {
                    "lsp",
                    "dadbod",
                    "snippets",
                    "lazydev",
                    "path",
                    "buffer",
                    "emoji",
                    "avante_commands",
                    "avante_mentions",
                    "avante_files",
                    "copilot",
                    "git",
                },
                providers = {
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
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
                    },
                    path = {
                        name = "Path",
                        module = "blink.cmp.sources.path",
                        -- When typing a path, I would get snippets and text in the
                        -- suggestions, I want those to show only if there are no path
                        -- suggestions
                        fallbacks = { "snippets", "buffer" },
                        opts = {
                            trailing_slash = false,
                            label_trailing_slash = true,
                            get_cwd = function(context)
                                return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
                            end,
                            show_hidden_files_by_default = true,
                        },
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
                    },
                    -- https://github.com/moyiz/blink-emoji.nvim
                    -- how to trigger: type :
                    emoji = {
                        module = "blink-emoji",
                        name = "Emoji",
                        opts = { insert = true }, -- Insert emoji (default) or complete its name
                    },
                    -- ai completion lowest priority
                    copilot = {
                        name = "copilot",
                        module = "blink-cmp-copilot",
                        score_offset = -100,
                        async = true,
                        opts = {
                            max_completions = 3,
                        },
                        transform_items = function(_, items)
                            local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
                            local kind_idx = CompletionItemKind.Copilot or (#CompletionItemKind + 1)

                            -- If not assigned, manually set it
                            if not CompletionItemKind.Copilot then
                                CompletionItemKind[kind_idx] = "Copilot"
                                CompletionItemKind["Copilot"] = kind_idx
                            end

                            for _, item in ipairs(items) do
                                item.kind = kind_idx -- Assign the Copilot kind ID
                                item.kind_icon = "" -- Explicitly set the Copilot icon
                            end

                            return items
                        end,
                    },
                    -- cursor like ai
                    avante_commands = {
                        name = "avante_commands",
                        module = "blink.compat.source",
                        opts = {},
                    },
                    avante_files = {
                        name = "avante_commands",
                        module = "blink.compat.source",
                        opts = {},
                    },
                    avante_mentions = {
                        name = "avante_mentions",
                        module = "blink.compat.source",
                        opts = {},
                    },
                    git = {
                        module = 'blink-cmp-git',
                        name = 'Git',
                        opts = {
                            -- options for the blink-cmp-git
                        },
                    },
                },

                -- Function to use when transforming the items before they're returned for all providers
                -- The default will lower the score for snippets to sort them lower in the list
                -- transform_items = function(_, items) return items end,

                -- Minimum number of characters in the keyword to trigger all providers
                -- May also be `function(ctx: blink.cmp.Context): number`
                min_keyword_length = 0,
            },
            cmdline = {
                enabled = true,
                keymap = { preset = 'cmdline' },
                sources = function()
                    local type = vim.fn.getcmdtype()
                    -- Search forward and backward
                    if type == '/' or type == '?' then return { 'buffer' } end
                    -- Commands
                    if type == ':' or type == '@' then return { 'cmdline' } end
                    return {}
                end,
                completion = {
                    trigger = {
                        show_on_blocked_trigger_characters = {},
                        show_on_x_blocked_trigger_characters = {},
                    },
                    list = {
                        selection = {
                            -- When `true`, will automatically select the first item in the completion list
                            preselect = true,
                            -- When `true`, inserts the completion item automatically when selecting it
                            auto_insert = true,
                        },
                    },
                    menu = {
                        auto_show = true,
                        -- draw = {
                        --     columns = { { 'label', 'label_description', gap = 1 } },
                        -- },
                    },
                    ghost_text = { enabled = false }
                }
            },
            appearance = {
                -- highlight_ns = vim.api.nvim_create_namespace('blink_cmp'),
                -- Sets the fallback highlight groups to nvim-cmp's highlight groups
                -- Useful for when your theme doesn't support blink.cmp
                -- Will be removed in a future release
                -- use_nvim_cmp_as_default = false,
                -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                -- nerd_font_variant = 'mono',

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

                    Copilot = '',

                    openPR = '',
                    openedPR = '',
                    closedPR = '',
                    mergedPR = '',
                    draftPR = '',
                    lockedPR = '',
                    openIssue = '',
                    openedIssue = '',
                    reopenedIssue = '',
                    completedIssue = '',
                    closedIssue = '',
                    not_plannedIssue = '',
                    duplicateIssue = '',
                    lockedIssue = '',
                },
            },
        },
        config = function(_, opts)
            local enabled = opts.sources.default
            for _, source in ipairs(opts.sources.compat or {}) do
                opts.sources.providers[source] = vim.tbl_deep_extend(
                    "force",
                    { name = source, module = "blink.compat.source" },
                    opts.sources.providers[source] or {}
                )
                if type(enabled) == "table" and not vim.tbl_contains(enabled, source) then
                    table.insert(enabled, source)
                end
            end

            -- Unset custom prop to pass blink.cmp validation
            opts.sources.compat = nil

            -- check if we need to override symbol kinds
            for _, provider in pairs(opts.sources.providers or {}) do
                ---@cast provider blink.cmp.SourceProviderConfig|{kind?:string}
                if provider.kind then
                    local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
                    local kind_idx = #CompletionItemKind + 1

                    CompletionItemKind[kind_idx] = provider.kind
                    ---@diagnostic disable-next-line: no-unknown
                    CompletionItemKind[provider.kind] = kind_idx

                    ---@type fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): blink.cmp.CompletionItem[]
                    local transform_items = provider.transform_items
                    ---@param ctx blink.cmp.Context
                    ---@param items blink.cmp.CompletionItem[]
                    provider.transform_items = function(ctx, items)
                        items = transform_items and transform_items(ctx, items) or items
                        for _, item in ipairs(items) do
                            item.kind = kind_idx or item.kind
                        end
                        return items
                    end

                    -- Unset custom prop to pass blink.cmp validation
                    provider.kind = nil
                end
            end

            -- print(vim.inspect(opts))
            require("blink.cmp").setup(opts)
        end,
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
                            hint = {
                                enable = true -- inlay hints
                            }
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
                            inlayHints = {
                                functionReturnTypes = true,
                                variableTypes = true,
                                parameterTypes = true,
                                parameternames = true,
                            },
                        }
                    }
                },

                -- cpp/c lsp
                clangd = {
                    settings = {
                        clangd = {
                            inlayHints = {
                                Designators = true,
                                Enabled = true,
                                ParameterNames = true,
                                DecucedTypes = true,
                            },
                            fallbackFlags = { "-std=c++20" }, -- or your preferred C++ standard
                        }
                    },
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
                                compositeLiteralTypes = true,
                                constantValues = true,         -- Show values of constants
                                functionTypeParameters = true, -- Show type parameters for functions
                                parameterNames = true,
                                rangeVariableTypes = true,     -- Show types of range variables
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

                golangci_lint_ls = {
                    cmd = { 'golangci-lint-langserver' },
                    filetypes = { 'go', 'gomod' },
                    root_dir = function(fname)
                        return require("lspconfig.util").root_pattern("go.mod", ".git")(fname)
                    end,
                    init_options = {
                        command = { 'golangci-lint', 'run', '--out-format', 'json' },
                    },
                },

                -- java lsp settings
                -- inlay hints are generally enabled by default
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

                -- zig 14 dev version zls setup
                zls = {
                    cmd = { "/Users/tengjungao/.zvm/bin/zls" },
                    settings = {
                        zls = {
                            -- Whether to enable build-on-save diagnostics
                            --
                            -- Further information about build-on save:
                            -- https://zigtools.org/zls/guides/build-on-save/
                            -- enable_build_on_save = true,

                            -- omit the following line if `zig` is in your PATH
                            zig_exe_path = "/Users/tengjungao/.zvm/bin/zig"
                        }
                    }
                },

                tailwindcss = {
                    filetypes = {
                        "html", "css", "javascript", "typescript",
                        "vue", "svelte", "php", "htmldjango"
                    },
                    settings = {
                        tailwindcss = {
                            includeLanguages = {
                                elixir = "html-eex",
                                eelixir = "html-eex",
                                heex = "html-eex",
                            },
                        },
                    }
                },

                harper_ls = {
                    -- Limit `harper_ls` to work only on comments and markdown files
                    filetypes = { "markdown", "text" }, -- It will only run for these filetypes
                    settings = {
                        ["harper-ls"] = {
                            userDictPath = "",
                            fileDictPath = "",
                            linters = {
                                SpellCheck = true,
                                SpelledNumbers = false,
                                AnA = true,
                                SentenceCapitalization = true,
                                UnclosedQuotes = true,
                                WrongQuotes = false,
                                LongSentences = true,
                                RepeatedWords = true,
                                Spaces = true,
                                Matcher = true,
                                CorrectNumberSuffix = true
                            },
                            codeActions = {
                                ForceStable = false
                            },
                            markdown = {
                                IgnoreLinkTitle = false
                            },
                            diagnosticSeverity = "hint",
                            isolateEnglish = false
                        }
                    },
                    handlers = {
                        ["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
                            local uri = result.uri
                            local bufnr = vim.uri_to_bufnr(uri)
                            if not bufnr then return end

                            -- Get all diagnostics and filter only those inside comments
                            local new_diagnostics = {}
                            for _, diagnostic in ipairs(result.diagnostics) do
                                local line = vim.api.nvim_buf_get_lines(bufnr, diagnostic.range.start.line,
                                    diagnostic.range.start.line + 1, false)[1]
                                if line and line:match("^%s*[%/%*#]") then -- Matches comment patterns like `//`, `#`, or `/*`
                                    table.insert(new_diagnostics, diagnostic)
                                end
                            end

                            -- Call the original diagnostics handler but only for filtered diagnostics
                            vim.lsp.diagnostic.on_publish_diagnostics(_, { uri = uri, diagnostics = new_diagnostics },
                                ctx, config)
                        end
                    },
                },

            },

            -- some particular setup steps
            setup = {

                -- clangd_extensions
                clangd = function(_, opts)
                    require("clangd_extensions").setup(vim.tbl_deep_extend("force", clangd_ext_opts or {},
                        { server = opts }))
                    return false
                end,

                -- tailwindcss fucking my cpu when editing markdown
                tailwindcss = function(_, opts)
                    opts.on_attach = function(client, bufnr)
                        local filetype = vim.bo[bufnr].filetype
                        if filetype == "markdown" or filetype == "mdx" then
                            client.stop()
                            return
                        end
                    end
                    opts.filetypes = vim.tbl_filter(function(ft)
                        return ft ~= "markdown" and ft ~= "mdx"
                    end, opts.filetypes or {})
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

            require("mason-lspconfig").setup({
                ensure_installed = vim.tbl_keys(opts.servers),
                automatic_installation = true,
            })

            require('mason-lspconfig').setup_handlers({
                function(server_name)
                    local server_opts = opts.servers[server_name] or {}
                    require("lspconfig")[server_name].setup(server_opts)

                    -- if a custom setup function exists, call it
                    if opts.setup and opts.setup[server_name] then
                        opts.setup[server_name](server_name, server_opts)
                    end
                end,
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

    -- ts comments
    {
        "echasnovski/mini.comment",
        event = "VeryLazy",
        opts = {
            options = {
                custom_commentstring = function()
                    return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo
                        .commentstring
                end,
            },
        },
    },

    {
        "JoosepAlviste/nvim-ts-context-commentstring",
        lazy = true,
        opts = {
            enable_autocmd = false,
        },
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
        -- version = "^5", -- recommended
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

    -- inlay hints
    {
        "folke/snacks.nvim",
        opts = {
            inlay_hints = {
                enabled = true,                   -- Enable inlay hints globally
                debounce = 200,                   -- Debounce updates for performance
                display = {
                    highlight = "Comment",        -- Color customization
                    virtual_text = true,          -- Show as virtual text
                    priority = 100,               -- Set hint priority
                },
                exclude = { "markdown", "text" }, -- Exclude unwanted filetypes
            }
        },
        config = function(_, opts)
            require("snacks").setup(opts)
            vim.keymap.set("n", "<leader>si", function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end, { desc = "Toggle Inlay Hints" })
        end,
    },

}
