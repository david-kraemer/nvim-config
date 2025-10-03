--[[
  after/ftplugin/tex.lua

  Purpose: LaTeX buffer-local settings

  This file is automatically sourced when opening LaTeX files.
  Use it for buffer-local options specific to LaTeX editing.

  Extension:
    - Add LaTeX-specific vim.opt_local settings here
    - Add LaTeX-specific buffer-local keymaps here
    - Plugin configuration goes in lua/plugins/lang/latex.lua
--]]

-- Text editing options for LaTeX
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.textwidth = 80
vim.opt_local.spell = true
vim.opt_local.spelllang = 'en_us'
vim.opt_local.conceallevel = 0 -- Disable concealing in LaTeX
