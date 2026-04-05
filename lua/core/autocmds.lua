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
    vim.highlight.on_yank()
  end,
})

-- ============================================================================
-- Journal Cleanup
-- ============================================================================
vim.api.nvim_create_user_command('JournalPurge', function(opts)
  local days = tonumber(opts.args) or 30
  local cutoff = os.time() - (days * 86400)
  local journal_dir = vim.env.HOME .. '/journal'

  for name, type in vim.fs.dir(journal_dir) do
    if type == 'file' and name:match '^%d%d%d%d%-%d%d%-%d%d%.md$' then
      local year, month, day = name:match '^(%d+)-(%d+)-(%d+)'
      local file_time = os.time { year = tonumber(year), month = tonumber(month), day = tonumber(day) }
      if file_time < cutoff then
        vim.fn.delete(journal_dir .. '/' .. name)
      end
    end
  end
end, { nargs = '?', desc = 'Purge journal entries older than N days (default 30)' })

