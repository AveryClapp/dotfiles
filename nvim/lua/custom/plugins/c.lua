-- Complete C++ IDE setup for Neovim
return {
  -- Enhanced C++ LSP with clangd
  {
    'p00f/clangd_extensions.nvim',
    ft = { 'c', 'cpp', 'objc', 'objcpp' },
    opts = {
      inlay_hints = {
        inline = true,
        only_current_line = false,
        show_parameter_hints = true,
        parameter_hints_prefix = '<- ',
        other_hints_prefix = '=> ',
      },
      ast = {
        role_icons = {
          type = '🄣',
          declaration = '🄓',
          expression = '🄔',
          statement = ';',
          specifier = '🄢',
          ['template argument'] = '🆃',
        },
      },
    },
  },

  -- LSP Configuration
  {
    'neovim/nvim-lspconfig',
    ft = { 'c', 'cpp', 'objc', 'objcpp' },
    config = function()
      local lspconfig = require 'lspconfig'
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      lspconfig.clangd.setup {
        capabilities = capabilities,
        cmd = {
          'clangd',
          '--background-index',
          '--clang-tidy',
          '--header-insertion=iwyu',
          '--completion-style=detailed',
          '--function-arg-placeholders',
          '--fallback-style=llvm',
          '--enable-config',
          '--offset-encoding=utf-16',
          '--header-insertion-decorators',
          '-j=4',
        },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
      }
    end,
  },

  -- Debugging support
  {
    'mfussenegger/nvim-dap',
    ft = { 'c', 'cpp' },
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
      'nvim-neotest/nvim-nio',
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      -- Setup DAP UI
      dapui.setup {
        icons = { expanded = '▾', collapsed = '▸', current_frame = '▸' },
        layouts = {
          {
            elements = {
              { id = 'scopes', size = 0.25 },
              { id = 'breakpoints', size = 0.25 },
              { id = 'stacks', size = 0.25 },
              { id = 'watches', size = 0.25 },
            },
            size = 40,
            position = 'left',
          },
          {
            elements = { 'repl', 'console' },
            size = 0.25,
            position = 'bottom',
          },
        },
      }

      -- Virtual text
      require('nvim-dap-virtual-text').setup()

      -- C++ debugging with codelldb
      dap.adapters.codelldb = {
        type = 'server',
        port = '${port}',
        executable = {
          command = vim.fn.stdpath 'data' .. '/mason/bin/codelldb',
          args = { '--port', '${port}' },
        },
      }

      dap.configurations.cpp = {
        {
          name = 'Launch file',
          type = 'codelldb',
          request = 'launch',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
        },
      }

      -- Use the same config for C
      dap.configurations.c = dap.configurations.cpp

      -- Auto open/close DAP UI
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end

      -- Debugging keymaps
      vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
      vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'Debug: Step Over' })
      vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'Debug: Step Into' })
      vim.keymap.set('n', '<F12>', dap.step_out, { desc = 'Debug: Step Out' })
      vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>B', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end, { desc = 'Debug: Set Conditional Breakpoint' })
      vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = 'Debug: Toggle UI' })
    end,
  },

  -- CMake integration
  {
    'Civitasv/cmake-tools.nvim',
    ft = { 'c', 'cpp' },
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('cmake-tools').setup {
        cmake_command = 'cmake',
        ctest_command = 'ctest',
        cmake_build_directory = 'build',
        cmake_generate_options = { '-DCMAKE_EXPORT_COMPILE_COMMANDS=1' },
        cmake_build_options = {},
        cmake_console_size = 10,
        cmake_show_console = 'always',
        cmake_dap_configuration = {
          name = 'cpp',
          type = 'codelldb',
          request = 'launch',
        },
        cmake_executor = {
          name = 'quickfix',
          opts = {},
          default_opts = {
            quickfix = {
              show = 'always',
              position = 'belowright',
              size = 10,
            },
          },
        },
        cmake_runner = {
          name = 'terminal',
          opts = {},
          default_opts = {
            terminal = {
              name = 'Main Terminal',
              prefix_name = '[CMakeTools]: ',
              split_direction = 'horizontal',
              split_size = 11,
            },
          },
        },
      }

      -- CMake keymaps
      vim.keymap.set('n', '<leader>cg', ':CMakeGenerate<CR>', { desc = 'CMake: Generate' })
      vim.keymap.set('n', '<leader>cb', ':CMakeBuild<CR>', { desc = 'CMake: Build' })
      vim.keymap.set('n', '<leader>cr', ':CMakeRun<CR>', { desc = 'CMake: Run' })
      vim.keymap.set('n', '<leader>cd', ':CMakeDebug<CR>', { desc = 'CMake: Debug' })
      vim.keymap.set('n', '<leader>ct', ':CMakeRunTest<CR>', { desc = 'CMake: Run Tests' })
      vim.keymap.set('n', '<leader>cs', ':CMakeSelectBuildType<CR>', { desc = 'CMake: Select Build Type' })
    end,
  },

  -- Enhanced completion
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'

      require('luasnip.loaders.from_vscode').lazy_load()

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm { select = true },
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        sources = cmp.config.sources {
          { name = 'nvim_lsp', priority = 1000 },
          { name = 'luasnip', priority = 750 },
          { name = 'buffer', priority = 500 },
          { name = 'path', priority = 250 },
        },
        formatting = {
          format = function(entry, vim_item)
            vim_item.menu = ({
              nvim_lsp = '[LSP]',
              luasnip = '[Snippet]',
              buffer = '[Buffer]',
              path = '[Path]',
            })[entry.source.name]
            return vim_item
          end,
        },
      }

      -- Setup for cmdline
      cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' },
        },
      })

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' },
        }, {
          { name = 'cmdline' },
        }),
      })
    end,
  },

  -- Better syntax highlighting with Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { 'c', 'cpp', 'cmake', 'make', 'ninja', 'comment', 'doxygen' },
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<C-space>',
            node_incremental = '<C-space>',
            scope_incremental = '<C-s>',
            node_decremental = '<C-backspace>',
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
              ['as'] = '@scope',
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              [']m'] = '@function.outer',
              [']]'] = '@class.outer',
            },
            goto_next_end = {
              [']M'] = '@function.outer',
              [']['] = '@class.outer',
            },
            goto_previous_start = {
              ['[m'] = '@function.outer',
              ['[['] = '@class.outer',
            },
            goto_previous_end = {
              ['[M'] = '@function.outer',
              ['[]'] = '@class.outer',
            },
          },
        },
      }
    end,
  },

  -- Symbol outline
  {
    'hedyhli/outline.nvim',
    cmd = { 'Outline', 'OutlineOpen' },
    keys = {
      { '<leader>o', '<cmd>Outline<CR>', desc = 'Toggle outline' },
    },
    opts = {
      outline_window = {
        position = 'right',
        width = 25,
        relative_width = false,
      },
    },
  },

  -- Comment generation
  {
    'danymat/neogen',
    ft = { 'c', 'cpp' },
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = function()
      require('neogen').setup {
        snippet_engine = 'luasnip',
        languages = {
          cpp = {
            template = {
              annotation_convention = 'doxygen',
            },
          },
        },
      }
      vim.keymap.set('n', '<leader>nc', ':Neogen<CR>', { desc = 'Generate comment' })
    end,
  },

  -- Header/source switcher
  {
    'jakemason/ouroboros',
    ft = { 'c', 'cpp' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      vim.keymap.set('n', '<leader>hh', ':Ouroboros<CR>', { desc = 'Switch header/source' })
    end,
  },

  -- Google Test integration
  {
    'nvim-neotest/neotest',
    ft = { 'c', 'cpp' },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'alfaix/neotest-gtest',
    },
    config = function()
      require('neotest').setup {
        adapters = {
          require('neotest-gtest').setup {},
        },
      }
      vim.keymap.set('n', '<leader>tt', function()
        require('neotest').run.run()
      end, { desc = 'Run nearest test' })
      vim.keymap.set('n', '<leader>tf', function()
        require('neotest').run.run(vim.fn.expand '%')
      end, { desc = 'Run file tests' })
      vim.keymap.set('n', '<leader>ts', function()
        require('neotest').summary.toggle()
      end, { desc = 'Toggle test summary' })
    end,
  },
}
