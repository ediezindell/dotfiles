--- ファイル内容をMarkdownのコードブロック形式でコピー
---@type LazySpec
local spec = {
  "ediezindell/denops-copy-md-codeblock.vim",
  dependencies = {
    "vim-denops/denops.vim",
  },
  keys = {
    { "<space>cP", "<Cmd>CopyCode<CR>", desc = "Copy file path" },
  },
  event = "BufEnter",
}
return spec
