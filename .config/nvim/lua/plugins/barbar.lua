-- タブバーを表示
---@type LazySpec
local spec = {
  "romgrk/barbar.nvim",
  dependencies = {
    "lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
    "nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
  },
  event = "BufEnter",
  keys = {
    { "[b", "<Cmd>BufferPrevious<CR>", desc = "BufferPrevious (barbar)" },
    { "]b", "<Cmd>BufferNext<CR>", desc = "BufferNext (barbar)" },
    { "<A-w>", "<Cmd>BufferClose<CR>", desc = "BufferClose (barbar)" },
  },
  init = function()
    vim.g.barbar_auto_setup = false
  end,
  opts = {},
}

return spec
