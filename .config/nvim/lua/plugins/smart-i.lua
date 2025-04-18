---@type LazySpec
local spec = {
  "yuki-yano/smart-i.nvim",
  event = "BufEnter",
  opts = {
    enable_i = false,
    enable_I = true,
    enable_a = true,
    enable_A = true,
  },
}

return spec
