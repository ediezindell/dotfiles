local opts = { noremap = true, silent = true }
local term_opts = { silent = true }
local keymap = vim.api.nvim_set_keymap

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Esc2回でハイライト解除
keymap("n", "<Esc><Esc>", ":<C-u>set nohlsearch<Return>", opts)

-- split view
keymap("n", "ss", ":split<Return><C-w>w", opts)
keymap("n", "sv", ":vsplit<Return><C-w>w", opts)

-- donot yank via x
keymap("n", "x", '"_x', opts)

-- plugin
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', {silent=true})

vim.keymap.set('n', '<leader>t', ':term<CR>', {})

vim.keymap.set('n', '<leader>mdp', ':CocCommand markdown-preview-enhanced.openPreview<CR>', {})

vim.keymap.set('n', '<leader>gd', ':DiffviewOpen<CR>', {})
