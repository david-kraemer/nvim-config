--[[
  core/autocmds.lua

  Purpose: Core autocommands independent of plugins

  This file contains autocommands that configure general Neovim behavior
  not tied to specific plugins or filetypes.

  Organization:
    1. General editor autocommands
    2. UI enhancements

  Extension:
    - Add general-purpose autocommands here
    - Plugin-specific autocommands belong in plugin configs
    - Filetype-specific settings belong in after/ftplugin/*.lua

  Note: Filetype-specific autocommands that set buffer-local options
  should be moved to after/ftplugin/ files for cleaner organization.
--]]

-- ============================================================================
-- Visual Feedback
-- ============================================================================
-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- ============================================================================
-- Python/Jupyter
-- ============================================================================
-- Auto-initialize Molten for Python files with Jupyter cells
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'python' },
  callback = function()
    -- Check if file contains jupyter-style cells (# %%%%)
    local lines = vim.api.nvim_buf_get_lines(0, 0, 50, false)
    for _, line in ipairs(lines) do
      if line:match('^# %%%%') then
        vim.cmd('MoltenInit python3')
        break
      end
    end
  end,
})

-- Auto-initialize Molten for .ipynb files
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
  pattern = '*.ipynb',
  callback = function()
    vim.cmd('MoltenInit python3')
  end,
})

-- Set filetype for .ipynb files (treated as JSON for editing)
vim.api.nvim_create_autocmd({ 'BufRead' }, {
  pattern = '*.ipynb',
  callback = function()
    vim.cmd('set filetype=json')
  end,
})
