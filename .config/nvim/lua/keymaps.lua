-- C-hjklでWindow移動
NormalKeymap("<C-h>", "<C-w>h", "move left")
NormalKeymap("<C-j>", "<C-w>j", "move down")
NormalKeymap("<C-k>", "<C-w>k", "move up")
NormalKeymap("<C-l>", "<C-w>l", "move right")

-- Esc2回でハイライト解除
NormalCommandKeymap("<Esc><Esc>", "set nohlsearch", "no highlight")

-- Yで行末までヤンク
NormalKeymap("Y", "y$", "yank to EOL")

-- split view
NormalCommandKeymap("<leader>ss", "split", "split") -- 上下
NormalCommandKeymap("<leader>sv", "vsplit", "vsplit") -- 左右

-- クリップボードの内容でバッファを置換
NormalCommandKeymap("<leader><C-v>", [[%d | normal! "+P]], "Replace buffer with clipboard contents")

-- 方向キー無効化
local arrowKeys = { "<Up>", "<Down>", "<Left>", "<Right>" }
for _, key in ipairs(arrowKeys) do
  vim.keymap.set({ "n", "v" }, key, "", {})
end

-- insert mode中にTabでインデント
InsertKeymap("<Tab>", "<C-t>", "indent")
InsertKeymap("<S-Tab>", "<C-d>", "indent")

---@see https://zenn.dev/vim_jp/articles/2024-06-05-vim-middle-class-features
for _, quote in ipairs({ '"', "'", "`" }) do
  vim.keymap.set({ "x", "o" }, "a" .. quote, "2i" .. quote)
end
