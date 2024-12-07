-- C-hjklでWindow移動
NormalKeymap("<C-h>", "<C-w>h", "move left")
NormalKeymap("<C-j>", "<C-w>j", "move down")
NormalKeymap("<C-k>", "<C-w>k", "move up")
NormalKeymap("<C-l>", "<C-w>l", "move right")

-- Esc2回でハイライト解除
CommandKeymap("<Esc><Esc>", "set nohlsearch", "no highlight")

-- Yで行末までヤンク
NormalKeymap("Y", "y$", "yank to EOL")

-- split view
CommandKeymap("<space>ss", "split", "split") -- 上下
CommandKeymap("<space>sv", "vsplit", "vsplit") -- 左右

-- クリップボードの内容でバッファを置換
CommandKeymap("<space><C-v>", [[%d | normal! "+P]], "Replace buffer with clipboard contents")

-- insert mode中にTabでインデント
InsertKeymap("<Tab>", "<C-t>", "indent")
InsertKeymap("<S-Tab>", "<C-d>", "indent")

---@see https://zenn.dev/vim_jp/articles/2024-06-05-vim-middle-class-features#引用符で囲まれた箇所全体を選択する
for _, quote in ipairs({ '"', "'", "`" }) do
  MotionKeymap("a" .. quote, "2i" .. quote, "引用符で囲まれた箇所全体を選択する")
end

MotionKeymap("i<space>", "iW", "スペースで囲われた範囲を選択する")

VisualKeymap("y", "mzy`z", "Visual コピー時にカーソル位置を保存")
VisualKeymap("p", "P", "Visual ペースト時にレジスタの変更を防止")

VisualKeymap("<", "<gv", "Visual 選択時に連続してインデント操作")
VisualKeymap(">", ">gv", "Visual 選択時に連続してインデント操作")

NormalKeymap("/", [[/\v]], "very magicフラグを入れた状態で検索開始")

NormalKeymap("<S-m>", "`", "jump to mark")

CommandKeymap("g/", "lua SearchByClipboard()", "クリップボードの内容で検索する")
