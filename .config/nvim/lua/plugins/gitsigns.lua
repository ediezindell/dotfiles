-- Gitの変更状況をエディタ上に表示する
return {
  "lewis6991/gitsigns.nvim",
  event = "BufEnter",
  config = function()
    require("gitsigns").setup({
      numhl = true, -- 行数表示ハイライト
      linehl = true, -- 行全体ハイライト
      -- word_diff = true,
    })
  end,
}
