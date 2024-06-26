-- code highlight
return {
  "nvim-treesitter/nvim-treesitter",
  event = { 'BufNewFile', 'BufRead' },
  run = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup({
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
      ensure_installed = "all",
    })
  end,
}
