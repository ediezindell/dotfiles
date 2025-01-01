---@type LazySpec
local spec = {
  "clxmochamalefic/lspctl.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  cmd = { "Lspctl" },
  keys = {
    { "<space>lc", "<Cmd>Lspctl<CR>", desc = "lspctl" },
  },
  opt = {
    info = "h",
    start = "s",
    stop = "x",
    restart = "r",
    close = "q",
  },
  config = function(_, opt)
    require("lspctl").setup(opt)
  end,
}

return spec
