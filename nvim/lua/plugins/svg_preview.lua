return {
  {
    "nmassardot/nvim-preview-svg",
    config = function()
      require("nvim-preview-svg"):setup()
    end,
    opts = {
      browser = "Chrome",
      -- args = false -- macOS versions newer than BigSur may not work with --args
    },
  },
}
