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

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = "rounded",
    })
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

-- 前方一致するファイルを選択して開く
--- @see https://zenn.dev/kawarimidoll/articles/33cf46fae69809
local function check_prefix_match_files()
  -- 現在のファイル名とディレクトリを取得
  local fname = vim.fn.expand("<afile>")
  local dname = vim.fn.fnamemodify(fname, ":h")

  -- 当該ディレクトリ内のファイル一覧を取得
  local files_in_dir = vim.split(vim.fn.glob(dname == "." and "*" or dname .. "/*"), "\n")

  -- ファイル名が前方一致するものを抽出
  local possible = vim.tbl_filter(function(v)
    return v:find("^" .. vim.pesc(fname)) ~= nil
  end, files_in_dir)

  -- 候補がなければ終了
  if vim.tbl_isempty(possible) then
    return
  end

  -- 候補のリストを confirm() を使って表示
  local choices = {}
  for k, v in ipairs(possible) do
    table.insert(choices, string.format("&%d %s", k, v))
  end

  local choice = vim.fn.confirm(
    string.format('"%s" does not exist. Do you want to open file below?', fname),
    table.concat(choices, "\n"),
    0
  )

  -- 選択されなければ終了
  if choice == 0 then
    return
  end

  -- 選択されたファイルを開く タイマーを使う理由は後述
  vim.fn.timer_start(0, function()
    vim.cmd("edit " .. vim.fn.fnameescape(possible[choice]))
  end)
end

-- 存在しないファイルが開かれたときに起動
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*",
  callback = check_prefix_match_files,
  group = vim.api.nvim_create_augroup("check_prefix_match_files", { clear = true }),
})
