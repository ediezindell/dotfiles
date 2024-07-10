local keymap = function(mode, lhs, rhs)
  local opts = { noremap = true, silent = true }
  vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
end
local normalKeymap = function(lhs, rhs)
  keymap("n", lhs, rhs)
end

-- 簡易Window移動
normalKeymap("<C-h>", "<C-w>h")
normalKeymap("<C-j>", "<C-w>j")
normalKeymap("<C-k>", "<C-w>k")
normalKeymap("<C-l>", "<C-w>l")

-- Esc2回でハイライト解除
normalKeymap("<Esc><Esc>", ":<C-u>set nohlsearch<CR>")

-- split view
normalKeymap("<leader>ss", ":split<CR>") -- 上下
normalKeymap("<leader>sv", ":vsplit<CR>") -- 左右

-- yank from cursor to end of line
normalKeymap("Y", "y$")

-- donot yank
-- normalKeymap("x", '"_x')
-- normalKeymap("X", '"_X')
normalKeymap("s", '"_s')

-- buffer
normalKeymap("<M-h>", ":bprev<CR>")
normalKeymap("<M-l>", ":bnext<CR>")

-- disable arrow keys
local arrowKeys = { "<Up>", "<Down>", "<Left>", "<Right>" }
for _, key in ipairs(arrowKeys) do
  vim.keymap.set({ "n", "v" }, key, "", {})
end
