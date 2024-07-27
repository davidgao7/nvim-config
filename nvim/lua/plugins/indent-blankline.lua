return {
  {
    "lukas-reineke/indent-blankline.nvim",
    cond = true, -- disable the plugin until it's fixed
    main = "ibl",
    opts = {},
    char = "",
    context_char = "│",
    show_current_context = false,
    show_current_context_start = false,
    max_indent_increase = 1,
    show_trailing_blankline_indent = false,
    config = function()
      -- if you want to highlight scop , uncomment this
      local highlight_colors = {
        "RainbowRed",
        "RainbowYellow",
        "RainbowBlue",
        "RainbowOrange",
        "RainbowGreen",
        "RainbowViolet",
        "RainbowCyan",
      }
      local hooks = require("ibl.hooks")
      -- create the highlight groups in the highlight setup hook, so they are reset
      -- every time the colorscheme changes
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
        vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
        vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
        vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
        vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
        vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
        vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
      end)

      require("ibl").setup({
        -- indent = {
        --   -- char = "|",
        --   highlight = highlight_colors,
        -- },
        whitespace = {
          highlight = "IblWhitespace",
          remove_blankline_trail = false,
        },
        scope = { highlight = highlight_colors },
      })

      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
    end,
  },

  -- NOTE: EMERGEYCY BACKUP PLAN
  -- {
  --   "lukas-reineke/indent-blankline.nvim",
  --   main = "ibl",
  --   commit = "29be0919b91fb59eca9e90690d76014233392bef",
  -- },
}
