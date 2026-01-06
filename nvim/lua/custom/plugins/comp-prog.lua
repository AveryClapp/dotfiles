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
        cpp = { exec = 'g++', args = { '-O3', '$(FNAME)', '-o', '$(FNOEXT)' } },
      },
      run_command = {
        cpp = { exec = './$(FNOEXT)' },
      },
      testcases_use_single_file = true,

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
    keymap('n', '<leader>tc', '<cmd>CompetiTest receive problem<cr>', { desc = 'Receive Problem' })
    keymap('n', '<leader>tr', '<cmd>CompetiTest run<cr>', { desc = 'Run Tests' })
    keymap('n', '<leader>ta', '<cmd>CompetiTest add_testcase<cr>', { desc = 'Add Testcase' })
    keymap('n', '<leader>te', '<cmd>CompetiTest edit_testcase<cr>', { desc = 'Edit Testcase' })
    keymap('n', '<leader>ts', '<cmd>CompetiTest submit<cr>', { desc = 'Submit Problem' })
  end,
}
