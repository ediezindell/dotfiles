---@type LazySpec
local spec = {
  "tzachar/highlight-undo.nvim",
  event = "BufEnter",
  opts = {
    ignored_filetypes = {
      "neo-tree",
      "fugitive",
      "TelescopePrompt",
      "mason",
      "lazy",
    },
  },
}

return spec
