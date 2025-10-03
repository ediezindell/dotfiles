--- font-sizeのpx指定をremへ変換
---@type LazySpec
local spec = {
  "ediezindell/denops-px2rem.vim",
  dependencies = {
    "vim-denops/denops.vim",
  },
  event = "BufEnter",
}
return spec
