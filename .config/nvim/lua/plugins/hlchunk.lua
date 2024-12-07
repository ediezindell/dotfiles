-- インデントを可視化する
---@type LazySpec
local spec = {
  "shellRaining/hlchunk.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    chunk = {
      enable = true,
      style = {
        { fg = "#9e86c8" },
        { fg = "#f92472" },
      },
      delay = 0,
    },
  },
}

return spec
