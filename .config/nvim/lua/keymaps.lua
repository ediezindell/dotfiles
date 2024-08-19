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

-- 方向キー無効化
local arrowKeys = { "<Up>", "<Down>", "<Left>", "<Right>" }
for _, key in ipairs(arrowKeys) do
  vim.keymap.set({ "n", "v" }, key, "", {})
end

InsertKeymap("<Tab>", "<C-t>", "indent")
InsertKeymap("<S-Tab>", "<C-d>", "indent")
