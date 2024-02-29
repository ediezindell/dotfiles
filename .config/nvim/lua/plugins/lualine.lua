-- status line customize
return {
  "nvim-lualine/lualine.nvim",
  requires = "kyazdani42/nvim-web-devicons",
  -- event = "VimEnter",
  config = function()
    require("lualine").setup({
      options = { theme = "iceberg_dark" },
    })
  end,
}
