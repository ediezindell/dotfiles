-- status line customize
return {
  "nvim-lualine/lualine.nvim",
  requires = "kyazdani42/nvim-web-devicons",
  -- event = "VimEnter",
  config = function()
    require("plugins/config/lualine")
  end,
}
