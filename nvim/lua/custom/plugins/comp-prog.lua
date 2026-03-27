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

    -- Keyboard Shortcuts (buffer-local to cpp files via autocmd)
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'cpp',
      callback = function(ev)
        local o = function(desc) return { buffer = ev.buf, silent = true, desc = desc } end
        local k = vim.keymap.set
        k('n', '<leader>tc', '<cmd>CompetiTest receive problem<cr>', o('CP: Receive problem'))
        k('n', '<leader>tr', '<cmd>CompetiTest run<cr>',             o('CP: Run tests'))
        k('n', '<leader>ta', '<cmd>CompetiTest add_testcase<cr>',    o('CP: Add testcase'))
        k('n', '<leader>te', '<cmd>CompetiTest edit_testcase<cr>',   o('CP: Edit testcase'))
        k('n', '<leader>tS', '<cmd>CompetiTest submit<cr>',          o('CP: Submit'))
      end,
    })
  end,
}
