--- `:q` で最後のバッファを閉じる際に確認ダイアログを表示
---@type LazySpec
local spec = {
  "ediezindell/confirm-quit.nvim",
  branch = "feature/custormize-for-me",
  event = "CmdlineEnter",
  opts = {},
}

return spec
