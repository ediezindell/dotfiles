-- %を拡張してHTMLタグなども対応
---@type LazySpec
local spec = {
  "andymass/vim-matchup",
  event = { "BufEnter", "BufNewFile" },
}

return spec
