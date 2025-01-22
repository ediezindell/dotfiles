-- ショートカットキーを表示する
---@type LazySpec
local spec = {
  "folke/which-key.nvim",
  event = "BufEnter",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  opts = {},
}

return spec
