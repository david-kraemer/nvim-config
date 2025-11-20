--[[
  plugins/claude.lua

  Purpose: Claude Code integration for AI-assisted development

  Features:
    - Terminal integration with Claude Code CLI
    - Automatic buffer reloading on file changes
    - Multiple command variants (continue, resume, verbose)
    - Floating window interface
    - Git repository root detection

  Keybindings:
    <C-,>       - Toggle Claude Code terminal
    <leader>cc  - Toggle Claude Code terminal
    <leader>cC  - Continue previous conversation
    <leader>cR  - Resume conversation (interactive picker)
    <leader>cV  - Toggle with verbose output

  Commands:
    :ClaudeCode         - Toggle terminal
    :ClaudeCodeContinue - Resume recent conversation
    :ClaudeCodeResume   - Interactive conversation picker
    :ClaudeCodeVerbose  - Enable verbose logging
--]]

return {
  'greggh/claude-code.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    { '<C-,>', desc = 'Toggle Claude Code' },
    { '<leader>cc', desc = 'Toggle [C]laude [C]ode' },
    { '<leader>cC', desc = '[C]laude [C]ontinue' },
    { '<leader>cR', desc = '[C]laude [R]esume' },
    { '<leader>cV', desc = '[C]laude [V]erbose' },
  },
  config = function()
    require('claude-code').setup({
      -- Window configuration
      window = {
        position = 'float', -- Use floating window for less intrusive UX
        split_ratio = 0.85, -- 85% of screen space when in split mode
        float = {
          width = math.min(160, math.floor(vim.o.columns * 0.92)), -- Cap at 160 columns for ultrawide
          height = '92%',
          row = 'center',
          col = 'center',
          border = 'rounded', -- Softer aesthetic
        },
      },

      -- Automatic buffer refresh on file changes
      refresh = {
        enable = true, -- Reload buffers when Claude modifies files
        timer_interval = 100, -- Check for file changes every 100ms
      },

      -- Git integration
      git = {
        use_git_root = true, -- Start Claude in repo root
      },

      -- Command variants for different workflows
      command_variants = {
        continue = '--continue', -- Resume last conversation
        resume = '--resume', -- Interactive conversation selection
        verbose = '--verbose', -- Detailed logging
      },

      -- Keybindings (proper structure for the plugin)
      keymaps = {
        toggle = {
          normal = '<C-,>', -- Primary toggle in normal mode
          terminal = '<C-,>', -- Toggle from terminal mode
          variants = {
            continue = '<leader>cC', -- Continue variant
            resume = '<leader>cR', -- Resume variant
            verbose = '<leader>cV', -- Verbose variant
          },
        },
      },
    })

    -- Register which-key group for discoverability
    local ok, wk = pcall(require, 'which-key')
    if ok then
      wk.add({
        { '<leader>c', group = '[C]laude' },
      })
    end
    
    -- Add additional keymap for <leader>cc since plugin doesn't support multiple toggles
    vim.api.nvim_set_keymap(
      'n',
      '<leader>cc',
      '<cmd>ClaudeCode<CR>',
      { noremap = true, silent = true, desc = '[C]laude [C]ode' }
    )
  end,
}
