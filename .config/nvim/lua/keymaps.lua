NormalKeymap("Y", "y$", "yank to EOL")
NormalKeymap("/", [[/\v]], "very magicフラグを入れた状態で検索開始")
NormalKeymap("<S-m>", "`", "jump to mark")

CommandKeymap("<Esc><Esc>", "set nohlsearch", "no highlight")
CommandKeymap("g/", "lua SearchByClipboard()", "クリップボードの内容で検索する")
CommandKeymap("<space>ss", "split", "上下分割")
CommandKeymap("<space>sv", "vsplit", "左右分割")
CommandKeymap("<space><C-v>", [[%d | normal! "+P]], "クリップボードの内容でバッファを置換")
CommandKeymap("<space>bd", "%bd|e#|bd#", "現在のバッファ以外を閉じる")

VisualKeymap("y", "mzy`z", "コピー時にカーソル位置を保存")
VisualKeymap("p", "P", "ペースト時にレジスタの変更を防止")
VisualKeymap("<", "<gv", "連続してインデント操作")
VisualKeymap(">", ">gv", "連続してインデント操作")

TermKeymap("<esc><esc>", [[<C-\><C-n>]], "Normal mode")

-- InsertKeymap("<Tab>", "<C-t>", "字下げ")
-- InsertKeymap("<S-Tab>", "<C-d>", "字上げ")

---@see https://zenn.dev/vim_jp/articles/2024-06-05-vim-middle-class-features#引用符で囲まれた箇所全体を選択する
for _, quote in ipairs({ '"', "'", "`" }) do
  MotionKeymap("a" .. quote, "2i" .. quote, "引用符で囲まれた箇所全体を選択する")
end
MotionKeymap("i<space>", "iW", "スペースで囲われた範囲を選択する")
MotionKeymap("a<space>", "2iW", "スペースで囲われた範囲を選択する")

NormalKeymap("<space>bc", function()
  local ftype = vim.api.nvim_eval("&filetype")
  vim.cmd(string.format(
    [[
    vsplit
    wincmd l
    enew
    setlocal buftype=nofile | set filetype=%s
    normal! P
    diffthis
    wincmd h | diffthis
    ]],
    ftype
  ))
end, "クリップボードの内容と比較")
