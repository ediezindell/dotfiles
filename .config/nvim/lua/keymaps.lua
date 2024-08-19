-- C-hjklでWindow移動
NormalKeymap("<C-h>", "<C-w>h")
NormalKeymap("<C-j>", "<C-w>j")
NormalKeymap("<C-k>", "<C-w>k")
NormalKeymap("<C-l>", "<C-w>l")

-- Esc2回でハイライト解除
NormalCommandKeymap("<Esc><Esc>", "set nohlsearch")

-- Yで行末までヤンク
NormalKeymap("Y", "y$")

-- split view
NormalCommandKeymap("<leader>ss", "split") -- 上下
NormalCommandKeymap("<leader>sv", "vsplit") -- 左右

-- 方向キー無効化
local arrowKeys = { "<Up>", "<Down>", "<Left>", "<Right>" }
for _, key in ipairs(arrowKeys) do
  vim.keymap.set({ "n", "v" }, key, "", {})
end

InsertKeymap("<Tab>", "<C-t>")
InsertKeymap("<S-Tab>", "<C-d>")
