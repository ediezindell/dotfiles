---@type LazySpec
local spec = {
  enabled = true,
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    {
      "github/copilot.vim",
      init = function()
        vim.g.copilot_no_tab_map = true
        vim.g.copilot_filetypes = {
          gitcommit = true,
        }
      end,
      keys = {
        {
          "<C-e>",
          'copilot#Accept("")',
          mode = "i",
          expr = true,
          replace_keycodes = false,
          desc = "Accept Copilot suggestion",
        },
      },
    },
    { "nvim-lua/plenary.nvim", branch = "master" },
  },
  build = "make tiktoken",
  opts = {
    prompts = require("gal"),
  },
  lazy = false,
}

return spec
