-- ~/.config/nvim/lua/colorscheme.lua
-- Kanagawa colorscheme configuration

return {
  'rebelot/kanagawa.nvim',
  name = 'kanagawa',
  priority = 1000,
  init = function()
    -- Set background to dark
    vim.o.background = "dark"
    
    -- Setup kanagawa before loading
    require('kanagawa').setup({
      compile = false,           -- enable compiling the colorscheme
      undercurl = true,          -- enable undercurls
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = false,       -- do not set background color
      dimInactive = false,       -- dim inactive window `:h hl-NormalNC`
      terminalColors = true,     -- define vim.g.terminal_color_{0,17}
      colors = {
        palette = {},
        theme = {
          wave = {},    -- add/modify wave theme colors
          lotus = {},   -- add/modify lotus theme colors  
          dragon = {},  -- add/modify dragon theme colors
          all = {}      -- add/modify colors for all themes
        },
      },
      overrides = function(colors)
        local theme = colors.theme
        return {
          -- Custom line number colors for better visibility
          LineNr = { fg = theme.ui.nontext },
          -- Choose one of these combinations:
          -- Option 1: Subtle grays (no background)
          -- LineNrAbove = { fg = colors.palette.fujiGray, bg = "NONE" },
          -- LineNrBelow = { fg = colors.palette.fujiGray, bg = "NONE" },
          -- CursorLineNr = { fg = colors.palette.fujiWhite, bg = "NONE" },
          
          -- Sign column (git signs, diagnostics, etc.)
          SignColumn = { fg = colors.palette.fujiGray, bg = "NONE" },
          GitSignsAdd = { fg = colors.palette.autumnGreen, bg = "NONE" },
          GitSignsChange = { fg = colors.palette.autumnYellow, bg = "NONE" },
          GitSignsDelete = { fg = colors.palette.autumnRed, bg = "NONE" },

          -- Option 2: Violet theme (uncomment to use)
          LineNrAbove = { fg = colors.palette.springViolet2 },
          LineNrBelow = { fg = colors.palette.springViolet2 },
          CursorLineNr = { fg = colors.palette.fujiWhite, bold = true, bg = "NONE" },
          
          -- Option 3: Aqua theme (uncomment to use)  
          -- LineNrAbove = { fg = colors.palette.waveAqua2 },
          -- LineNrBelow = { fg = colors.palette.waveAqua2 },
          -- CursorLineNr = { fg = colors.palette.springBlue, bold = true },
          
          -- Enhanced comment styling
          Comment = { fg = theme.syn.comment, italic = true },
          
          -- Better telescope highlighting
          TelescopeNormal = { bg = theme.ui.bg_dim, fg = theme.ui.fg_dim },
          TelescopeBorder = { bg = theme.ui.bg_dim, fg = theme.ui.bg_dim },
          TelescopePromptNormal = { bg = theme.ui.bg_p2 },
          TelescopePromptBorder = { bg = theme.ui.bg_p2, fg = theme.ui.bg_p2 },
          TelescopePromptTitle = { bg = colors.palette.waveRed, fg = theme.ui.bg_dim },
          TelescopePreviewTitle = { bg = colors.palette.waveBlue, fg = theme.ui.bg_dim },
          TelescopeResultsTitle = { bg = theme.ui.bg_dim, fg = theme.ui.bg_dim },
        }
      end,
      theme = "wave",              -- Load "wave" theme when 'background' option is not set
      background = {               -- map the value of 'background' option to a theme
        dark = "wave",             -- try "dragon" for darker theme
        light = "lotus"
      },
    })
    
    -- Load the colorscheme
    vim.cmd.colorscheme 'kanagawa-wave'
    
    -- Additional customizations can go here
    vim.cmd.hi 'Comment gui=none'  -- Remove comment styling if you prefer plain comments
  end,
}
