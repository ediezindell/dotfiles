NormalKeymap("Y", "y$", "yank to EOL")
NormalKeymap("/", [[/\v]], "", { noremap = true, desc = "very magicフラグを入れた状態で検索開始" })
NormalKeymap("<S-m>", "`", "jump to mark")
NormalKeymap("<BS>", "<C-o>", "back")
NormalKeymap("<Left>", "<C-o>", "back")
NormalKeymap("<Right>", "<C-i>", "forward")
NormalKeymap("<space>fE", function()
  vim.g.disable_auto_format = false
end, "enable auto format global")
NormalKeymap("<space>fD", function()
  vim.g.disable_auto_format = true
end, "disable auto format global")

NormalKeymap("<space>fe", function()
  vim.b.disable_auto_format = false
end, "enable auto format in this buffer")
NormalKeymap("<space>fd", function()
  vim.b.disable_auto_format = true
end, "disable auto format in this buffer")
NormalKeymap("q:", ":", "", { noremap = true })

CommandKeymap("<Esc><Esc>", "set nohlsearch", "no highlight")
CommandKeymap("g/", "lua SearchByClipboard()", "クリップボードの内容で検索する")
CommandKeymap("<space>ss", "split", "上下分割")
CommandKeymap("<space>sv", "vsplit", "左右分割")
CommandKeymap("<space><C-v>", [[%d | normal! "+P]], "クリップボードの内容でバッファを置換")
CommandKeymap("<space>bd", "%bd|e#|bd#", "現在のバッファ以外を閉じる")

VisualKeymap("y", "mzy`z", "コピー時にカーソル位置を保存")
VisualKeymap("p", "P", "ペースト時にレジスタの変更を防止")
VisualKeymap("<", "<gv", "連続してインデント操作")
VisualKeymap(">", ">gv", "連続してインデント操作")

TermKeymap("<esc><esc>", [[<C-\><C-n>]], "Normal mode")

-- InsertKeymap("<Tab>", "<C-t>", "字下げ")
-- InsertKeymap("<S-Tab>", "<C-d>", "字上げ")

---@see https://zenn.dev/vim_jp/articles/2024-06-05-vim-middle-class-features#引用符で囲まれた箇所全体を選択する
for _, quote in ipairs({ '"', "'", "`" }) do
  MotionKeymap("a" .. quote, "2i" .. quote, "引用符で囲まれた箇所全体を選択する")
end
MotionKeymap("i<space>", "iW", "スペースで囲われた範囲を選択する")
MotionKeymap("a<space>", "2iW", "スペースで囲われた範囲を選択する")

NormalKeymap("<space>bc", function()
  local ftype = vim.api.nvim_eval("&filetype")
  vim.cmd(string.format(
    [[
    vsplit
    wincmd l
    enew
    setlocal buftype=nofile | set filetype=%s
    normal! P
    diffthis
    wincmd h | diffthis
    ]],
    ftype
  ))
end, "クリップボードの内容と比較")
local function get_url_under_cursor()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local valid_chars = "[%w:/%._%-%?%&%=#]"

  local start_col = col
  while start_col > 0 and line:sub(start_col, start_col):match(valid_chars) do
    start_col = start_col - 1
  end
  start_col = start_col + 1

  local end_col = col + 1
  while end_col <= #line and line:sub(end_col, end_col):match(valid_chars) do
    end_col = end_col + 1
  end
  end_col = end_col - 1

  local text = line:sub(start_col, end_col)

  if text:match("^https?://") then
    return text
  end

  return nil
end
NormalKeymap("gx", function()
  local url = get_url_under_cursor()
  if url then
    vim.fn.jobstart({ "open", url }, { detach = true })
  end
end, "Open URL under cursor", { silent = true })
