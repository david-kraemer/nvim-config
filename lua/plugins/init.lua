--[[
  plugins/init.lua

  Purpose: Bootstrap lazy.nvim and aggregate plugin specifications

  This file:
    1. Installs lazy.nvim if not present
    2. Configures lazy.nvim to import plugin specs from plugins/*.lua

  Organization:
    - Bootstrap section (auto-install lazy.nvim)
    - Plugin loader (imports specs from this directory)

  Extension:
    - Add new plugin files in lua/plugins/
    - lazy.nvim automatically imports all return values from plugins/*.lua
    - Keep this file minimal—all plugin specs belong in other files

  Plugin file structure:
    Each file in lua/plugins/ should return a table (or array of tables)
    containing lazy.nvim plugin specifications:

    return {
      'author/plugin-name',
      opts = { ... },
      config = function() ... end,
    }

  See: https://github.com/folke/lazy.nvim
--]]

-- ============================================================================
-- Bootstrap lazy.nvim
-- ============================================================================
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    lazyrepo,
    lazypath,
  }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- ============================================================================
-- Load Plugins
-- ============================================================================
-- lazy.nvim will automatically import all lua/plugins/*.lua files
-- and merge their specs into a single plugin list
require('lazy').setup({
  -- Import all plugin specs from lua/plugins/*.lua
  { import = 'plugins.editor' },
  { import = 'plugins.coding' },
  { import = 'plugins.lsp' },
  { import = 'plugins.treesitter' },
  { import = 'plugins.git' },
  { import = 'plugins.ui' },
  { import = 'plugins.claude' },
  { import = 'plugins.obsidian' },
  { import = 'plugins.lang.python' },
  { import = 'plugins.lang.latex' },
  { import = 'plugins.lang.web' },
  { import = 'plugins.lang.julia' },
  { import = 'plugins.lang.racket' },
}, {
  -- lazy.nvim configuration options
  ui = {
    -- Use nerd font icons if available
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
  -- Performance optimizations
  performance = {
    rtp = {
      -- Disable unused built-in plugins
      disabled_plugins = {
        'gzip',
        'matchit',
        'matchparen',
        'netrwPlugin',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
})
