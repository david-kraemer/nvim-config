--[[
  core/options.lua

  Purpose: Core Neovim options and global settings

  This file contains all vim.opt and vim.g settings that configure
  the editor's behavior independent of any plugins.

  Organization:
    1. Leader key configuration (must be first)
    2. Plugin-independent global variables
    3. UI and display settings
    4. Editing behavior
    5. Search settings
    6. File handling
    7. Performance settings

  Extension:
    - Add new options in the appropriate section
    - Avoid plugin-specific settings (those go in plugin specs)
    - Keep buffer-local settings in after/ftplugin/ files
--]]

-- ============================================================================
-- Leader Keys (must be set before plugins load)
-- ============================================================================
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- ============================================================================
-- Global Variables
-- ============================================================================
-- Set to true if you have a Nerd Font installed
vim.g.have_nerd_font = false

-- Disable netrw (using nvim-tree instead)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Python host program (using spade environment)
vim.g.python3_host_prog = '/Users/dkraemer/.uv/spade/bin/python3'

-- ============================================================================
-- UI and Display
-- ============================================================================
-- Enable 24-bit RGB color
vim.opt.termguicolors = true

-- Line numbers
vim.opt.number = true
-- vim.opt.relativenumber = true  -- Uncomment for relative line numbers

-- Don't show mode in command line (shown in statusline)
vim.opt.showmode = false

-- Keep signcolumn always visible
vim.opt.signcolumn = 'yes'

-- Highlight current cursor line
vim.opt.cursorline = true

-- Minimal lines to keep above/below cursor
vim.opt.scrolloff = 10

-- How to display whitespace characters
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live as you type
vim.opt.inccommand = 'split'

-- ============================================================================
-- Editing Behavior
-- ============================================================================
-- Enable mouse support
vim.opt.mouse = 'a'

-- Enable break indent
vim.opt.breakindent = true

-- Sync clipboard with OS (scheduled to avoid startup delay)
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Allow switching buffers without saving
-- vim.opt.hidden = true  -- Deprecated: enabled by default in modern Neovim

-- Format options
vim.opt.formatoptions = vim.opt.formatoptions
  - 'a' -- No auto formatting
  + 'j' -- Remove comment leader when joining
  + 'n' -- Smart indent lists
  + 'r' -- Continue comments after return

-- ============================================================================
-- Search Settings
-- ============================================================================
-- Case-insensitive search unless \C or capital letter in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Highlight search results
vim.opt.hlsearch = true

-- Incremental search
vim.opt.incsearch = true

-- Default g flag on substitutions
vim.opt.gdefault = true

-- ============================================================================
-- File Handling
-- ============================================================================
-- Persistent undo
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand '~/.vim/undodir'

-- No swap files
vim.opt.swapfile = false

-- Change to file's directory when opening
vim.opt.autochdir = true  -- Change working directory to current file's directory

-- Confirm before failing on unsaved changes
vim.opt.confirm = true

-- ============================================================================
-- Split Behavior
-- ============================================================================
vim.opt.splitright = true
vim.opt.splitbelow = true

-- ============================================================================
-- Performance
-- ============================================================================
-- Faster update time for CursorHold and swap writes
vim.opt.updatetime = 250

-- Faster mapped sequence completion
vim.opt.timeoutlen = 300

-- Don't redraw during macros
vim.opt.lazyredraw = true

-- Avoid ins-completion messages
vim.opt.shortmess:append 'c'

-- Terminal performance optimizations
vim.opt.ttyfast = true -- Assume fast terminal connection
vim.opt.shell = vim.fn.executable('zsh') == 1 and 'zsh' or vim.o.shell
vim.g.terminal_scrollback = 1000 -- Limit scrollback (default is 10000)
