-- nvim-tree用のアイコンセット
return {
  'nvim-tree/nvim-web-devicons',
  -- event = "VimEnter",
  config = function()
    require('nvim-web-devicons').setup {
      override = {
        zsh = {
          icon = "",
          color = "#428850",
          cterm_color = "65",
          name = "Zsh"
        },
        ts = {
          icon = '󰛦',
          color = '#3178C6'
        }
      },
      color_icons = true,
      default = true,
    }
  end,
}
