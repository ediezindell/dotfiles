-- ステータスラインをカスタマイズする
---@type LazySpec
local spec = {
  "nvim-lualine/lualine.nvim",
  requires = {
    "kyazdani42/nvim-web-devicons",
  },
  event = "VeryLazy",
  config = function()
    require("config.lualine") -- 外部設定ファイルの読み込み
  end,
}

return spec
