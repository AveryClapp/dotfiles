return {
  'xeluxee/competitest.nvim',
  dependencies = 'muniftanjim/nui.nvim',
  config = function()
    require('competitest').setup {
      local_config_file_name = '.competitest.lua',

      -- Templates for new problems
      template_file = {
        cpp = '~/.config/nvim/templates/cp_template.cpp',
      },

      -- Execution logic
      compile_command = {
        cpp = { exec = 'g++', args = { '-std=c++20', '-O2', '-I' .. os.getenv 'HOME' .. '/.local/include', '$(FNAME)', '-o', 'Executables/$(FNOEXT)' } },
      },
      run_command = {
        cpp = { exec = './Executables/$(FNOEXT)' },
      },
      testcases_use_single_file = true,
      testcases_directory = 'Testcases',
      testcases_single_file_format = '$(FNOEXT).testcases',

      -- UI Settings
      runner_ui = {
        interface = 'popup',
      },
      popup_ui = {
        total_width = 0.8,
        total_height = 0.8,
      },
    }

    -- Keyboard Shortcuts
    local keymap = vim.keymap.set
    local opts = { buffer = true, silent = true }
    keymap('n', '<leader>tc', '<cmd>CompetiTest receive problem<cr>', { desc = 'Receive Problem', unpack(opts) })
    keymap('n', '<leader>tr', '<cmd>CompetiTest run<cr>', { desc = 'Run Tests', unpack(opts) })
    keymap('n', '<leader>ta', '<cmd>CompetiTest add_testcase<cr>', { desc = 'Add Testcase', unpack(opts) })
    keymap('n', '<leader>te', '<cmd>CompetiTest edit_testcase<cr>', { desc = 'Edit Testcase', unpack(opts) })
    keymap('n', '<leader>ts', '<cmd>CompetiTest submit<cr>', { desc = 'Submit Problem', unpack(opts) })
  end,
}
