--[[
  plugins/lsp.lua

  Purpose: LSP (Language Server Protocol) configuration

  LSP provides:
    - Go to definition/references
    - Autocompletion
    - Code actions and refactoring
    - Diagnostics
    - Symbol search

  Organization:
    1. LSP plugin configuration (mason, lspconfig)
    2. Server list and settings
    3. LSP keymaps (set on LspAttach)
    4. Diagnostic configuration

  Extension:
    - Add new language servers to `servers` table
    - Customize server settings in server-specific tables
    - Add LSP keymaps in on_attach function
    - Adjust diagnostic display in diagnostic config

  See:
    - :help lspconfig-all (list all available servers)
    - :help lsp
--]]

return {
  -- ============================================================================
  -- Lua LSP for Neovim config
  -- ============================================================================
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  -- ============================================================================
  -- Main LSP Configuration
  -- ============================================================================
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Mason: LSP/tool installer
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Status updates for LSP
      { 'j-hui/fidget.nvim', opts = {} },

      -- Completion capabilities
      'saghen/blink.cmp',
    },
    config = function()
      -- ========================================================================
      -- LSP Keymaps (triggered when LSP attaches to buffer)
      -- ========================================================================
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Navigation
          map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- Symbols
          map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
          map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')

          -- Actions
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

          -- Utility function for version compatibility
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has('nvim-0.11') == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- Document highlight on cursor hold
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = 'kickstart-lsp-highlight', buffer = event2.buf })
              end,
            })
          end

          -- Inlay hints toggle
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- ========================================================================
      -- Diagnostic Configuration
      -- ========================================================================
      vim.diagnostic.config({
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '�Z ',
            [vim.diagnostic.severity.WARN] = '�* ',
            [vim.diagnostic.severity.INFO] = '�� ',
            [vim.diagnostic.severity.HINT] = '�6 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            return diagnostic.message
          end,
        },
      })

      -- ========================================================================
      -- LSP Capabilities
      -- ========================================================================
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- ========================================================================
      -- Language Servers
      -- ========================================================================
      local servers = {
        -- Web development
        html = {},
        cssls = {},
        tsserver = {},
        emmet_ls = {},

        -- Julia
        julials = {},

        -- LaTeX
        ltex = {
          settings = {
            ltex = {
              language = 'en-US',
              latex = { commands = { ['\\cite'] = 'ignore' } },
            },
          },
        },

        -- Python (Ruff)
        ruff = {
          settings = {
            ruff = {
              lint = {
                run = 'onSave', -- Changed from onType for better performance
              },
              organizeImports = true,
              fixAll = true,
              format = {
                args = { '--preview' },
              },
              path = { 'ruff' },
              select = {
                'I',
                'N',
                'UP',
                'B',
                'A',
                'C4',
                'SIM',
                'PIE',
                'RUF',
              },
              ignore = {
                'ANN',
              },
              target = 'py313',
            },
          },
        },

        -- Rust
        rust_analyzer = {},

        -- Lua
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },
      }

      -- ========================================================================
      -- Mason Setup
      -- ========================================================================
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua',
        'ruff',
      })
      require('mason-tool-installer').setup({ ensure_installed = ensure_installed })

      require('mason-lspconfig').setup({
        ensure_installed = {},
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      })
    end,
  },
}
