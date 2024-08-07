-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- show the file path in the title
vim.opt.winbar = "%=%m %f"
-- always toggle off the conceallevel and always show everything
vim.opt.conceallevel = 0
-- set vertical refernce line
vim.opt.colorcolumn = "79"
-- enable mouse mode
vim.opt.mouse = "a"
-- set size of an indent to 4 spaces
vim.opt.shiftwidth = 4
-- a tab is 4 spaces
vim.opt.tabstop = 4
-- pressing tab key will insert 4 spaces
vim.opt.expandtab = true
-- number of spaces inserted instead of a tab
vim.opt.softtabstop = 4

-- indent blankline configuration
vim.opt.list = true
--vim.cmd([[highlight IndentBlanklineIndent1 guifg=#E06C75 gui=nocombine]])
--vim.cmd([[highlight IndentBlanklineIndent2 guifg=#E5C07B gui=nocombine]])
--vim.cmd([[highlight IndentBlanklineIndent3 guifg=#98C379 gui=nocombine]])
--vim.cmd([[highlight IndentBlanklineIndent4 guifg=#56B6C2 gui=nocombine]])
--vim.cmd([[highlight IndentBlanklineIndent5 guifg=#61AFEF gui=nocombine]])
--vim.cmd([[highlight IndentBlanklineIndent6 guifg=#C678DD gui=nocombine]])

-- enable mouse mode
vim.opt.mouse = "a"

-- smart indent
-- vim.opt.smartindent = true

-- sync with system clipboard
vim.opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
