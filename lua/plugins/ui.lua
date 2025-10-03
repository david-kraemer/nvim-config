--[[
  plugins/ui.lua

  Purpose: UI and appearance plugins

  Plugins that affect visual appearance:
    - Colorschemes
    - Statusline (configured in mini.nvim in editor.lua)
    - Visual enhancements

  Organization:
    - Active colorscheme
    - Alternative colorschemes (commented)
    - UI enhancement plugins

  Extension:
    - To change colorscheme: uncomment desired scheme, comment current
    - Add new colorschemes as entries in the return array
    - Keep one colorscheme active (lazy = false, priority = 1000)
--]]

return {
  -- ============================================================================
  -- Colorscheme: Zenbones
  -- ============================================================================
  {
    'zenbones-theme/zenbones.nvim',
    dependencies = 'rktjmp/lush.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.zenbones_darken_comments = 45
      vim.cmd.colorscheme('zenbones')
    end,
  },

  -- Alternative colorschemes (add as needed):
  -- 'folke/tokyonight.nvim'
  -- 'ellisonleao/gruvbox.nvim'
}
