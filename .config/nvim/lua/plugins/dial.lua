--- C-a/C-x の拡張
---@type LazySpec
local spec = {
  "monaqa/dial.nvim",
  event = "BufEnter",
  keys = {
    {
      "<C-a>",
      function()
        require("dial.map").manipulate("increment", "normal")
      end,
    },
    {
      "<C-x>",
      function()
        require("dial.map").manipulate("decrement", "normal")
      end,
    },
    {
      "g<C-a>",
      function()
        require("dial.map").manipulate("increment", "gnormal")
      end,
    },
    {
      "g<C-x>",
      function()
        require("dial.map").manipulate("decrement", "gnormal")
      end,
    },
  },
  config = function()
    local augend = require("dial.augend")
    require("dial.config").augends:register_group({
      -- default augends used when no group name is specified
      default = {
        augend.integer.alias.decimal,  -- nonnegative decimal number (0, 1, 2, 3, ...)
        augend.constant.alias.bool,    -- boolean value (true <-> false)
        augend.date.alias["%Y/%m/%d"], -- date (2022/02/19, etc.)
      },
    })
  end,
}

return spec
