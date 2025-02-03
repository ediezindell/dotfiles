---@type LazySpec
local spec = {
  "hrsh7th/nvim-swm",
  event = "BufEnter",
  keys = {
    { "<C-h>", '<Cmd>lua require("swm").h()<CR>' },
    { "<C-j>", '<Cmd>lua require("swm").j()<CR>' },
    { "<C-k>", '<Cmd>lua require("swm").k()<CR>' },
    { "<C-l>", '<Cmd>lua require("swm").l()<CR>' },
  },
}

return spec
