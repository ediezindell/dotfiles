-- display git status
return {
  "lewis6991/gitsigns.nvim",
  -- event = "VimEnter",
  config = function()
    require("gitsigns").setup({
      numhl = true, -- 行数表示ハイライト
      linehl = true, -- 行全体ハイライト
      -- word_diff = true,
    })
  end,
}
