---@type LazySpec
local spec = {
  enabled = true,
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    { "github/copilot.vim" },
    { "nvim-lua/plenary.nvim", branch = "master" },
  },
  build = "make tiktoken",
  opts = {
    prompts = require("gal"),
  },
  lazy = false,
}

return spec
