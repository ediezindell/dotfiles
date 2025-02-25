---@type LazySpec
local spec = {
  "atusy/jab.nvim",
  dependencies = {
    "lambdalisue/vim-kensaku",
  },
  init = function()
    vim.keymap.set({ "n", "x", "o" }, ";", function()
      return require("jab").jab_win({
        "a",
        "s",
        "d",
        "f",
        "h",
        "j",
        "k",
        "l",
      })
    end, { expr = true })
  end,
  event = "BufEnter",
}

return spec
