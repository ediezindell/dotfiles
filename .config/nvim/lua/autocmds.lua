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
