---@type LazySpec
local spec = {
  "ediezindell/denops-copy-md-codeblock.vim",
  dependencies = {
    "vim-denops/denops.vim",
  },
  event = "BufEnter",
}
return spec
