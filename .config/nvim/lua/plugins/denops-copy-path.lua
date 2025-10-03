--- ファイルパスをコピー
---@type LazySpec
local spec = {
  "ediezindell/denops-copy-path.vim",
  dependencies = {
    "vim-denops/denops.vim",
  },
  event = "BufEnter",
}
return spec
