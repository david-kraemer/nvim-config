--[[
  plugins/git.lua

  Purpose: Git integration plugins

  Plugins for git workflow:
    - Gitsigns: Git decorations and hunk operations
    - Neogit: Magit-like git interface
    - Diffview: Advanced diff and history viewer
    - Telescope git pickers

  Organization:
    - Gitsigns (inline git decorations)
    - Neogit (commit interface)
    - Diffview (diff viewer)
    - Keymaps for git workflow

  Extension:
    - Add new git tools here
    - Keep git-related keymaps in this file
--]]

return {
  -- ============================================================================
  -- Gitsigns (git decorations in signcolumn)
  -- ============================================================================
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '>' },
        changedelete = { text = '~' },
      },
      signcolumn = true,
      numhl = false,
      linehl = false,
      word_diff = false,
      watch_gitdir = {
        follow_files = true,
      },
      auto_attach = true,
      attach_to_untracked = false,
      current_line_blame = false,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol',
        delay = 1000,
        ignore_whitespace = false,
        virt_text_priority = 100,
      },
      current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil,
      max_file_length = 40000,
      preview_config = {
        border = 'single',
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1,
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Next git hunk' })

        map('n', '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Previous git hunk' })

        -- Actions
        map('n', '<leader>hs', gs.stage_hunk, { desc = '[H]unk [S]tage' })
        map('n', '<leader>hr', gs.reset_hunk, { desc = '[H]unk [R]eset' })
        map('v', '<leader>hs', function()
          gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = '[H]unk [S]tage' })
        map('v', '<leader>hr', function()
          gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = '[H]unk [R]eset' })
        map('n', '<leader>hS', gs.stage_buffer, { desc = '[H]unk [S]tage buffer' })
        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = '[H]unk [U]ndo stage' })
        map('n', '<leader>hR', gs.reset_buffer, { desc = '[H]unk [R]eset buffer' })
        map('n', '<leader>hp', gs.preview_hunk, { desc = '[H]unk [P]review' })
        map('n', '<leader>hb', function()
          gs.blame_line({ full = true })
        end, { desc = '[H]unk [B]lame line' })
        map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = '[T]oggle [B]lame' })
        map('n', '<leader>hd', gs.diffthis, { desc = '[H]unk [D]iff' })
        map('n', '<leader>hD', function()
          gs.diffthis('~')
        end, { desc = '[H]unk [D]iff ~' })
        map('n', '<leader>td', gs.toggle_deleted, { desc = '[T]oggle [D]eleted' })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Select git hunk' })
      end,
    },
  },

  -- ============================================================================
  -- Neogit (Magit-like interface)
  -- ============================================================================
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
      'nvim-telescope/telescope.nvim',
      'ibhagwan/fzf-lua',
    },
    config = true,
    keys = {
      {
        '<leader>ng',
        function()
          require('neogit').open()
        end,
        desc = '[N]eo[G]it',
      },
      {
        '<leader>nc',
        function()
          require('neogit').open({ 'commit' })
        end,
        desc = '[N]eogit [C]ommit',
      },
    },
  },

  -- ============================================================================
  -- Diffview (diff and history viewer)
  -- ============================================================================
  {
    'sindrets/diffview.nvim',
    keys = {
      { '<leader>gd', '<cmd>DiffviewOpen<CR>', desc = '[G]it [D]iff View' },
      { '<leader>gh', '<cmd>DiffviewFileHistory %<CR>', desc = '[G]it File [H]istory' },
    },
  },

  -- ============================================================================
  -- Additional Git Keymaps (using Telescope)
  -- ============================================================================
  {
    'nvim-telescope/telescope.nvim',
    optional = true,
    keys = {
      { '<leader>gf', '<cmd>Telescope git_files<CR>', desc = '[G]it [F]iles' },
      { '<leader>gc', '<cmd>Telescope git_commits<CR>', desc = '[G]it [C]ommits' },
      { '<leader>gb', '<cmd>Telescope git_branches<CR>', desc = '[G]it [B]ranches' },
      { '<leader>gs', '<cmd>Telescope git_status<CR>', desc = '[G]it [S]tatus' },
      { '<leader>gx', '<cmd>Telescope git_bcommits<CR>', desc = '[G]it Buffer Commits' },
      { '<leader>gl', '<cmd>Gitsigns toggle_current_line_blame<CR>', desc = '[G]it [L]ine Blame' },
      {
        '<leader>gp',
        function()
          vim.cmd('terminal git push')
          vim.cmd('startinsert')
        end,
        desc = '[G]it [P]ush',
      },
      {
        '<leader>gg',
        function()
          vim.cmd('20split | terminal git status')
          vim.cmd('startinsert')
        end,
        desc = '[G]it Status (terminal)',
      },
      {
        '<leader>cc',
        function()
          vim.cmd('Gitsigns stage_hunk')
          vim.cmd('Neogit commit')
        end,
        desc = '[C]ommit [C]urrent buffer',
      },
    },
  },
}
