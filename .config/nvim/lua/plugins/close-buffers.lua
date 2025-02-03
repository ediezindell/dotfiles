---@type LazySpec
local spec = {
  "kazhala/close-buffers.nvim",
  event = "BufEnter",
  keys = {
    { "<space>bw", "<Cmd>lua require('close_buffers').wipe({ type = 'other' })<CR>", desc = "wipe other buffers" },
  },
}

return spec
