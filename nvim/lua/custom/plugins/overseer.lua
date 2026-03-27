-- lua/custom/plugins/overseer.lua
return {
  {
    'stevearc/overseer.nvim',
    cmd = { 'OverseerRun', 'OverseerToggle', 'OverseerBuild' },
    keys = {
      { '<leader>oo', '<cmd>OverseerToggle<CR>', desc = 'Overseer: Toggle panel' },
      { '<leader>or', '<cmd>OverseerRun<CR>',    desc = 'Overseer: Run task' },
    },
    config = function()
      require('overseer').setup {
        task_list = {
          direction = 'bottom',
          min_height = 12,
          max_height = 20,
        },
      }
    end,
  },
}
