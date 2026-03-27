-- lua/custom/plugins/recorder.lua
return {
  'chrisgrieser/nvim-recorder',
  dependencies = { 'rcarriga/nvim-notify' },
  config = function()
    require('recorder').setup {
      slots = { 'a', 'b', 'c', 'd' },
      mapping = {
        startStopRecording = 'q',
        playMacro = 'Q',
        switchSlot = '<C-q>',
        editMacro = 'cq',
        yankMacro = 'yq',
        addBreakPoint = '##',
      },
      clear = false,
      logLevel = vim.log.levels.INFO,
    }
  end,
}
