--[[
  plugins/git.lua

  Purpose: Git integration plugins

  Plugins for git workflow:
    - Gitsigns: Git decorations and hunk operations
    - Lazygit: Terminal UI for git commands
    - Diffview: Advanced diff and history viewer

  Organization:
    - Gitsigns (inline git decorations and hunk operations)
    - Lazygit (primary git interface)
    - Diffview (detailed diff viewer)
    - Minimal git keymaps

  Extension:
    - Most git operations go through lazygit (<leader>gg)
    - Quick hunk operations stay with gitsigns (<leader>h*)
    - Detailed diffs available via diffview (<leader>gd)
--]]

return {
  -- ============================================================================
  -- Gitsigns (git decorations in signcolumn)
  -- ============================================================================
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '▎' },
        change = { text = '▎' },
        delete = { text = '▏' },
        topdelete = { text = '▔' },
        changedelete = { text = '▒' },
        untracked = { text = '░' },
      },
      signcolumn = true,
      numhl = true,
      linehl = false,
      word_diff = true,
      watch_gitdir = {
        follow_files = true,
      },
      auto_attach = true,
      attach_to_untracked = true,
      current_line_blame = false,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'right_align',
        delay = 200,
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
  -- Lazygit (Terminal UI for git)
  -- ============================================================================
  {
    'kdheepak/lazygit.nvim',
    cmd = {
      'LazyGit',
      'LazyGitConfig',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
    },
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>gg', '<cmd>LazyGit<CR>', desc = '[G]it [G]UI (lazygit)' },
      { '<leader>gf', '<cmd>LazyGitFilterCurrentFile<CR>', desc = '[G]it [F]ile history' },
      { '<leader>gc', '<cmd>LazyGitFilter<CR>', desc = '[G]it [C]ommits (filter)' },
    },
    config = function()
      -- Use floating window for less intrusive UX (consistent with claude-code)
      vim.g.lazygit_floating_window_winblend = 0
      vim.g.lazygit_floating_window_scaling_factor = 0.9
      vim.g.lazygit_floating_window_border_chars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' }
      vim.g.lazygit_floating_window_use_plenary = 0
      vim.g.lazygit_use_neovim_remote = 1
      
      -- Custom config location if needed
      vim.g.lazygit_use_custom_config_file_path = 0
    end,
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
  -- Complementary Git Keymaps
  -- ============================================================================
  -- Minimal additional keymaps that complement lazygit's functionality
  {
    'nvim-telescope/telescope.nvim',
    optional = true,
    keys = {
      { '<leader>gF', '<cmd>Telescope git_files<CR>', desc = '[G]it [F]iles (search)' },
      { '<leader>gs', '<cmd>Telescope git_status<CR>', desc = '[G]it [S]tatus (telescope)' },
      { '<leader>gb', '<cmd>Telescope git_branches<CR>', desc = '[G]it [B]ranches (switch)' },
      { '<leader>gl', '<cmd>Gitsigns toggle_current_line_blame<CR>', desc = '[G]it [L]ine blame toggle' },
    },
  },
}
