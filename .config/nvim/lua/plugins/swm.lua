---@type LazySpec
local spec = {
  "hrsh7th/nvim-swm",
  event = "BufEnter",
  config = function()
    local swm = require("swm")
    vim.keymap.set({ "n", "x" }, "<C-h>", swm.h)
    vim.keymap.set({ "n", "x" }, "<C-j>", swm.j)
    vim.keymap.set({ "n", "x" }, "<C-k>", swm.k)
    vim.keymap.set({ "n", "x" }, "<C-l>", swm.l)
  end,
}

return spec
