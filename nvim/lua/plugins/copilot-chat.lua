local prompts = {
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
}


return {
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "main",
        dependencies = {
            { "nvim-lua/plenary.nvim" },
            { "zbirenbaum/copilot.lua" },
        },
        opts = {
            prompts = prompts,
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
                local input = vim.fn.input(prompt)
                if input ~= "" then
                    vim.cmd(command .. " " .. input)
                end
            end

            -- Key mappings for CopilotChat commands
            vim.keymap.set('n', '<leader>ci', '', { desc = 'copilot+' })
            vim.keymap.set('n', '<leader>cie', '<cmd>CopilotChatExplain<CR>', { desc = 'CopilotChat - Explain code' })
            vim.keymap.set('n', '<leader>cit', '<cmd>CopilotChatTests<CR>', { desc = 'CopilotChat - Generate tests' })
            vim.keymap.set('n', '<leader>cir', '<cmd>CopilotChatReview<CR>', { desc = 'CopilotChat - Review code' })
            vim.keymap.set('n', '<leader>ciR', '<cmd>CopilotChatRefactor<CR>', { desc = 'CopilotChat - Refactor code' })
            vim.keymap.set('n', '<leader>cin', '<cmd>CopilotChatBetterNamings<CR>',
                { desc = 'CopilotChat - Better Naming' })
            vim.keymap.set('n', '<leader>cix', '<cmd>CopilotChatInline<CR>', { desc = 'CopilotChat - Inline chat' })
            vim.keymap.set('n', '<leader>cii', function() copilot_chat_input('Ask Copilot: ', 'CopilotChat') end,
                { desc = 'CopilotChat - Ask input' })
            vim.keymap.set('n', '<leader>cim', '<cmd>CopilotChatCommit<CR>',
                { desc = 'Generate commit message for all changes' })
            vim.keymap.set('n', '<leader>ciM', '<cmd>CopilotChatCommitStaged<CR>',
                { desc = 'Generate commit message for staged changes' })
            vim.keymap.set('n', '<leader>ciq', function() copilot_chat_input('Quick Chat: ', 'CopilotChatBuffer') end,
                { desc = 'CopilotChat - Quick chat' })
            vim.keymap.set('n', '<leader>cid', '<cmd>CopilotChatDebugInfo<CR>', { desc = 'CopilotChat - Debug Info' })
            vim.keymap.set('n', '<leader>cif', '<cmd>CopilotChatFixDiagnostic<CR>',
                { desc = 'CopilotChat - Fix Diagnostic' })
            vim.keymap.set('n', '<leader>cil', '<cmd>CopilotChatReset<CR>',
                { desc = 'CopilotChat - Clear buffer and chat history' })
            vim.keymap.set('n', '<leader>civ', '<cmd>CopilotChatToggle<CR>', { desc = 'CopilotChat - Toggle Vsplit' })
        end,
    },
}
