-- Lisp-style indentation (same as Racket)
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.expandtab = true

-- Force K to use LSP hover instead of keywordprg
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = true, desc = 'LSP Hover' })

-- Enable Lisp indentation mode
vim.opt_local.lisp = true
vim.opt_local.lispwords:append {
  'define',
  'define-syntax',
  'lambda',
  'let',
  'let*',
  'letrec',
  'let-values',
  'call-with-current-continuation',
  'call/cc',
  'cond',
  'case',
  'when',
  'unless',
  'syntax-rules',
}
