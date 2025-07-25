-- タブバーを表示
---@type LazySpec
local spec = {
  "romgrk/barbar.nvim",
  dependencies = {
    "lewis6991/gitsigns.nvim",     -- OPTIONAL: for git status
    "nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
  },
  event = "BufEnter",
  keys = {
    { "[b",        "<Cmd>BufferPrevious<CR>",                   desc = "BufferPrevious (barbar)" },
    { "]b",        "<Cmd>BufferNext<CR>",                       desc = "BufferNext (barbar)" },
    { "<A-w>",     "<Cmd>BufferClose<CR>",                      desc = "BufferClose (barbar)" },
    { "<space>bp", "<Cmd>BufferPin<CR>",                        desc = "BufferPin (barbar)" },
    { "<space>bD", "<Cmd>BufferCloseAllButCurrentOrPinned<CR>", desc = "BufferCloseAllButCurrentOrPinned (barbar)" },
  },
  init = function()
    vim.g.barbar_auto_setup = false
  end,
  opts = {
    highlight_alternate = true,
    icons = {
      separator = { left = "" },
      pinned = { button = "", filename = true },
    },
    auto_hide = true,
  },
}

return spec
