-- code highlight
return {
  'nvim-treesitter/nvim-treesitter',
  event = "VimEnter",
  run = ':TSUpdate',
  config = function()
    require("nvim-treesitter").setup({
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
      ensure_installed = "maintained",
    })
  end,
}
