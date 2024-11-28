-- Astro
---@type LazySpec
local spec = {
  "wuelnerdotexe/vim-astro",
  ft = { "astro" },
  init = function()
    vim.g.astro_typescript = "enable"
    vim.g.astro_stylus = "enable"
  end,
}

return spec
