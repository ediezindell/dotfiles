---@type LazySpec
local spec = {
  "wuelnerdotexe/vim-astro",
  ft = { "astro" },
  config = function()
    vim.g.astro_typescript = "enable"
    vim.g.astro_stylus = "enable"
  end,
}

return spec
