--[[
  plugins/lang/python.lua

  Purpose: Python-specific plugins and configuration

  Python tools:
    - Molten: Jupyter notebook integration
    - image.nvim: Display images from notebooks
    - venv-selector: Virtual environment management

  Organization:
    - Jupyter/notebook tools
    - Virtual environment management
    - Python-specific keymaps
    - Autocommands for Python files

  Extension:
    - Add Python development tools here
    - Python LSP config (ruff) is in lsp.lua
    - Python formatting (ruff_format) is in coding.lua
    - Buffer-local Python settings go in after/ftplugin/python.lua

  Note: Molten provides REPL-like experience in Python files with # %%%% cells
--]]

return {
  -- ============================================================================
  -- Jupyter Integration
  -- ============================================================================
  {
    'benlubas/molten-nvim',
    version = '^1.0.0',
    dependencies = { '3rd/image.nvim' },
    build = ':UpdateRemotePlugins',
    ft = { 'python' },
    cmd = { 'MoltenInit' },
    init = function()
      vim.g.molten_image_provider = 'image.nvim'
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_wrap_output = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true
    end,
    keys = {
      { '<leader>mi', ':MoltenInit<CR>', desc = '[M]olten [I]nit' },
      { '<leader>mr', ':MoltenEvaluateOperator<CR>', desc = '[M]olten [R]un operator' },
      { '<leader>ml', ':MoltenEvaluateLine<CR>', desc = '[M]olten eval [L]ine' },
      { '<leader>mr', ':<C-u>MoltenEvaluateVisual<CR>gv', mode = 'x', desc = '[M]olten [R]un visual' },
      { '<leader>mc', ':MoltenReevaluateCell<CR>', desc = '[M]olten eval [C]ell' },
      { '<leader>md', ':MoltenDelete<CR>', desc = '[M]olten [D]elete cell' },
      { '<leader>mh', ':MoltenHideOutput<CR>', desc = '[M]olten [H]ide output' },
      { '<leader>ms', ':MoltenShowOutput<CR>', desc = '[M]olten [S]how output' },
    },
  },

  -- ============================================================================
  -- Image Rendering
  -- ============================================================================
  {
    '3rd/image.nvim',
    enabled = vim.env.TERM == 'xterm-kitty', -- Only enable if using Kitty terminal
    opts = {
      backend = 'kitty', -- Kitty is the only backend that works on macOS
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { 'markdown', 'vimwiki' },
        },
        neorg = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { 'norg' },
        },
        html = {
          enabled = false,
        },
        css = {
          enabled = false,
        },
      },
      max_width = nil,
      max_height = nil,
      max_width_window_percentage = nil,
      max_height_window_percentage = 50,
      window_overlap_clear_enabled = false,
      window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', '' },
      editor_only_render_when_focused = false,
      tmux_show_only_in_active_window = false,
      hijack_file_patterns = { '*.png', '*.jpg', '*.jpeg', '*.gif', '*.webp', '*.avif' },
    },
  },

  -- ============================================================================
  -- Virtual Environment Selector
  -- ============================================================================
  -- TEMPORARILY DISABLED - venv-selector was causing errors with scratch files
  -- To re-enable:
  -- 1. Uncomment the block below
  -- 2. Run :Lazy sync
  -- 3. Restart Neovim
  -- {
  --   'linux-cultist/venv-selector.nvim',
  --   dependencies = {
  --     'neovim/nvim-lspconfig',
  --     'nvim-telescope/telescope.nvim',
  --     'mfussenegger/nvim-dap-python',
  --   },
  --   ft = 'python',
  --   lazy = true,
  --   opts = {
  --     notify_user_on_activate = false,
  --   },
  --   keys = {
  --     { '<leader>vs', '<cmd>VenvSelect<cr>', desc = '[V]env [S]elect' },
  --     { '<leader>vc', '<cmd>VenvSelectCached<cr>', desc = '[V]env [C]ached' },
  --   },
  -- },
}
