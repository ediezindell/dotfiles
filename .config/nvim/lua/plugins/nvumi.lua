---@type LazySpec
local spec = {
  "josephburgess/nvumi",
  dependencies = { "folke/snacks.nvim" },
  event = "BufEnter",
  opts = {
    virtual_text = "newline", -- or "inline"
    prefix = " 🚀 ", -- prefix shown before the output
    date_format = "iso", -- or: "uk", "us", "long"
    keys = {
      run = "<CR>", -- run/refresh calculations
      reset = "R", -- reset buffer
      yank = "<leader>y", -- yank output of current line
      yank_all = "<leader>Y", -- yank all outputs
    },
    custom_conversions = {
      -- see section below
    },
  },
}

return spec
