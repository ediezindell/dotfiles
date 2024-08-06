-- nvim-tree用のアイコンセット
---@type LazySpec
local spec = {
  "nvim-tree/nvim-web-devicons",
  event = "VimEnter",
  config = function()
    require("nvim-web-devicons").setup({
      -- アイコンの上書き
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

return spec
