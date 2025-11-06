---@type LazySpec
local spec = {
  "clxmochamalefic/lspctl.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "neovim/nvim-lspconfig",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  lazy = true,
  cmd = { "Lspctl" },
  opts = {
    manager = "mason", -- default: "lspconfig", support: "lspconfig"|"mason"
    keymap = {
      info = "h",
      start = "s",
      stop = "x",
      restart = "r",
      close = "q",
    },
  },
  config = function(_, opts)
    require("lspctl").setup(opts)
  end,
}

return spec
