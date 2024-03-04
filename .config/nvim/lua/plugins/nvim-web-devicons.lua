-- nvim-tree用のアイコンセット
return {
  "nvim-tree/nvim-web-devicons",
  -- event = "VimEnter",
  config = function()
    require("nvim-web-devicons").setup({
      override_by_extension = {
        ["zsh"] = {
          icon = "",
          color = "#428850",
          cterm_color = "65",
          name = "Zsh",
        },
        ["ts"] = {
          icon = "󰛦",
          color = "#3178C6",
          cterm_color = "74",
          name = "Cts",
        },
      },
      color_icons = true,
      default = false,
    })
  end,
}
