---@type LazySpec
local spec = {
  "ediezindell/denops-mode-change-notify.vim",
  dependencies = {
    "vim-denops/denops.vim",
  },
  event = "BufEnter",
}
return spec
