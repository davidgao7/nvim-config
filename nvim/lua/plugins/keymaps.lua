-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- set pycharm comment shortcut to nvim
-- comment/uncomment usual command: <leader><BS>gcc
-- local Util = require("lazyvim.util")
--local map = Util.safe_keymap_set( -- map("n", "<D-/>", "<leader><BS>gcc", { desc = "Comment/Uncomment a line" })
-- map("n", "<leader>fs", require("telescope").extensions.live_grep_args, { noremap = true })

-- NOTE: remap the code lsp keymaps since it's taken by copilot_chat
-- mainly the <leader>cc part, which used to be vim.lsp.codelens (run codelens)
return {
  "neovim/nvim-lspconfig",
  init = function()
    local keys = require("lazyvim.plugins.lsp.keymaps").get()
    -- replace the codelens to something else
    keys[#keys + 1] =
      { "<leader>cL", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "v" }, has = "codelens" }
    -- <leader>g is taken by git actions
    keys[#keys + 1] = { "<leader>ci", vim.lsp.buf.definition, desc = "Go to Definition", mode = "n" }
    keys[#keys + 1] = { "<leader>ck", vim.lsp.buf.references, desc = "Find References", mode = "n" }
    -- the move widown right is missing
    keys[#keys + 1] = { "<C-l>", "<C-w>l", desc = "Move to the right window", mode = "n" }
  end,
}
