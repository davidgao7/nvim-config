-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- prevent the markdown auto hide
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "markdown" },
  callback = function()
    vim.wo.conceallevel = 0
  end,
})

-- changing refernce line color
vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("ColorColumn", { clear = true }),
  desc = "Change ColorColumn highlight",
  callback = function()
    vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#234F1E" })
  end,
})

-- show invisible characters
vim.api.nvim_create_autocmd("BufRead", {
  pattern = "*.*", -- Apply to all buffers
  desc = "Show invisible characters",
  callback = function()
    vim.wo.list = true
    vim.wo.listchars = "tab:▸ ,trail:·,extends:❯,precedes:❮,nbsp:·,eol:¬"
  end,
})

-- nvim-cmp sql completion
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sql", "mysql", "plsql", "pgsql", "sqlite" },
  callback = function()
    require("cmp").setup.buffer({
      sources = {
        { name = "vim-dadbod-completion" },
      },
    })
  end,
})
