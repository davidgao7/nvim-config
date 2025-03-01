-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
require("config.options")

-- Setup lazy.nvim
require("lazy").setup({
    spec = {
        -- import your plugins
        { import = "plugins" },
    },
    -- Configure any other settings here. See the documentation for more details.
    -- colorscheme that will be used when installing plugins.
    -- install = { colorscheme = { "catppuccin" } },
    -- automatically check for plugin updates
    checker = { enabled = true },
})

-- Function to fetch keymaps and display them in fzf-lua
local function keymap_fzf()
    local keymaps = {}
    local modes = { "n", "i", "v", "x", "s", "o", "t", "c" }

    for _, mode in ipairs(modes) do
        for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
            local lhs = map.lhs
            local rhs = map.rhs or "[N/A]"
            local desc = map.desc or ""
            local plugin = map.plugin or "NA" -- Get the plugin name or "NA" if it's a user-defined mapping

            -- Format the line to include mode, keymap, description, and plugin
            local line = string.format("[%s] %s -> %s (%s) [%s]", mode, lhs, rhs, desc, plugin)
            table.insert(keymaps, line)
        end
    end

    require("plugins.fzf") -- Ensure fzf-lua is loaded

    require("fzf-lua").fzf_exec(keymaps, {
        prompt = "Keymaps> ",
        previewer = function(item)
            return vim.fn.systemlist(string.format("echo '%s'", item))
        end,
    })
end

-- Set a keymap to trigger the function
vim.keymap.set("n", "<leader>sk", keymap_fzf, { desc = "Search Keymaps with fzf-lua" })

-- If you still want fallback behavior (e.g., for non-LSP buffers),
-- but don’t want to see "No information available," suppress the message using a custom handler.
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    silent = true, -- Suppress "No information available" messages
})

-- Map <Esc> to clear search highlight and keep its default behavior
vim.keymap.set("n", "<Esc>", "<cmd>noh<CR><Esc>", { desc = "Clear search highlights" })
vim.keymap.set("i", "<Esc>", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("v", "<Esc>", "<Esc>", { desc = "Exit visual mode" })
vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy plugin manager" })
