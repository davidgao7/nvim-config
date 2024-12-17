return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").add({ "<C-g>s", mode = "i", desc = "add surround" })
      require("which-key").add({ "<C-g>S", mode = "i", desc = "add surround line" })
      require("which-key").add({ "ys", mode = "n", desc = "add surround+motion" })
      require("which-key").add({ "yss", mode = "n", desc = "add surround line+motion" })
      require("which-key").add({ "cs", mode = "n", desc = "change surround+motion" })
      require("which-key").add({ "cS", mode = "n", desc = "change line surround+motion" })
      require("which-key").add({ "ds", mode = "n", desc = "Delete a surrounding pair" })
      require("which-key").add({ "S", mode = "v", desc = "Surround visual selection" })
      require("which-key").add({ "gS", mode = "v", desc = "Surround visual line" })
      require("which-key").add({ "yT", mode = "v", desc = "Surround new line" })
      require("which-key").add({ "ySS", mode = "n", desc = "Surround line" })
    end,
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      --[[
        -- nvim-surround operations:
        -- add - ys
        -- change - cs
        -- delete - ds
        --]]
      require("nvim-surround").setup({
        keymaps = {
          insert = "<C-g>s", -- insert char between text
          insert_line = "<C-g>S", -- insert char above/below
          normal = "ys", -- add surrounding pair with motion
          normal_cur = "yss", -- add surrounding pair with motion, on this line
          normal_line = "yT", -- add surrounding pair with motion, on new line
          normal_cur_line = "ySS", -- add surrounding pair with motion, on this line
          visual = "S", -- surround visual selection
          visual_line = "gS", -- surround visual line
          delete = "ds", -- delete surrounding pair
          change = "cs", -- change surrounding pair with motion
          change_line = "cS", -- change surrounding pair with motion, on this line
        },
        -- aliases could mess up bracket pair map
        highlight = {
          duration = 0,
        },
        move_cursor = "begin",
      })
    end,
  },
}
