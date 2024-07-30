-- insert mode 抜けた際に英字入力にする
vim.cmd("autocmd InsertLeave * :silent !/opt/homebrew/bin/im-select com.google.inputmethod.Japanese.Roman")

function _G.set_terminal_keymaps()
  local terminalKeymap = function(key, value)
    local opts = { buffer = 0 }
    vim.keymap.set("t", key, value, opts)
  end
  local keymaps = {
    ["<esc>"] = [[<C-\><C-n>]],
    ["<C-c>"] = [[<C-\>n>]],
    -- ["jk"] = [[<C-\>n>]],
    -- ["<C-h>"] = [[<C-\>wincmd h<CR>]],
    -- ["<C-j>"] = [[<C-\>wincmd j<CR>]],
    -- ["<C-k>"] = [[<C-\>wincmd k<CR>]],
    -- ["<C-l>"] = [[<C-\>wincmd l<CR>]],
    -- ["<C-w>"] = [[<C-\><C-n><C-w>]],
  }
  for k, v in pairs(keymaps) do
    terminalKeymap(k, v)
  end
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

-- 検索時にhlsearchを有効にする
vim.api.nvim_create_augroup("AutoHLS", { clear = true })
vim.api.nvim_create_autocmd("CmdlineLeave", {
  pattern = { "/", "?", "*" },
  command = "set hlsearch",
  group = "AutoHLS",
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(_)
    vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
    vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
    vim.keymap.set("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>")
    vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.rename()<CR>")
    vim.keymap.set("n", "gn", "<cmd>lua vim.lsp.buf.rename()<CR>")
    vim.keymap.set("n", "ga", "<cmd>lua vim.lsp.buf.code_action()<CR>")
    vim.keymap.set("n", "ge", "<cmd>lua vim.diagnostic.open_float()<CR>")
    vim.keymap.set("n", "g]", "<cmd>lua vim.diagnostic.goto_next()<CR>")
    vim.keymap.set("n", "g[", "<cmd>lua vim.diagnostic.goto_prev()<CR>")
  end,
})

-- 保存時フォーマット
vim.cmd([[
  augroup FormatAutogroup
    autocmd!
    autocmd BufWritePre * lua vim.lsp.buf.format()
  augroup END
]])

-- スクロール位置を記憶
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local last_pos = vim.fn.line([['"]])
    if last_pos > 0 and last_pos <= vim.fn.line("$") then
      vim.cmd("normal! g'\"")
    end
  end,
})

-- 保存時にディレクトリが存在しなければ作成する
local auto_mkdir_group = vim.api.nvim_create_augroup("auto_mkdir_group", { clear = true })
local function auto_mkdir()
  local dir = vim.fn.expand("<afile>:p:h")
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end
end
vim.api.nvim_create_autocmd("BufWritePre", {
  group = auto_mkdir_group,
  pattern = "*",
  callback = auto_mkdir,
})
