--[[
  core/buffers.lua

  Selective buffer deletion utilities.

  Commands:
    :BufDeleteSuffix[!] {suffix}   - Delete buffers by file suffix
    :BufDeletePattern[!] {pattern} - Delete buffers matching Lua pattern
    :BufDeleteTerminal[!]          - Delete all terminal buffers
    :BufDeleteOther[!]             - Delete all except current buffer
    :BufDeleteHidden[!]            - Delete buffers not visible in any window
    :BufDeleteUnmodified           - Delete all unmodified buffers

  Keymaps:
    <leader>bs - Delete by suffix
    <leader>bp - Delete by pattern
    <leader>bt - Delete terminals
    <leader>bo - Delete other buffers
    <leader>bh - Delete hidden buffers
    <leader>bu - Delete unmodified buffers

  The ! variant forces deletion of modified buffers.
--]]

local M = {}

--- Filter loaded buffers by predicate.
---
--- :param predicate: Function that takes bufnr and returns boolean.
--- :returns: List of buffer numbers matching predicate.
local function buffers_matching(predicate)
  local matches = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and predicate(bufnr) then
      table.insert(matches, bufnr)
    end
  end
  return matches
end

--- Delete buffers, optionally forcing modified ones.
---
--- :param bufnrs: List of buffer numbers to delete.
--- :param force: If true, delete modified buffers without saving.
local function delete_buffers(bufnrs, force)
  local deleted, skipped = 0, 0
  local current = vim.api.nvim_get_current_buf()

  for _, bufnr in ipairs(bufnrs) do
    if vim.bo[bufnr].modified and not force then
      skipped = skipped + 1
    else
      if bufnr == current then
        vim.cmd 'bprevious'
      end
      vim.api.nvim_buf_delete(bufnr, { force = force })
      deleted = deleted + 1
    end
  end

  vim.notify(
    string.format('Deleted %d buffer(s)%s', deleted, skipped > 0 and string.format(' (%d modified skipped)', skipped) or '')
  )
end

--- Check if buffer is displayed in any window.
local function is_buffer_visible(bufnr)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      return true
    end
  end
  return false
end

-- =============================================================================
-- Commands
-- =============================================================================

vim.api.nvim_create_user_command('BufDeleteSuffix', function(opts)
  local suffix = opts.args
  if suffix == '' then
    vim.notify('BufDeleteSuffix requires a suffix argument', vim.log.levels.ERROR)
    return
  end
  local pattern = vim.pesc(suffix) .. '$'
  local bufs = buffers_matching(function(bufnr)
    return vim.api.nvim_buf_get_name(bufnr):match(pattern)
  end)
  delete_buffers(bufs, opts.bang)
end, { nargs = 1, bang = true, desc = 'Delete buffers by file suffix' })

vim.api.nvim_create_user_command('BufDeletePattern', function(opts)
  local pattern = opts.args
  if pattern == '' then
    vim.notify('BufDeletePattern requires a pattern argument', vim.log.levels.ERROR)
    return
  end
  local bufs = buffers_matching(function(bufnr)
    return vim.api.nvim_buf_get_name(bufnr):match(pattern)
  end)
  delete_buffers(bufs, opts.bang)
end, { nargs = 1, bang = true, desc = 'Delete buffers matching Lua pattern' })

vim.api.nvim_create_user_command('BufDeleteTerminal', function(opts)
  local bufs = buffers_matching(function(bufnr)
    return vim.bo[bufnr].buftype == 'terminal'
  end)
  delete_buffers(bufs, opts.bang)
end, { bang = true, desc = 'Delete all terminal buffers' })

vim.api.nvim_create_user_command('BufDeleteOther', function(opts)
  local current = vim.api.nvim_get_current_buf()
  local bufs = buffers_matching(function(bufnr)
    return bufnr ~= current
  end)
  delete_buffers(bufs, opts.bang)
end, { bang = true, desc = 'Delete all buffers except current' })

vim.api.nvim_create_user_command('BufDeleteHidden', function(opts)
  local bufs = buffers_matching(function(bufnr)
    return not is_buffer_visible(bufnr)
  end)
  delete_buffers(bufs, opts.bang)
end, { bang = true, desc = 'Delete buffers not visible in any window' })

vim.api.nvim_create_user_command('BufDeleteUnmodified', function()
  local bufs = buffers_matching(function(bufnr)
    return not vim.bo[bufnr].modified
  end)
  delete_buffers(bufs, false)
end, { desc = 'Delete all unmodified buffers' })

-- =============================================================================
-- Keymaps
-- =============================================================================

vim.keymap.set('n', '<leader>bs', function()
  vim.ui.input({ prompt = 'Suffix: ' }, function(suffix)
    if suffix and suffix ~= '' then
      vim.cmd('BufDeleteSuffix ' .. suffix)
    end
  end)
end, { desc = '[B]uffer delete by [S]uffix' })

vim.keymap.set('n', '<leader>bp', function()
  vim.ui.input({ prompt = 'Pattern: ' }, function(pattern)
    if pattern and pattern ~= '' then
      vim.cmd('BufDeletePattern ' .. pattern)
    end
  end)
end, { desc = '[B]uffer delete by [P]attern' })

vim.keymap.set('n', '<leader>bt', '<cmd>BufDeleteTerminal<cr>', { desc = '[B]uffer delete [T]erminals' })
vim.keymap.set('n', '<leader>bo', '<cmd>BufDeleteOther<cr>', { desc = '[B]uffer delete [O]ther' })
vim.keymap.set('n', '<leader>bh', '<cmd>BufDeleteHidden<cr>', { desc = '[B]uffer delete [H]idden' })
vim.keymap.set('n', '<leader>bu', '<cmd>BufDeleteUnmodified<cr>', { desc = '[B]uffer delete [U]nmodified' })

return M
