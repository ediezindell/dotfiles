-- 右下に通知や進捗情報を表示
---@type LazySpec
local spec = {
  "j-hui/fidget.nvim",
  opts = {},
  event = { "BufEnter", "BufNewFile" },
}
return spec
