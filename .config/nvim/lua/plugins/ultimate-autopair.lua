---@type LazySpec
local spec = {
  "altermo/ultimate-autopair.nvim",
  event = { "InsertEnter" },
  opts = {
    cmap = false, -- コマンドラインで無効
  },
}

return spec
