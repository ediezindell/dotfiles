---@type LazySpec
local spec = {
  "kazhala/close-buffers.nvim",
  event = "BufEnter",
  keys = {
    {
      "<space>bw",
      function()
        require("close_buffers").wipe({ type = "other" })
      end,
      desc = "wipe other buffers",
    },
  },
}

return spec
