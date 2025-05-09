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
      NonText = getFg(palette.grey),

      -- for plugins
      UgUndo = { fg = palette.white, bg = palette.orange }, -- undo-glow
      UgRedo = { fg = palette.white, bg = palette.orange }, -- undo-glow
      BufferCurrent = { bg = palette.pink }, -- barbar
      BufferCurrentMod = { bg = palette.pink, fg = palette.black }, -- barbar
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
  -- {
  --   "sainnhe/sonokai",
  --   lazy = false,
  --   priority = 1000,
  --   init = function()
  --     vim.g.sonokai_enable_italic = false
  --   end,
  --   config = function()
  --     vim.cmd.colorscheme("sonokai")
  --   end,
  -- },
  -- {
  --   "jsit/toast.vim",
  --   lazy = false,
  --   priority = 1000,
  -- },
}

return spec
