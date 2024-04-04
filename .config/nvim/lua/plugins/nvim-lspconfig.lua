return {
  "neovim/nvim-lspconfig",
  event = "VimEnter",
  config = function()
    require("lspconfig")
  end,
}
