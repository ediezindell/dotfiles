-- ターミナルを表示する
---@type LazySpec
local spec = {
  "akinsho/toggleterm.nvim",
  version = "*",
  event = "VeryLazy",
  opts = {
    insert_mappings = true,
  },
  keys = { {
    "<space>t",
    "<Cmd>ToggleTerm<CR>",
  } },
}

return spec
