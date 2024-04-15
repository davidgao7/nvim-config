return {
  "zbirenbaum/copilot.lua",
  keys = {
    -- goto next / previous suggestion
    { "<C-n>", require("copilot.suggestion").next(), desc = "next" },
    { "<C-p>", require("copilot.suggestion").prev(), desc = "prev" },
    { "<C-yw>", require("copilot.suggestion").accept_word(), "accept_word" },
    { "<C-yl>", require("copilot.suggestion").accept_line(), "accept_line" },
    { "<C-c>", require("copilot.suggestion").dismiss(), "dismiss" },
  },
  cmd = "Copilot",
  build = ":Copilot auth",
  opts = {
    suggestion = { enabled = true },
    panel = { enabled = true },
    filetypes = {
      markdown = true,
      help = true,
    },
  },
}
