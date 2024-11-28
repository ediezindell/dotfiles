---@type LazySpec
local spec = {
  "jinh0/eyeliner.nvim",
  event = "VeryLazy",
  opts = {
    highlight_on_key = true,
    dim = true, -- 他の文字を暗くする
    default_keymaps = true,
  },
}

return spec
