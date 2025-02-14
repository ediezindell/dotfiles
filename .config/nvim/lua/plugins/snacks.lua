--@type LazySpec
local spec = {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    image = {},
    picker = {
      formatters = { file = { truncate = 200 } },
      layout = {
        cycle = true,
      },
    },
    explorer = {
      replace_netrw = false, -- oil.nvim と競合するため無効化
    },
  },
  keys = function()
    local pickerConfig = require("plugins.config.snacks.picker")
    local keys = pickerConfig.keys
    return keys
  end,
}

return spec
