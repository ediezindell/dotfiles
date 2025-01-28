---@type LazySpec
local spec = {
  "atusy/jab.nvim",
  dependencies = {
    "lambdalisue/vim-kensaku",
  },
  init = function()
    vim.keymap.set({ "n", "x", "o" }, ";", function()
      return require("jab").jab_win()
    end, { expr = true })
  end,
  event = "BufEnter",
}

return spec
