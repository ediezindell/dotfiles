--- 行ジャンプ時のハイライト
---@type LazySpec
local spec = {
  "jinh0/eyeliner.nvim",
  event = "BufEnter",
  opts = {
    highlight_on_key = true,
    dim = true, -- 他の文字を暗くする
    default_keymaps = true,
  },
}

return spec
