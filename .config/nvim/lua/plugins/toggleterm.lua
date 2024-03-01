return {
  -- ターミナル表示
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      insert_mappings = true,
    })
  end,
}
