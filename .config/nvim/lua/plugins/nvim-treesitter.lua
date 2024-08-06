-- code highlight
---@type LazySpec
local spec = {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufNewFile", "BufRead" },
  run = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup({
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
      ensure_installed = "all",
    })
  end,
}

return spec
