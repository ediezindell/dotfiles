-- `-` でファイルエクスプローラーを開く
return {
  "stevearc/oil.nvim",
  opts = {},
  -- Optional dependencies
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("oil").setup({})
    local opts = {}
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", opts)
  end,
}
