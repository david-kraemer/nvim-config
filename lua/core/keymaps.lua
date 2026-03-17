--[[
  core/keymaps.lua

  Purpose: Core keymaps independent of plugins

  This file contains only keymaps that don't depend on plugins.
  Plugin-specific keymaps should be defined in the plugin's config function.

  Organization:
    1. General editor keymaps
    2. Search and navigation
    3. Window management
    4. Terminal mode
    5. Quickfix navigation

  Extension:
    - Add non-plugin keymaps here
    - Plugin keymaps belong in lua/plugins/*.lua files
    - Use descriptive `desc` fields for which-key integration
--]]

-- ============================================================================
-- Search
-- ============================================================================
-- Clear search highlight on pressing Esc in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- ============================================================================
-- Diagnostics
-- ============================================================================
-- Open diagnostic quickfix list
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- ============================================================================
-- Terminal Mode
-- ============================================================================
-- Exit terminal mode with double Esc
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- ============================================================================
-- Accelerated j/k
-- ============================================================================
-- Rapid repeats ramp from 1 to 6 lines per keystroke; slow presses stay at 1
local function accel(key)
  local last = 0
  local step = 1
  return function()
    if vim.v.count ~= 0 then
      step = 1
      return key
    end
    local now = vim.uv.hrtime() / 1e6
    if now - last < 100 then
      step = math.min(step + 1, 3)
    else
      step = 1
    end
    last = now
    return step .. key
  end
end

vim.keymap.set({ 'n', 'v' }, 'j', accel 'j', { expr = true, desc = 'Accelerated down' })
vim.keymap.set({ 'n', 'v' }, 'k', accel 'k', { expr = true, desc = 'Accelerated up' })
vim.keymap.set({ 'n', 'v' }, 'h', accel 'h', { expr = true, desc = 'Accelerated left' })
vim.keymap.set({ 'n', 'v' }, 'l', accel 'l', { expr = true, desc = 'Accelerated right' })

-- ============================================================================
-- Movement Reminders (disable arrow keys)
-- ============================================================================
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- ============================================================================
-- Window Management
-- ============================================================================
-- Navigate between windows with Ctrl+hjkl
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Window command prefix
vim.keymap.set('n', '<leader>w', '<C-w>', { desc = 'Window commands' })

-- ============================================================================
-- Quickfix Navigation
-- ============================================================================
vim.keymap.set('n', ']q', ':cnext<CR>', { desc = 'Next quickfix' })
vim.keymap.set('n', '[q', ':cprev<CR>', { desc = 'Previous quickfix' })

-- ============================================================================
-- HTML Tag Manipulation
-- ============================================================================
vim.keymap.set('n', '<leader>xit', 'cit', { desc = 'Change inner HTML tag content' })
vim.keymap.set('n', '<leader>xat', 'cat', { desc = 'Change entire HTML tag and content' })

-- ============================================================================
-- Scratch
-- ============================================================================
vim.keymap.set('n', '<leader>ff', ':Scratch<CR>', { desc = 'Open daily scratch file' })
vim.keymap.set('n', '<leader>fm', ':ScratchMarkdown<CR>', { desc = 'Open daily Markdown scratch file' })
vim.keymap.set('n', '<leader>fp', ':ScratchPython<CR>', { desc = 'Open daily Python scratch file' })
vim.keymap.set('n', '<leader>fj', ':ScratchJulia<CR>', { desc = 'Open daily Julia scratch file' })
vim.keymap.set('n', '<leader>fr', ':ScratchRust<CR>', { desc = 'Open daily Rust scratch file' })
vim.keymap.set('n', '<leader>fq', ':ScratchSQL<CR>', { desc = 'Open daily SQL scratch file' })
vim.keymap.set('n', '<leader>fl', ':ScratchTeX<CR>', { desc = 'Open daily LaTeX scratch file' })
vim.keymap.set('n', '<leader>ft', ':ScratchTemplate ', { desc = 'Edit scratch template' })
vim.keymap.set('n', '<leader>fP', ':ScratchPurge ', { desc = 'Purge scratch files older than N days (default 7)' })
