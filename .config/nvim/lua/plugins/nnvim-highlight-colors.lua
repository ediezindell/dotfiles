---@type LazySpec
local spec = {
  "brenoprata10/nvim-highlight-colors",
  event = "LspAttach",
  config = function()
    require("nvim-highlight-colors").setup({})
  end,
}

return spec
