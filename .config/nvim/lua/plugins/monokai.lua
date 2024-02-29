-- color theme
return {
  "tanvirtin/monokai.nvim",
  -- event = "VimEnter",
  config = function()
    require("monokai").setup({
      italics = false,
    })
  end,
}
