--[[
  after/ftplugin/markdown.lua

  Purpose: Markdown buffer-local settings

  This file is automatically sourced when opening Markdown files.
  Use it for buffer-local options specific to Markdown editing.

  Extension:
    - Add Markdown-specific vim.opt_local settings here
    - Add Markdown-specific buffer-local keymaps here
    - Plugin configuration goes in lua/plugins/editor.lua
--]]

-- Text editing options for Markdown
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.textwidth = 80 -- Disabled to prevent hard line breaks
vim.opt_local.colorcolumn = '80' -- Visual guide at column 80
vim.opt_local.spell = true
vim.opt_local.spelllang = 'en_us'
vim.opt_local.conceallevel = 0 -- Disable concealing in Markdown

-- Better handling of code blocks
vim.opt_local.autoindent = true
vim.opt_local.smartindent = false -- Prevents markdown interfering with code indentation
vim.opt_local.indentexpr = '' -- Let embedded languages handle their own indentation

