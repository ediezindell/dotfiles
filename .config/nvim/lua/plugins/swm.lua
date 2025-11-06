---@type LazySpec
local spec = {
  "hrsh7th/nvim-swm",
  event = "BufEnter",
  keys = {
    {
      "<C-h>",
      function()
        require("swm").h()
      end,
    },
    {
      "<C-j>",
      function()
        require("swm").j()
      end,
    },
    {
      "<C-k>",
      function()
        require("swm").k()
      end,
    },
    {
      "<C-l>",
      function()
        require("swm").l()
      end,
    },
  },
}

return spec
