---@type LazySpec
local spec = {
  "jinh0/eyeliner.nvim",
  event = { "BufEnter" },
  config = function()
    require("eyeliner").setup({
      highlight_on_key = true,
      dim = true,
      default_keymaps = true,
    })
  end,
}

return spec
