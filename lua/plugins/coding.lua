--[[
  plugins/coding.lua

  Purpose: Coding assistance plugins

  Plugins that assist with writing code:
    - Autocompletion (blink.cmp)
    - Snippets (LuaSnip)
    - AI assistance (Copilot)
    - Auto-pairs (brackets, quotes)
    - Formatting (conform.nvim)

  Organization:
    - Completion engine
    - Snippet engine
    - AI tools
    - Auto-formatting
    - Helper tools

  Extension:
    - Add new coding assistance plugins here
    - LSP-specific config goes in lsp.lua
    - Language-specific tools go in lang/*.lua
--]]

return {
  -- ============================================================================
  -- Autocompletion
  -- ============================================================================
  {
    'saghen/blink.cmp',
    event = 'InsertEnter', -- Load when entering insert mode, not at startup
    version = false, -- Use latest version for bug fixes and improvements
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          -- Build step needed for regex support in snippets
          -- Not supported on many Windows environments
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        opts = {},
      },
      'folke/lazydev.nvim',
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        -- 'default' for mappings similar to built-in completion
        --   <c-y> to accept the completion
        --   <c-space> to open menu or docs
        --   <c-n>/<c-p> or <up>/<down> to select items
        --   <c-e> to hide menu
        --   <c-k> to toggle signature help
        --   <tab>/<s-tab> to move through snippet placeholders
        preset = 'default',
      },

      appearance = {
        nerd_font_variant = 'mono',
      },

      completion = {
        documentation = {
          auto_show = false,
          auto_show_delay_ms = 500,
        },
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = {
          lazydev = {
            module = 'lazydev.integrations.blink',
            score_offset = 100,
          },
        },
      },

      snippets = { preset = 'luasnip' },

      fuzzy = { implementation = 'lua' },

      signature = { enabled = true },
    },
  },

  -- ============================================================================
  -- AI Assistance
  -- ============================================================================
  {
    'github/copilot.vim',
    event = 'InsertEnter', -- Defer heavy Node.js process until needed
    config = function()
      vim.api.nvim_set_keymap('i', '<C-J>', 'copilot#Accept("<CR>")', { silent = true, expr = true })
      vim.api.nvim_set_keymap('i', '<C-K>', 'copilot#Next()', { silent = true, expr = true })
      vim.api.nvim_set_keymap('i', '<C-L>', 'copilot#Previous()', { silent = true, expr = true })
    end,
  },

  -- ============================================================================
  -- Auto-pairs
  -- ============================================================================
  {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup()
    end,
  },

  -- ============================================================================
  -- Formatting
  -- ============================================================================
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable format_on_save for languages without standardized style
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 5000,
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'ruff_organize_imports', 'ruff_fix', 'ruff_format' },
        javascript = { 'prettier' },
        javascriptreact = { 'prettier' },
        typescript = { 'prettier' },
        typescriptreact = { 'prettier' },
        css = { 'prettier' },
        json = { 'prettier' },
        markdown = { 'prettier' },
      },
    },
  },
}
