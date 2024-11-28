-- Gituiをnvim上で使えるようにする
---@type LazySpec
local spec = {
  "is0n/fm-nvim",
  cmd = "Gitui",
  keys = {
    { "<Up>", "<Cmd>Gitui<CR>", desc = "Gitui" },
  },
  opts = {
    ui = {
      float = {
        border = "rounded",
      },
    },
  },
}

return spec
