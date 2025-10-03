--[[
  plugins/lang/web.lua

  Purpose: Web development plugins (HTML/CSS/JavaScript/TypeScript)

  Web development tools:
    - nvim-ts-autotag: Auto-close and rename HTML tags
    - bracey.vim: Live browser preview
    - nvim-colorizer: Display color codes with their actual colors
    - typescript-tools: Enhanced TypeScript support
    - package-info: Display npm package versions

  Organization:
    - HTML/CSS tools
    - JavaScript/TypeScript tools
    - Live preview
    - Package management helpers

  Extension:
    - Add web development tools here
    - Web LSPs (html, cssls, tsserver, emmet_ls) are in lsp.lua
    - Web formatters (prettier) are in coding.lua
    - Buffer-local settings go in after/ftplugin/javascript.lua

  Keymaps:
    - <leader>lp: Start live preview (Bracey)
    - <leader>ls: Stop live preview
    - <leader>lr: Reload live preview
    - <leader>cp: Toggle colorizer
    - <leader>ht: Change inner HTML tag
    - <leader>hT: Change entire HTML tag
--]]

return {
  -- ============================================================================
  -- HTML Auto-tag
  -- ============================================================================
  {
    'windwp/nvim-ts-autotag',
    ft = { 'html', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'tsx', 'jsx' },
    config = function()
      require('nvim-ts-autotag').setup()
    end,
  },

  -- ============================================================================
  -- Live Browser Preview
  -- ============================================================================
  {
    'turbio/bracey.vim',
    build = 'npm install --prefix server',
    cmd = { 'Bracey', 'BraceyStop', 'BraceyReload' },
    ft = { 'html', 'css', 'javascript' },
    keys = {
      { '<leader>lp', ':Bracey<CR>', desc = 'Start live preview' },
      { '<leader>ls', ':BraceyStop<CR>', desc = 'Stop live preview' },
      { '<leader>lr', ':BraceyReload<CR>', desc = 'Reload live preview' },
    },
  },

  -- ============================================================================
  -- Color Code Display
  -- ============================================================================
  {
    'norcalli/nvim-colorizer.lua',
    ft = { 'html', 'css', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
    config = function()
      require('colorizer').setup({ 'html', 'css', 'javascript' })
      vim.keymap.set('n', '<leader>cp', ':ColorizerToggle<CR>', { desc = 'Toggle colorizer' })
    end,
  },

  -- ============================================================================
  -- TypeScript Enhanced Support
  -- ============================================================================
  {
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
    config = function()
      require('typescript-tools').setup({})
    end,
  },

  -- ============================================================================
  -- NPM Package Version Display
  -- ============================================================================
  {
    'vuki656/package-info.nvim',
    dependencies = { 'MunifTanjim/nui.nvim' },
    ft = { 'json' },
    config = function()
      require('package-info').setup()
    end,
  },
}
