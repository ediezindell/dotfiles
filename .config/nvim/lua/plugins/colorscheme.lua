-- color theme

local getFg = function(color)
  return { fg = color }
end
---@diagnostic disable-next-line: unused-local
local getBg = function(color)
  return { bg = color }
end

local getOpts = function(palette)
  return {
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
  }
end

---@type LazySpec[]
local spec = {
  {
    "tanvirtin/monokai.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local monokai = require("monokai")
      local opts = getOpts(monokai.classic)
      monokai.setup(opts)
    end,
  },
  {
    "sainnhe/sonokai",
    lazy = false,
    priority = 1001,
    init = function()
      vim.g.sonokai_enable_italic = false
    end,
    config = function()
      vim.cmd.colorscheme("sonokai")
    end,
  },
}

return spec
