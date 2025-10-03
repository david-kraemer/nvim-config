--[[
  plugins/lang/julia.lua

  Purpose: Julia language support

  Julia tools:
    - julia-vim: Syntax highlighting and basic Julia support

  Organization:
    - Julia plugin configuration
    - Julia-specific settings

  Extension:
    - Add Julia development tools here
    - Julia LSP (julials) is configured in lsp.lua
    - Buffer-local Julia settings would go in after/ftplugin/julia.lua

  Note: The Julia LSP server provides most functionality (completion,
  go-to-definition, etc.). This plugin provides syntax highlighting
  and Julia-specific editing features.
--]]

return {
  -- ============================================================================
  -- Julia Language Support
  -- ============================================================================
  -- Note: Disabled by default. Uncomment if you actively use Julia.
  -- The plugin has aggressive autocommands that can slow startup.

  -- {
  --   'JuliaEditorSupport/julia-vim',
  --   ft = 'julia',
  --   init = function()
  --     vim.g.latex_to_unicode_auto = 0
  --   end,
  -- },
}
