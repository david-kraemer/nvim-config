return {
  'epwalsh/obsidian.nvim',
  version = '*', -- use latest version
  event = {
    'BufReadPre ' .. vim.fn.expand('~') .. '/Documents/krolson/**/*.md',
    'BufNewFile ' .. vim.fn.expand('~') .. '/Documents/krolson/**/*.md',
  },
  cmd = { 'ObsidianSearch', 'ObsidianNew', 'ObsidianQuickSwitch', 'ObsidianOpen', 'ObsidianToday' },
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  opts = {
    workspaces = {
      {
        name = 'krolson',
        path = '~/Documents/krolson/krolson',
      },
    },
  },
}
