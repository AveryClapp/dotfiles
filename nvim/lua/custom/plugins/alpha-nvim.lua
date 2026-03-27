-- lua/custom/plugins/alpha-nvim.lua
return {
  'goolord/alpha-nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = 'VimEnter',
  config = function()
    local alpha     = require('alpha')
    local dashboard = require('alpha.themes.dashboard')

    -- Highlight groups matching Kanagawa Wave
    vim.api.nvim_set_hl(0, 'AlphaHeader',  { fg = '#7FB4CA' })
    vim.api.nvim_set_hl(0, 'AlphaFooter',  { fg = '#727169', italic = true })
    vim.api.nvim_set_hl(0, 'AlphaButtons', { fg = '#DCD7BA' })

    -- Manual centering: alpha uses byte length, not display width,
    -- so Unicode box chars are miscalculated. Fix with strdisplaywidth.
    local function center(str)
      local cols = vim.o.columns
      local w    = vim.fn.strdisplaywidth(str)
      local pad  = math.max(0, math.floor((cols - w) / 2) - 3)
      return string.rep(' ', pad) .. str
    end

    local art = {
      '███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗',
      '████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║',
      '██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║',
      '██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║',
      '██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║',
      '╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝',
      '~~~~~~~~~~~~~~~~~~~~~~~ 神 奈 川 ~~~~~~~~~~~~~~~~~~~~~~~',
    }

    dashboard.section.header.val  = vim.tbl_map(center, art)
    dashboard.section.header.opts = { position = 'left', hl = 'AlphaHeader' }

    -- Buttons
    local btn = dashboard.button
    dashboard.section.buttons.val = {
      btn('e', '  New file',      ':ene <BAR> startinsert<CR>'),
      btn('f', '  Find file',     ':Telescope find_files<CR>'),
      btn('r', '  Recent files',  ':Telescope oldfiles<CR>'),
      btn('g', '  Live grep',     ':Telescope live_grep<CR>'),
      btn('b', '  Buffers',       ':Telescope buffers<CR>'),
      btn('t', '  Todo list',     ':TodoTelescope<CR>'),
      btn('G', '  Git',           ':Neogit<CR>'),
      btn('u', '  Undo history',  ':UndotreeToggle<CR>'),
      btn('p', '  Plugins',       ':Lazy<CR>'),
      btn('m', '  LSP tools',     ':Mason<CR>'),
      btn('c', '  Config',        ':e ~/.config/nvim/init.lua<CR>'),
      btn('q', '  Quit',          ':qa<CR>'),
    }
    dashboard.section.buttons.opts.hl = 'AlphaButtons'

    -- Footer: stats + random quote
    local quotes = {
      'The best code is no code at all.',
      'Make it work, make it right, make it fast.',
      'Simplicity is the soul of efficiency.',
      'Code is read more often than it is written.',
      'First, solve the problem. Then, write the code.',
      'Any fool can write code a computer understands.',
      'Debugging is twice as hard as writing the code.',
      'Programs must be written for people to read.',
      "Don't Stop Until You Are Proud.",
      'Talk is cheap. Show me the code.',
      'In theory, theory and practice are the same. In practice, they are not.',
      'Weeks of programming can save you hours of planning.',
      'It works on my machine.',
    }
    math.randomseed(os.time())

    local function make_footer()
      local v   = vim.version()
      local ok, lazy = pcall(require, 'lazy')
      local n   = ok and lazy.stats().count or 0
      return {
        center(string.format('nvim v%d.%d.%d  ·  %d plugins', v.major, v.minor, v.patch, n)),
        '',
        center('"' .. quotes[math.random(#quotes)] .. '"'),
      }
    end

    dashboard.section.footer.val  = make_footer()
    dashboard.section.footer.opts = { position = 'left', hl = 'AlphaFooter' }

    dashboard.config.layout = {
      { type = 'padding', val = 3 },
      dashboard.section.header,
      { type = 'padding', val = 2 },
      dashboard.section.buttons,
      { type = 'padding', val = 2 },
      dashboard.section.footer,
    }

    alpha.setup(dashboard.config)

    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'alpha',
      callback = function()
        vim.opt_local.foldenable     = false
        vim.opt_local.number         = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn     = 'no'
      end,
    })
  end,
}
