return {
  "tani/dmacro.nvim",
  config = function()
    require("dmacro").setup({
      dmacro_key = "<C-t>",
    })
  end,
}
