---@type LazySpec
local spec = {
  "ediezindell/denops-colorscheme.vim",
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
