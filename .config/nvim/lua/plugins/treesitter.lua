---@type LazySpec[]
local spec = {
  "romus204/tree-sitter-manager.nvim",
  lazy = false,
  config = function()
    require("tree-sitter-manager").setup({
      ensure_installed = "all",
    })
  end,
}

return spec
