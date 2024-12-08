-- code highlight
---@type LazySpec
local spec = {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufNewFile", "BufRead" },
  run = ":TSUpdate",
  opts = {
    highlight = {
      enable = true,
      disable = { "text" },
    },
    indent = {
      enable = true,
      disable = { "text" },
    },
    ensure_installed = "all",
  },
}

return spec
