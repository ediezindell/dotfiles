---@type LazySpec
local spec = {
  "monaqa/dial.nvim",
  lazy = false,
  cmd = "LspAttach",
  keys = {
    { "<C-a>",  [[ <Cmd>lua require("dial.map").manipulate("increment", "normal")<CR> ]] },
    { "<C-x>",  [[ <Cmd>lua require("dial.map").manipulate("decrement", "normal")<CR> ]] },
    { "g<C-a>", [[ <Cmd>lua require("dial.map").manipulate("increment", "gnormal")<CR> ]] },
    { "g<C-x>", [[ <Cmd>lua require("dial.map").manipulate("decrement", "gnormal")<CR> ]] },
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
