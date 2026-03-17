--[[
  plugins/git.lua

  Two tools, clear boundaries:
    - Gitsigns: inline operations while editing (<leader>h*, ]c/[c)
    - Lazygit: everything else (<leader>gg)
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
      word_diff = false,
      watch_gitdir = {
        follow_files = true,
      },
      auto_attach = true,
      attach_to_untracked = true,
      current_line_blame = true,
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
        map('n', '<leader>hs', function()
          gs.stage_hunk()
          vim.schedule(gs.refresh)
        end, { desc = '[H]unk [S]tage' })
        map('n', '<leader>hr', gs.reset_hunk, { desc = '[H]unk [R]eset' })
        map('v', '<leader>hs', function()
          gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
          vim.schedule(gs.refresh)
        end, { desc = '[H]unk [S]tage' })
        map('v', '<leader>hr', function()
          gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = '[H]unk [R]eset' })
        map('n', '<leader>hS', function()
          gs.stage_buffer()
          vim.schedule(gs.refresh)
        end, { desc = '[H]unk [S]tage buffer' })
        map('n', '<leader>hu', function()
          gs.undo_stage_hunk()
          vim.schedule(gs.refresh)
        end, { desc = '[H]unk [U]ndo stage' })
        map('n', '<leader>hR', gs.reset_buffer, { desc = '[H]unk [R]eset buffer' })
        map('n', '<leader>hp', gs.preview_hunk, { desc = '[H]unk [P]review' })
        map('n', '<leader>hb', function()
          gs.blame_line { full = true }
        end, { desc = '[H]unk [B]lame line' })
        map('n', '<leader>hd', gs.diffthis, { desc = '[H]unk [D]iff' })
        map('n', '<leader>hD', function()
          gs.diffthis '~'
        end, { desc = '[H]unk [D]iff ~' })
        map('n', '<leader>td', gs.toggle_deleted, { desc = '[T]oggle [D]eleted' })
        map('n', '<leader>gl', gs.toggle_current_line_blame, { desc = '[G]it [L]ine blame' })

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
      { '<leader>gd', '<cmd>LazyGitCurrentFile<CR>', desc = '[G]it [D]iff current file' },
      { '<leader>gf', '<cmd>LazyGitFilterCurrentFile<CR>', desc = '[G]it [F]ile history' },
      { '<leader>gc', '<cmd>LazyGitFilter<CR>', desc = '[G]it [C]ommits (filter)' },
    },
    config = function()
      vim.g.lazygit_floating_window_winblend = 0
      vim.g.lazygit_floating_window_scaling_factor = 0.9
      vim.g.lazygit_floating_window_border_chars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' }
      vim.g.lazygit_floating_window_use_plenary = 0
    end,
  },

  -- ============================================================================
  -- Octo.nvim (GitHub Issues & PRs in Neovim)
  -- ============================================================================
  {
    'pwntester/octo.nvim',
    cmd = 'Octo',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    keys = {
      -- Pull Requests
      { '<leader>opl', '<cmd>Octo pr list<CR>', desc = '[O]cto [P]R [L]ist' },
      { '<leader>opc', '<cmd>Octo pr create draft<CR>', desc = '[O]cto [P]R [C]reate Draft' },
      { '<leader>opo', '<cmd>Octo pr checkout<CR>', desc = '[O]cto [P]R check[O]ut' },
      { '<leader>opm', '<cmd>Octo pr merge<CR>', desc = '[O]cto [P]R [M]erge' },
      { '<leader>opd', '<cmd>Octo pr diff<CR>', desc = '[O]cto [P]R [D]iff' },
      { '<leader>opk', '<cmd>Octo pr checks<CR>', desc = '[O]cto [P]R chec[K]s' },
      -- Issues
      { '<leader>oil', '<cmd>Octo issue list<CR>', desc = '[O]cto [I]ssue [L]ist' },
      { '<leader>oic', '<cmd>Octo issue create<CR>', desc = '[O]cto [I]ssue [C]reate' },
      { '<leader>ois', '<cmd>Octo issue search<CR>', desc = '[O]cto [I]ssue [S]earch' },
      -- Review
      { '<leader>ors', '<cmd>Octo review start<CR>', desc = '[O]cto [R]eview [S]tart' },
      { '<leader>oru', '<cmd>Octo review submit<CR>', desc = '[O]cto [R]eview s[U]bmit' },
      { '<leader>orr', '<cmd>Octo review resume<CR>', desc = '[O]cto [R]eview [R]esume' },
      { '<leader>ord', '<cmd>Octo review discard<CR>', desc = '[O]cto [R]eview [D]iscard' },
      -- Quick access
      { '<leader>os', '<cmd>Octo search<CR>', desc = '[O]cto [S]earch' },
      { '<leader>oa', '<cmd>Octo actions<CR>', desc = '[O]cto [A]ctions' },
    },
    opts = {
      picker = 'telescope',
      enable_builtin = true,
      default_merge_method = 'squash',
      use_local_fs = true,
      timeout = 10000,
    },
  },
}
