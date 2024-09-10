-- color theme
---@type LazySpec
local spec = {
  "tanvirtin/monokai.nvim",
  event = "VeryLazy",
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
        sassId = getFg(palette.green),
        HighlightUndo = { fg = palette.white, bg = palette.orange },
        HighlightRedo = { fg = palette.white, bg = palette.orange },
      },
    })
  end,
}

return spec
