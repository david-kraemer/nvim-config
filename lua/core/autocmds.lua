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
-- Scratch Files
-- ============================================================================
-- Create scratch directory and commands for daily scratch files
local scratch_dir = vim.fn.stdpath 'data' .. '/scratch'
vim.fn.mkdir(scratch_dir, 'p')

-- Generic function to create scratch commands for any file extension
local function create_scratch_command(name, extension)
  vim.api.nvim_create_user_command(name, function()
    local filename = scratch_dir .. '/' .. os.date '%Y%m%d' .. '.' .. extension
    
    -- Check if file doesn't exist and template exists
    if vim.fn.filereadable(filename) == 0 then
      local template = scratch_dir .. '/templates/' .. extension .. '.template'
      if vim.fn.filereadable(template) == 1 then
        -- Copy template to new scratch file
        vim.fn.system({'cp', template, filename})
      end
    end
    
    -- Open the file normally
    vim.cmd('edit ' .. vim.fn.fnameescape(filename))
  end, {})
end

-- Create specific scratch commands
create_scratch_command('Scratch', 'md')
create_scratch_command('ScratchMarkdown', 'md')
create_scratch_command('ScratchPython', 'py')
create_scratch_command('ScratchLua', 'lua')
create_scratch_command('ScratchJulia', 'jl')
create_scratch_command('ScratchRust', 'rs')
create_scratch_command('ScratchSQL', 'sql')
create_scratch_command('ScratchTeX', 'tex')

-- Command to edit scratch templates
vim.api.nvim_create_user_command('ScratchTemplate', function(opts)
  local template_dir = scratch_dir .. '/templates'
  local ext = opts.args
  
  if ext == '' then
    vim.notify('Usage: :ScratchTemplate <extension>', vim.log.levels.ERROR)
    return
  end
  
  local template_path = template_dir .. '/' .. ext .. '.template'
  vim.cmd('edit ' .. vim.fn.fnameescape(template_path))
end, {
  nargs = 1,
  complete = function()
    local template_dir = scratch_dir .. '/templates'
    local templates = vim.fn.glob(template_dir .. '/*.template', false, true)
    return vim.tbl_map(function(path)
      return vim.fn.fnamemodify(path, ':t:r')  -- Get filename without .template extension
    end, templates)
  end,
  desc = 'Edit a scratch file template',
})

vim.api.nvim_create_user_command('ScratchPurge', function(opts)
  local days = tonumber(opts.args) or 7
  local cutoff = os.time() - (days * 86400)

  for name, type in vim.fs.dir(scratch_dir) do
    -- Match any YYYYMMDD.ext pattern
    if type == 'file' and name:match '^%d%d%d%d%d%d%d%d%.%w+$' then
      local year = tonumber(name:sub(1, 4))
      local month = tonumber(name:sub(5, 6))
      local day = tonumber(name:sub(7, 8))
      local file_time = os.time { year = year, month = month, day = day }

      if file_time < cutoff then
        vim.fn.delete(scratch_dir .. '/' .. name)
      end
    end
  end
end, { nargs = '?' })

