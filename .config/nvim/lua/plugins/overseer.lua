---@type LazySpec
local spec = {
  "stevearc/overseer.nvim",
  event = "VeryLazy",
  keys = {
    { "<space>or", "<Cmd>OverseerRun<CR>", desc = "OverseerRun" },
    { "<space>oo", "<Cmd>OverseerOpen<CR>", desc = "OverseerOpen" },
  },
  opts = {},
}

return spec
