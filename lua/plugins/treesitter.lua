--[[
  plugins/treesitter.lua

  Purpose: Treesitter configuration for syntax highlighting and code understanding

  Treesitter provides:
    - Fast, accurate syntax highlighting
    - Code structure understanding
    - Text objects for functions, classes, etc.
    - Incremental selection

  Organization:
    - Core treesitter configuration
    - Language parsers to install
    - Text object configuration

  Extension:
    - Add languages to ensure_installed
    - Configure text object keymaps in textobjects section
    - See :help nvim-treesitter for additional modules
--]]

return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    main = 'nvim-treesitter.configs',
    opts = {
      -- ============================================================================
      -- Parser Installation
      -- ============================================================================
      ensure_installed = {
        -- Languages
        'julia',
        'rust',
        'python',
        'c',
        'bash',

        -- Web development
        'html',
        'css',
        'javascript',
        'typescript',
        'tsx',
        'json',

        -- Documentation
        'latex',
        'bibtex',
        'markdown',
        'markdown_inline',

        -- Config/scripting
        'lua',
        'vim',
        'vimdoc',
        'query',
        'diff',
        'luadoc',
      },

      -- Disable auto-install to avoid network calls at runtime
      -- Use :TSInstall <language> to add parsers as needed
      auto_install = false,

      -- ============================================================================
      -- Highlighting
      -- ============================================================================
      highlight = {
        enable = true,
        -- Some languages need vim's regex highlighting for indent rules
        additional_vim_regex_highlighting = { 'ruby' },
      },

      -- ============================================================================
      -- Indentation
      -- ============================================================================
      indent = {
        enable = true,
        disable = { 'ruby' },
      },

      -- ============================================================================
      -- Text Objects
      -- ============================================================================
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to matching text object
          keymaps = {
            -- Select function
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            -- Select class
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
        },
      },
    },
  },
}
