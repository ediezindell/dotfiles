---@type LazySpec
local spec = {
  "ediezindell/denops-colorscheme.vim",
  init = function()
    vim.g.denops_colorscheme_disable_default_scheme = 1
  end,
  keys = {
    { "[c", "<Cmd>NextColor<CR>", desc = "next colorscheme" },
    { "]c", "<Cmd>PrevColor<CR>", desc = "prev colorscheme" },
  },
  dependencies = {
    "vim-denops/denops.vim",
  },
  event = "BufEnter",
}
return spec
