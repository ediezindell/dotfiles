-- ヤンクした箇所をハイライトする
---@type LazySpec
local spec = {
  "machakann/vim-highlightedyank",
  config = function()
    vim.g.highlightedyank_highlight_duration = 300
  end,
  event = { "BufEnter", "BufNewFile" },
}

return spec
