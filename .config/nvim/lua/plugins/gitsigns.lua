-- display git status
return {
  "lewis6991/gitsigns.nvim",
  event = "VimEnter",
  config = function()
    require('gitsigns').setup({
      numhl = true,
      -- linehl = true,
      -- word_diff = true,
    })
  end,
}
