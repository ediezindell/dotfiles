-- color theme
---@type LazySpec
local spec = {
  "tanvirtin/monokai.nvim",
  event = "LspAttach",
  config = function()
    local monokai = require("monokai")
    local palette = monokai.classic
    local getFg = function(color)
      return { fg = color }
    end
    monokai.setup({
      italics = false,
      custom_hlgroups = {
        Structure = getFg(palette.green),
        typescriptImport = getFg(palette.pink),
        typescriptExport = getFg(palette.aqua),
        typescriptVariable = getFg(palette.aqua),
        tsxIntrinsicTagName = getFg(palette.pink),
      },
    })
  end,
}

return spec
