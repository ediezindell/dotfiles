
return {
  'nvim-treesitter/nvim-treesitter',
  run = ':TSUpdate',
  config = function()
    require("nvim-treesitter").setup({
      highlight = {
        enable = true,
      },
      ensure_installed = "maintained",
    })
  end,
}
