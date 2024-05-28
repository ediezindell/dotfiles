-- ステータスラインをカスタマイズする
return {
  "nvim-lualine/lualine.nvim",
  requires = {
    "kyazdani42/nvim-web-devicons",
  },
  event = "VimEnter",
  config = function()
    require("config.lualine") -- 外部設定ファイルの読み込み
  end,
}
