-- タブバーを表示
---@type LazySpec
local spec = {
  "romgrk/barbar.nvim",
  dependencies = {
    "lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
    "nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
  },
  event = "BufEnter",
  init = function()
    vim.g.barbar_auto_setup = false
    CommandKeymap("[b", "BufferPrevious", "BufferPrevious (barbar)")
    CommandKeymap("]b", "BufferNext", "BufferNext (barbar)")
    CommandKeymap("<A-w>", "BufferClose", "")
  end,
  opts = {},
}

return spec
