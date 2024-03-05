local opts = { noremap = true, silent = true }
local term_opts = { silent = true }
local keymap = vim.api.nvim_set_keymap

-- 簡易Window移動
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Esc2回でハイライト解除
keymap("n", "<Esc><Esc>", ":<C-u>set nohlsearch<CR>", opts)

-- split view
keymap("n", "<leader>ss", ":split<CR>", opts)  -- 上下
keymap("n", "<leader>sv", ":vsplit<CR>", opts) -- 左右

-- yank from cursor to end of line
keymap("n", "Y", "y$", opts)

-- donot yank
keymap("n", "x", '"_x', opts)
keymap("n", "X", '"_X', opts)
keymap("n", "s", '"_s', opts)


-- nvim-tree
keymap("n", "<leader>e", ":NvimTreeToggle<CR>", opts)

-- terminal
keymap("n", "<leader>t", ":ToggleTerm<CR>", term_opts)

-- diffview
keymap("n", "<leader>gd", ":DiffviewOpen<CR>", opts)

-- disable arrow keys
vim.keymap.set({ "n", "v" }, "<Up>", "", {})
vim.keymap.set({ "n", "v" }, "<Down>", "", {})
vim.keymap.set({ "n", "v" }, "<Left>", "", {})
vim.keymap.set({ "n", "v" }, "<Right>", "", {})
