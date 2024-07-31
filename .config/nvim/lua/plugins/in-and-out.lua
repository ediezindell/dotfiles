---@type LazySpec
local spec = {
  "ysmb-wtsg/in-and-out.nvim",
  keys = {
    {
      "<C-CR>",
      function()
        require("in-and-out").in_and_out()
      end,
      mode = "i",
    },
  },
}

return spec
