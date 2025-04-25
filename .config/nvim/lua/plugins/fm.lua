-- Gituiをnvim上で使えるようにする
---@type LazySpec
local spec = {
  "is0n/fm-nvim",
  cmd = {
    "Gitui",
    "Lazygit",
  },
  keys = {
    { "<Up>",   "<Cmd>Gitui<CR>",   desc = "open gitui" },
    { "<Down>", "<Cmd>Lazygit<CR>", desc = "open lazygit" },
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
