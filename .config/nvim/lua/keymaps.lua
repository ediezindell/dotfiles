-- 簡易Window移動
NormalKeymap("<C-h>", "<C-w>h")
NormalKeymap("<C-j>", "<C-w>j")
NormalKeymap("<C-k>", "<C-w>k")
NormalKeymap("<C-l>", "<C-w>l")

-- Esc2回でハイライト解除
NormalKeymap("<Esc><Esc>", "<Cmd>set nohlsearch<CR>")

-- split view
NormalKeymap("<leader>ss", "<Cmd>split<CR>") -- 上下
NormalKeymap("<leader>sv", "<Cmd>vsplit<CR>") -- 左右

-- yank from cursor to end of line
NormalKeymap("Y", "y$")

-- buffer
NormalKeymap("<M-h>", "<Cmd>bprev<CR>")
NormalKeymap("<M-l>", "<Cmd>bnext<CR>")

-- disable arrow keys
local arrowKeys = { "<Up>", "<Down>", "<Left>", "<Right>" }
for _, key in ipairs(arrowKeys) do
  vim.keymap.set({ "n", "v" }, key, "", {})
end
