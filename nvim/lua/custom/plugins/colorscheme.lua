-- ~/.config/nvim/lua/colorscheme.lua
-- Kanagawa colorscheme configuration

return {
  'rebelot/kanagawa.nvim',
  name = 'kanagawa',
  priority = 1000,
  init = function()
    -- Ensure true colors are enabled
    vim.opt.termguicolors = true
    vim.o.background = "dark"
    
    -- Setup kanagawa before loading
    require('kanagawa').setup({
      compile = false,
      undercurl = true,
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = false,
      dimInactive = false,
      terminalColors = true,
      colors = {
        palette = {},
        theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
      },
      overrides = function(colors)
        local theme = colors.theme
        return {
          -- Line numbers
          LineNr = { fg = theme.ui.nontext, bg = "NONE" },
          LineNrAbove = { fg = theme.ui.nontext, bg = "NONE" },
          LineNrBelow = { fg = theme.ui.nontext, bg = "NONE" },
          CursorLineNr = { fg = colors.palette.crystalBlue, bold = true, bg = "NONE" },
          
          -- Sign column  
          SignColumn = { bg = "NONE" },
          GitSignsAdd = { fg = colors.palette.autumnGreen, bg = "NONE" },
          GitSignsChange = { fg = colors.palette.autumnYellow, bg = "NONE" },
          GitSignsDelete = { fg = colors.palette.autumnRed, bg = "NONE" },
          
          -- Remove cursorline background
          CursorLine = { bg = "NONE" },
        }
      end,
      theme = "wave",
      background = {
        dark = "wave",
        light = "lotus"
      },
    })
    
    -- Load the colorscheme
    vim.cmd.colorscheme('kanagawa-wave')
    vim.cmd.hi 'Comment gui=none'
  end,
}
