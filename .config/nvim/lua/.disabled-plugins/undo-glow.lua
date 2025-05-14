---@type LazySpec
local spec = {
  "y3owk1n/undo-glow.nvim",
  event = "BufEnter",
  opts = {
    animation = {
      enabled = true,
      duration = 500,
    },
  },
  config = function(_, opts)
    NormalKeymap("u", function()
      require("undo-glow").undo(opts)
    end, "undo")
    NormalKeymap("<C-r>", function()
      require("undo-glow").redo(opts)
    end, "redo")
  end,
}

return spec
