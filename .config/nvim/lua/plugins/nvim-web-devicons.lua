return {
  'nvim-tree/nvim-web-devicons',
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
          icon = 'ﯤ',
          color = '#3178C6'
        }
      },
      color_icons = true,
      default = true,
    }
  end
}
