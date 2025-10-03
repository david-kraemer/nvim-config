--[[
  plugins/editor.lua

  Purpose: Editor enhancement plugins

  Plugins that enhance core editing experience:
    - File explorer (nvim-tree)
    - Fuzzy finder (telescope)
    - Keymap hints (which-key)
    - Text objects and motions (mini.nvim)
    - Comment toggling
    - Indentation detection

  Organization:
    - File navigation and search
    - Editing enhancements
    - UI helpers

  Extension:
    - Add new editor plugins as table entries in the return array
    - Keep language-specific tools in lang/*.lua
    - Keep git tools in git.lua
--]]

return {
  -- ============================================================================
  -- Indentation Detection
  -- ============================================================================
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  -- ============================================================================
  -- Comment Toggling
  -- ============================================================================
  {
    'numToStr/Comment.nvim',
    opts = {},
  },

  -- ============================================================================
  -- File Explorer
  -- ============================================================================
  {
    'nvim-tree/nvim-tree.lua',
    keys = {
      { '<C-n>', ':NvimTreeToggle<CR>', desc = 'Toggle file tree', noremap = true },
    },
    config = function()
      require('nvim-tree').setup({
        filters = {
          dotfiles = true,
          custom = { 'node_modules', '.git', '.cache' },
        },
        git = {
          enable = true,
          ignore = false,
        },
        actions = {
          open_file = {
            quit_on_open = false,
          },
        },
      })
    end,
  },

  -- ============================================================================
  -- Fuzzy Finder
  -- ============================================================================
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope', -- Load on :Telescope command
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable('make') == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    -- Define all keymaps here to defer loading until first use
    keys = {
      { '<leader>sh', '<cmd>Telescope help_tags<cr>', desc = '[S]earch [H]elp' },
      { '<leader>sk', '<cmd>Telescope keymaps<cr>', desc = '[S]earch [K]eymaps' },
      { '<leader>sf', '<cmd>Telescope find_files<cr>', desc = '[S]earch [F]iles' },
      { '<leader>ss', '<cmd>Telescope builtin<cr>', desc = '[S]earch [S]elect Telescope' },
      { '<leader>sw', '<cmd>Telescope grep_string<cr>', desc = '[S]earch current [W]ord' },
      { '<leader>sg', '<cmd>Telescope live_grep<cr>', desc = '[S]earch by [G]rep' },
      { '<leader>sd', '<cmd>Telescope diagnostics<cr>', desc = '[S]earch [D]iagnostics' },
      { '<leader>sr', '<cmd>Telescope resume<cr>', desc = '[S]earch [R]esume' },
      { '<leader>s.', '<cmd>Telescope oldfiles<cr>', desc = '[S]earch Recent Files ("." for repeat)' },
      { '<leader><leader>', '<cmd>Telescope buffers<cr>', desc = '[ ] Find existing buffers' },
      {
        '<leader>/',
        function()
          require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
            winblend = 10,
            previewer = false,
          }))
        end,
        desc = '[/] Fuzzily search in current buffer',
      },
      {
        '<leader>s/',
        function()
          require('telescope.builtin').live_grep({
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files',
          })
        end,
        desc = '[S]earch [/] in Open Files',
      },
      {
        '<leader>sn',
        function()
          require('telescope.builtin').find_files({ cwd = vim.fn.stdpath('config') })
        end,
        desc = '[S]earch [N]eovim files',
      },
      -- Git pickers (consolidated from git.lua)
      { '<leader>gf', '<cmd>Telescope git_files<cr>', desc = '[G]it [F]iles' },
      { '<leader>gc', '<cmd>Telescope git_commits<cr>', desc = '[G]it [C]ommits' },
      { '<leader>gb', '<cmd>Telescope git_branches<cr>', desc = '[G]it [B]ranches' },
      { '<leader>gs', '<cmd>Telescope git_status<cr>', desc = '[G]it [S]tatus' },
      { '<leader>gx', '<cmd>Telescope git_bcommits<cr>', desc = '[G]it Buffer Commits' },
    },
    config = function()
      require('telescope').setup({
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
        defaults = {
          path_display = { truncate = 3 },
          dynamic_preview_title = true,
          file_ignore_patterns = {
            '%.pdf',
            '%.aux',
            '%.out',
            '%.fls',
          },
        },
      })

      -- Enable extensions
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
    end,
  },

  -- ============================================================================
  -- Which-Key (keymap hints)
  -- ============================================================================
  {
    'folke/which-key.nvim',
    event = 'VeryLazy', -- Defer until after startup
    opts = {
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-&> ',
          M = '<M-&> ',
          D = '<D-&> ',
          S = '<S-&> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },
      spec = {
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },

  -- ============================================================================
  -- Mini.nvim Modules
  -- ============================================================================
  -- Text objects (load eagerly for immediate use)
  {
    'echasnovski/mini.ai',
    event = 'VeryLazy',
    opts = { n_lines = 500 },
  },

  -- Surround operations (load on first use)
  {
    'echasnovski/mini.surround',
    keys = {
      { 'sa', mode = { 'n', 'v' }, desc = 'Add surrounding' },
      { 'sd', mode = 'n', desc = 'Delete surrounding' },
      { 'sr', mode = 'n', desc = 'Replace surrounding' },
    },
    opts = {},
  },

  -- Statusline (load immediately for UI)
  {
    'echasnovski/mini.statusline',
    lazy = false,
    config = function()
      local statusline = require('mini.statusline')
      statusline.setup({ use_icons = vim.g.have_nerd_font })
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },

  -- ============================================================================
  -- Better % matching
  -- ============================================================================
  'andymass/vim-matchup',

  -- ============================================================================
  -- Better repeat with '.'
  -- ============================================================================
  'tpope/vim-repeat',

  -- ============================================================================
  -- Diagnostics Display
  -- ============================================================================
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('trouble').setup()
    end,
  },

  -- ============================================================================
  -- Todo Comments Highlighting
  -- ============================================================================
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = true },
  },
}
