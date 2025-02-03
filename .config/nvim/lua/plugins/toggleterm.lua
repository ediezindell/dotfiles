-- ターミナルを表示する
---@type LazySpec
local spec = {
  "akinsho/toggleterm.nvim",
  version = "*",
  cmd = "ToggleTerm",
  opts = {
    insert_mappings = true,
  },
  keys = {
    {
      "<space>t",
      "<Cmd>ToggleTerm<CR>",
      desc = "toggle terminal",
    },
  },
}

return spec
