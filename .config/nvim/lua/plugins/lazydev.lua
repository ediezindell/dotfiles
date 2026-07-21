---@type LazySpec
local spec = {
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
    library = {
      { path = "lazy.nvim", words = { "LazySpec", "Lazy" } },
    },
  },
}

return spec
