--- ファイルパスをコピー
---@type LazySpec
local spec = {
  "ediezindell/denops-copy-path.vim",
  dependencies = {
    "vim-denops/denops.vim",
  },
  keys = {
    { "<space>cp", "<Cmd>CopyPath<CR>", desc = "Copy file path" },
  },
  event = "BufEnter",
}
return spec
