return {
  "kkharji/lspsaga.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local saga = require("lspsaga")
    saga.init_lsp_saga({
      error_sign = "",
      warn_sign = "",
      hint_sign = "󰌵",
      infor_sign = "",
    })
  end,
}
