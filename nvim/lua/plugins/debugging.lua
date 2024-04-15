-- Setup adapters as nvim-dap dependencies
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "mfussenegger/nvim-dap-python",
    {
      "rcarriga/nvim-dap-ui",
      dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    },
    -- stylua: ignore
    keys = {
      { "<leader>dPw", function() require('dap-python').repl.open() end, desc = "Open dap widgets"},
      { "<leader>dPi", function() require('dap-python').step_into() end, desc = "Debug step_into"},
      { "<leader>dPc", function() require('dap-python').continue() end, desc = "Debug continue"},
      { "<leader>dPb", function() require('dap-python').toggle_breakpoint() end, desc = "Toggle Breakpoint"},
      { "<leader>dPm", function() require('dap-python').test_method() end, desc = "Debug Method" },
      { "<leader>dPC", function() require('dap-python').test_class() end,  desc = "Debug Class" },
    },
    config = function()
      -- local path = require("mason-registry").get_package("debugpy"):get_install_path()
      require("dap-python").setup("/Users/tengjungao/anaconda3/envs/changan_project/bin/python")
      local dap = require("dap")
      local dapui = require("dapui")

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end

      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end

      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end

      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      vim.keymap.set("n", "<Leader>dt", dap.toggle_breakpoint, {})
      vim.keymap.set("n", "<Leader>dc", dap.continue, {})
    end,
  },
}
