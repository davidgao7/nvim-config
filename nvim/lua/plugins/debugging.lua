-- Setup adapters as nvim-dap dependencies
return {
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>dP"] = { name = "Python+" },
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "mfussenegger/nvim-dap-python",
      {
        "kmontocam/nvim-conda",
        dependencies = { "nvim-lua/plenary.nvim" },
      },
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
        -- require("dap-python").setup("/Users/tengjungao/anaconda3/envs/changan_project/bin/python")
        require("dap-python").resolve_python = function()
          return ""
        end
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

        -- cpp debugging
        dap.adapters.cppdbg = {
          id = "cppdbg",
          type = "executable",
          command = "OpenDebugAD7",
          options = {
            detached = false,
          },
        }
        dap.configurations.cpp = {
          {
            name = "Launch file",
            type = "cppdbg",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
          },
        }
        dap.configurations.c = dap.configurations.cpp
        dap.configurations.rust = dap.configurations.cpp
      end,
    },
  },
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
      "mfussenegger/nvim-dap-python",
      { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
    },
    branch = "regexp",
    config = function()
      -- This function gets called by the plugin when a new result from fd is received
      -- You can change the filename displayed here to what you like. Here in the example we remove the /bin/python part.
      local function remove_last_part(filename)
        return filename:gsub("/bin/python", ""):gsub("/Users/tengjungao/anaconda3/envs/", "")
      end

      local function on_venv_activate()
        local command_run = false

        local function run_shell_command()
          local source = require("venv-selector").source() -- anaconda_base
          local python = require("venv-selector").python():gsub("/bin/python", "") -- /Users/tengjungao/anaconda3/envs/llmstreamlit/bin/python 1
          for i in string.gmatch(python, "%S+") do -- /Users/tengjungao/anaconda3/envs/llmstreamlit/bin/python
            if string.find(i, "anaconda3/envs") then
              python = i
            end
          end
          -- string.find(source, "conda")  return a number
          vim.notify("python: ", python, "info", { title = "Venv Selector" })

          -- different source has different command to activate the venv
          if string.find(source, "poetry") and command_run == false then
            local command = "poetry env use " .. python
            vim.notify("Poetry venv activated", "info", { title = "Venv Selector" })
            vim.api.nvim_feedkeys(command .. "\n", "n", false)
            command_run = true
          elseif string.find(source, "conda") and command_run == false then
            vim.cmd("CondaActivate " .. remove_last_part(source))
            command_run = true
          elseif string.find(source, "venv") and command_run == false then
            local command = "source " .. python .. "/bin/activate"
            vim.notify("Venv activated", "info", { title = "Venv Selector" })
            vim.api.nvim_feedkeys(command .. "\n", "n", false)
            command_run = true
          end
        end

        vim.api.nvim_create_augroup("TerminalCommands", { clear = true })

        vim.api.nvim_create_autocmd("TermEnter", {
          group = "TerminalCommands",
          pattern = "*",
          callback = run_shell_command,
        })
      end

      require("venv-selector").setup({
        settings = {
          options = {
            -- If you put the callback here as a global option, its used for all searches (including the default ones by the plugin)
            on_telescope_result_callback = remove_last_part,
            -- activate the venv
            on_venv_activate_callback = on_venv_activate,
          },

          search = {
            -- -- If you know that your venvs are in a specific location, you can also disable the default cwd search and write your own:
            -- cwd = false, -- setting this to false disables the default cwd search
            -- my_venvs = {
            --   command = "fd bin/python$ /Users/tengjungao/anaconda3/envs --full-path --color never -E /proc", -- Sample command, need to be changed for your own venvs
            --
            --   -- If you put the callback here, its only called for your "my_venvs" search
            --   on_telescope_result_callback = remove_last_part,
            -- },
            -- If you need to create your own anaconda search, you have to remember to set the type to "anaconda".
            anaconda_base = {
              command = "fd bin/python$ /Users/tengjungao/anaconda3/envs --full-path --color never -E /proc",
              type = "anaconda",
            },
          },
        },
      })
    end,
    opts = {
      debug = false, -- enables you to run the VenvSelectLog command to view debug logs
      on_telescope_result_callback = nil, -- callback function for when a search result shows up in telescope
      on_venv_activate_callback = nil, -- callback function for when a venv is activated
      fd_binary_name = nil, -- plugin looks for `fd` or `fdfind` but you can set something else here
      enable_default_searches = true, -- switches all default searches on/off
      enable_cached_venvs = true, -- automatically activates the venv you used last time in a directory
      activate_venv_in_terminal = true, -- activate the selected python interpreter in terminal windows opened from neovim
      set_environment_variables = true, -- sets VIRTUAL_ENV or CONDA_PREFIX environment variables
      show_telescope_search_type = true, -- shows the name of the search in telescope
      notify_user_on_venv_activation = false, -- notifies user on activation of the virtual env
      search_timeout = 5,
    },
    event = "VeryLazy", -- Optional: needed only if you want to type `:VenvSelect` without a keymapping
    keys = {
      -- Keymap to open VenvSelector to pick a venv.
      { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv", ft = "python" },
    },
  },
}
