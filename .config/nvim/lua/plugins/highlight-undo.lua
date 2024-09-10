---@type LazySpec
local spec = {
  "tzachar/highlight-undo.nvim",
  event = "VeryLazy",
  config = function()
    require("highlight-undo").setup({
      duration = 300,
      undo = {
        hlgroup = "HighlightUndo",
      },
      redo = {
        hlgroup = "HighlightRedo",
      },
    })
  end,
}

return spec
