---@type LazySpec
local spec = {
  "hrsh7th/nvim-insx",
  event = "VeryLazy",
  config = function()
    -- local insx = require("insx")
    require("insx.preset.standard").setup()
  end,
}

return spec
