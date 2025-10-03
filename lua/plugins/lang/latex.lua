--[[
  plugins/lang/latex.lua

  Purpose: LaTeX-specific plugins and configuration

  LaTeX tools:
    - VimTeX: LaTeX compilation, viewing, and navigation
    - telescope-bibtex: BibTeX citation search
    - vim-table-mode: Table editing for LaTeX/Markdown

  Organization:
    - VimTeX configuration
    - Bibliography tools
    - Table editing
    - LaTeX-specific keymaps

  Extension:
    - Add LaTeX development tools here
    - LaTeX LSP (ltex) is configured in lsp.lua
    - Buffer-local LaTeX settings go in after/ftplugin/tex.lua

  VimTeX Features:
    - Continuous compilation with latexmk
    - PDF viewing with Skim (macOS)
    - SyncTeX forward/backward search
    - Table of contents navigation
    - Error/warning quickfix
--]]

return {
  -- ============================================================================
  -- VimTeX (LaTeX compilation and tooling)
  -- ============================================================================
  {
    'lervag/vimtex',
    ft = { 'tex', 'latex', 'bib' }, -- Load only for LaTeX files
    init = function()
      -- PDF viewer (Skim on macOS)
      vim.g.vimtex_view_method = 'skim'

      -- Compiler settings
      vim.g.vimtex_compiler_method = 'latexmk'
      vim.g.vimtex_compiler_latexmk = {
        continuous = 1,
        callback = 1,
        build_dir = 'build',
        options = {
          '-pdf',
          '-pdflatex="pdflatex -interaction=nonstopmode"',
          '-file-line-error',
          '-synctex=1',
        },
      }

      -- Disable quickfix auto-open
      vim.g.vimtex_quickfix_mode = 0

      -- Disable concealing
      vim.g.vimtex_syntax_conceal_disable = 1
    end,
    keys = {
      { '<leader>ll', '<cmd>VimtexCompile<CR>', desc = '[L]atex Compile' },
      { '<leader>lv', '<cmd>VimtexView<CR>', desc = '[L]atex View' },
      { '<leader>ls', '<cmd>VimtexStop<CR>', desc = '[L]atex Stop' },
      { '<leader>lc', '<cmd>VimtexClean<CR>', desc = '[L]atex Clean' },
      { '<leader>le', '<cmd>VimtexErrors<CR>', desc = '[L]atex Errors' },
      { '<leader>lt', '<cmd>VimtexTocToggle<CR>', desc = '[L]atex TOC' },
    },
  },

  -- ============================================================================
  -- BibTeX Citation Search
  -- ============================================================================
  {
    'nvim-telescope/telescope-bibtex.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    config = function()
      require('telescope').load_extension('bibtex')
      vim.keymap.set('n', '<leader>sb', '<cmd>Telescope bibtex<CR>', { desc = '[S]earch [B]ibliography' })
    end,
  },

  -- ============================================================================
  -- Table Mode (for LaTeX and Markdown tables)
  -- ============================================================================
  {
    'dhruvasagar/vim-table-mode',
    ft = { 'tex', 'markdown' },
    config = function()
      vim.g.table_mode_corner = '|'
      vim.keymap.set('n', '<leader>tm', '<cmd>TableModeToggle<CR>', { desc = '[T]able [M]ode' })
    end,
  },
}
