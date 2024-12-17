return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup({
        default_file_explorer = true,
        columns = {
          "icon",
          "permissions",
          "size",
          "mtime",
        },
        view_options = {
          show_hidden = false, -- looks kinda messy
        },
      })
    end,
    ops = {},
    keys = {
      -- vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" }),
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
    },
    --  <space>fo  hasn't used yet
  },
}
