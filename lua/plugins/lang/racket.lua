--[[
  plugins/lang/racket.lua

  Purpose: Racket and Scheme language support

  Provides:
    - REPL integration via Conjure (supports Racket, Chez, Guile, MIT Scheme)
    - Structural editing via paredit (slurp, barf, raise, splice)

  Prerequisites:
    - Racket LSP: raco pkg install racket-langserver
    - Scheme REPL: configure g:conjure#client#scheme#stdio#command

  See:
    - :help conjure
    - :help nvim-paredit
--]]

return {
  -- ============================================================================
  -- Conjure: Interactive REPL
  -- ============================================================================
  {
    'Olical/conjure',
    ft = { 'racket', 'scheme' },
    init = function()
      -- Disable default HUD mapping (conflicts with window navigation)
      vim.g['conjure#mapping#doc_word'] = false

      -- Racket: use racket REPL
      vim.g['conjure#client#racket#stdio#command'] = 'racket -i'

      -- Scheme: default to Chez (override for Guile/MIT-Scheme as needed)
      vim.g['conjure#client#scheme#stdio#command'] = 'chez'
    end,
  },

  -- ============================================================================
  -- Paredit: Structural Editing
  -- ============================================================================
  {
    'julienvincent/nvim-paredit',
    ft = { 'racket', 'scheme', 'lisp', 'clojure' },
    opts = {
      keys = {
        -- Slurp/barf (extend/shrink s-expression)
        ['>)'] = { 'slurp_forwards', 'Slurp forwards' },
        ['<('] = { 'slurp_backwards', 'Slurp backwards' },
        ['>('] = { 'barf_forwards', 'Barf forwards' },
        ['<)'] = { 'barf_backwards', 'Barf backwards' },

        -- Raise (replace parent with current element)
        ['<localleader>r'] = { 'raise_element', 'Raise element' },
        ['<localleader>R'] = { 'raise_form', 'Raise form' },

        -- Splice (unwrap parent)
        ['<localleader>s'] = { 'splice_sexp', 'Splice sexp' },
      },
    },
  },
}
