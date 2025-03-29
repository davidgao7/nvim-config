return {
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        build = ":Copilot auth",
        event = "InsertEnter",
        opts = {
            suggestion = { enabled = false },
            panel = { enabled = false },
            filetypes = {
                markdown = true,
                help = true,
            },
            lsp_binary = nil,
            server_opts_overrides = {},
        },
    },

    -- copilot chat
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "main",
        dependencies = {
            { "nvim-lua/plenary.nvim" },
            { "zbirenbaum/copilot.lua" },
        },
        opts = {
            prompts = {
                -- Code related prompts
                Explain = "Please explain how the following code works.",
                Review = "Please review the following code and provide suggestions for improvement.",
                Tests = "Please explain how the selected code works, then generate unit tests for it.",
                Refactor = "Please refactor the following code to improve its clarity and readability.",
                FixCode = "Please fix the following code to make it work as intended.",
                FixError = "Please explain the error in the following text and provide a solution.",
                BetterNamings = "Please provide better names for the following variables and functions.",
                Documentation = "Please provide documentation for the following code.",
                SwaggerApiDocs = "Please provide documentation for the following API using Swagger.",
                SwaggerJsDocs = "Please write JSDoc for the following API using Swagger.",
                -- Text related prompts
                Summarize = "Please summarize the following text.",
                Spelling = "Please correct any grammar and spelling errors in the following text.",
                Wording = "Please improve the grammar and wording of the following text.",
                Concise = "Please rewrite the following text to make it more concise.",
            },
            auto_follow_cursor = false,
        },
        config = function(_, opts)
            local chat = require("CopilotChat")
            local select = require("CopilotChat.select")

            -- Override prompts
            opts.selection = select.unnamed
            opts.prompts.Commit = {
                prompt = "Write commit message for the change with commitizen convention",
                selection = select.gitdiff,
            }
            opts.prompts.CommitStaged = {
                prompt = "Write commit message for the change with commitizen convention",
                selection = function(source)
                    return select.gitdiff(source, true)
                end,
            }

            chat.setup(opts)

            -- User commands
            vim.api.nvim_create_user_command("CopilotChatVisual", function(args)
                chat.ask(args.args, { selection = select.visual })
            end, { nargs = "*", range = true })

            vim.api.nvim_create_user_command("CopilotChatInline", function(args)
                chat.ask(args.args, {
                    selection = select.visual,
                    window = { layout = "float", relative = "cursor", width = 1, height = 0.4, row = 1 },
                })
            end, { nargs = "*", range = true })

            vim.api.nvim_create_user_command("CopilotChatBuffer", function(args)
                chat.ask(args.args, { selection = select.buffer })
            end, { nargs = "*", range = true })

            -- Function to prompt user input and execute a CopilotChat command
            local function copilot_chat_input(prompt, command)
                if type(command) ~= "string" then
                    print("Error: 'command' should be a string")
                    return
                end
                local input = vim.fn.input(prompt)
                if input ~= "" then
                    vim.cmd(command .. " " .. input)
                end
            end

            vim.keymap.set("n", "<leader>cii", function() copilot_chat_input("Ask Copilot: ", "CopilotChat") end,
                { desc = "CopilotChat - Ask input" })
            vim.keymap.set("n", "<leader>ciq", function() copilot_chat_input("Quick Chat: ", "CopilotChatBuffer") end,
                { desc = "CopilotChat - Quick chat" })
        end,
        keys = {
            { "<leader>ci",  "",                                 mode = "n", desc = "copilot+" },
            { "<leader>cie", "<cmd>CopilotChatExplain<CR>",      mode = "n", desc = "CopilotChat - Explain code" },
            { "<leader>cit", "<cmd>CopilotChatTests<CR>",        mode = "n", desc = "CopilotChat - Generate tests" },
            { "<leader>cir", "<cmd>CopilotChatReview<CR>",       mode = "n", desc = "CopilotChat - Review code" },
            { "<leader>ciR", "<cmd>CopilotChatRefactor<CR>",     mode = "n", desc = "CopilotChat - Refactor code" },
            { "<leader>cix", "<cmd>CopilotChatInline<CR>",       mode = "n", desc = "CopilotChat - Inline chat" },
            { "<leader>cim", "<cmd>CopilotChatCommit<CR>",       mode = "n", desc = "Generate commit message for all changes" },
            { "<leader>ciM", "<cmd>CopilotChatCommitStaged<CR>", mode = "n", desc = "Generate commit message for staged changes" },
            { "<leader>cid", "<cmd>CopilotChatFixCode<CR>",      mode = "n", desc = "CopilotChat - Fix Code" },
            { "<leader>cif", "<cmd>CopilotChatFixError<CR>",     mode = "n", desc = "CopilotChat - Fix Error" },
            { "<leader>cil", "<cmd>CopilotChatReset<CR>",        mode = "n", desc = "CopilotChat - Clear buffer and chat history" },
            { "<leader>civ", "<cmd>CopilotChatToggle<CR>",       mode = "n", desc = "CopilotChat - Toggle Vsplit" },
        }
    },

    -- "cursor": avante.nvim
    {
        "yetone/avante.nvim",
        event = "VeryLazy",
        version = "v0.0.23",      -- Never set this value to "*"! Never!
        opts = {
            provider = "copilot", -- Recommend using Claude
            -- WARNING: Since auto-suggestions are a high-frequency operation and therefore expensive,
            -- currently designating it as `copilot` provider is dangerous because: https://github.com/yetone/avante.nvim/issues/1048
            -- Of course, you can reduce the request frequency by increasing `suggestion.debounce`.
            auto_suggestions_provider = "copilot",
            hints = { enabled = true },
            -- add any opts here
            file_selector = {
                --- @alias FileSelectorProvider "native" | "fzf" | "telescope" | string
                provider = "fzf",
                -- Options override for custom providers
                provider_opts = {},
            },
            -- enable web search tool
            copilot = {
                disable_tools = false,
            },
            -- add web search tools
            web_search_engine = {
                enabled = true,
                provider = "google",
                providers = {
                    google = {
                        api_key_name = "GOOGLE_SEARCH_API_KEY",
                        engine_id_name = "GOOGLE_SEARCH_ENGINE_ID",
                        extra_request_body = {},
                        format_response_body = function(body)
                            if body.items ~= nil then
                                local jsn = vim
                                    .iter(body.items)
                                    :map(
                                        function(result)
                                            return {
                                                title = result.title,
                                                link = result.link,
                                                snippet = result.snippet,
                                            }
                                        end
                                    )
                                    :take(10)
                                    :totable()
                                return vim.json.encode(jsn), nil
                            end
                            return "", nil
                        end,
                    },
                },
            },
        },
        -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
        build = "make",
        -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
        dependencies = {
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            --- The below dependencies are optional,
            "echasnovski/mini.pick",         -- for file_selector provider mini.pick
            "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
            "ibhagwan/fzf-lua",              -- for file_selector provider fzf
            "nvim-tree/nvim-web-devicons",   -- or echasnovski/mini.icons
            -- "zbirenbaum/copilot.lua",        -- for providers='copilot'
            {
                -- support for image pasting
                "HakonHarnes/img-clip.nvim",
                event = "VeryLazy",
                opts = {
                    -- recommended settings
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                            insert_mode = true,
                        },
                        -- required for Windows users
                        use_absolute_path = true,
                    },
                },
            },
            {
                -- Make sure to set this up properly if you have lazy=true
                'MeanderingProgrammer/render-markdown.nvim',
                opts = {
                    file_types = { "markdown", "Avante" },
                },
                ft = { "markdown", "Avante" },
            },
            {
                "folke/which-key.nvim",
                opts = {
                    spec = {
                        { "<leader>cia", group = "cursor" }
                    }
                }
            },
            -- patching cmp in source
            {
                "saghen/blink.compat",
                lazy = true,
                opts = {},
                config = function()
                    -- monkeypatch cmp.ConfirmBehavior for Avante
                    require("cmp").ConfirmBehavior = {
                        Insert = "insert",
                        Replace = "replace",
                    }
                end,
            },
        },
    },

}
