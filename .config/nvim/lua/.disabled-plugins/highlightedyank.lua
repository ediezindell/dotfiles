-- ヤンクした箇所をハイライトする
---@type LazySpec
local spec = {
  "machakann/vim-highlightedyank",
  init = function()
    vim.g.highlightedyank_highlight_duration = 300
  end,
  event = "BufEnter",
}

return spec
