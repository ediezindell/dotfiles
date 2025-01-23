local function aucmd(event, opts)
  vim.api.nvim_create_autocmd(event, opts)
end
local function group(name)
  vim.api.nvim_create_augroup(name, { clear = true })
end

-- Insertモードを抜けた際に英字入力に設定
---@refs https://github.com/daipeihust/im-select
aucmd("InsertLeave", {
  command = "silent !im-select com.google.inputmethod.Japanese.Roman",
  group = group("AutoRoman"),
})

-- ターミナルのキーマッピングを設定
local function set_terminal_keymaps()
  local opts = { buffer = 0 }
  local keymaps = {
    ["<esc>"] = [[<C-\><C-n>]],
    ["<C-c>"] = [[<C-\><C-n>]],
  }

  for key, cmd in pairs(keymaps) do
    vim.keymap.set("t", key, cmd, opts)
  end
end
aucmd("TermOpen", {
  pattern = "term://*",
  callback = set_terminal_keymaps,
  group = group("TermKeymap"),
})

-- 検索時にhlsearchを有効化
aucmd("CmdlineLeave", {
  pattern = { "/", "?", "*" },
  command = "set hlsearch",
  group = group("AutoHLS"),
})

-- LSPアタッチ時のキーマッピングとハンドラ設定
local function set_lsp_keymaps()
  local mappings = {
    K = vim.lsp.buf.hover,
    gd = vim.lsp.buf.definition,
    gt = vim.lsp.buf.type_definition,
    gr = vim.lsp.buf.rename,
    gn = vim.lsp.buf.rename,
    ga = vim.lsp.buf.code_action,
    ge = vim.diagnostic.open_float,
    ["g]"] = vim.diagnostic.goto_next,
    ["g["] = vim.diagnostic.goto_prev,
  }

  for key, func in pairs(mappings) do
    vim.keymap.set("n", key, func, { buffer = 0 })
  end

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
end
aucmd("LspAttach", {
  callback = set_lsp_keymaps,
  group = group("LspKeymap"),
})

-- 保存時にフォーマットを実行
aucmd("BufWritePre", {
  callback = function()
    vim.lsp.buf.format()
  end,
  group = group("AutoFormat"),
})

-- スクロール位置を記憶
aucmd("BufReadPost", {
  callback = function()
    local last_pos = vim.fn.line([['"]])
    if last_pos > 0 and last_pos <= vim.fn.line("$") then
      vim.cmd("normal! g'\"")
    end
  end,
})

-- 保存時にディレクトリが存在しなければ作成
local function create_missing_dirs()
  local dir = vim.fn.expand("<afile>:p:h")
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end
end
aucmd("BufWritePre", {
  callback = create_missing_dirs,
  group = group("AutoMkdir"),
})

-- 存在しないファイルが開かれた際の処理
local function handle_missing_file()
  local fname = vim.fn.expand("<afile>")
  local dname = vim.fn.fnamemodify(fname, ":h")
  local files_in_dir = vim.split(vim.fn.glob(dname == "." and "*" or dname .. "/*"), "\n")

  local matches = vim.tbl_filter(function(f)
    return f:find("^" .. vim.pesc(fname)) ~= nil -- 前方一致
  end, files_in_dir)
  if vim.tbl_isempty(matches) then
    matches = vim.tbl_filter(function(f)
      return f:find(vim.pesc(fname)) ~= nil -- 部分一致
    end, files_in_dir)
  end

  local function open(file)
    vim.fn.timer_start(0, function()
      vim.cmd("bdelete")
      vim.cmd("edit " .. vim.fn.fnameescape(file))
    end)
  end

  if vim.tbl_isempty(matches) then
    if fname == "," then
      open(".")
      return
    else
      return
    end
  end

  local matchCount = 0
  local choices = {}
  for i, file in ipairs(matches) do
    matchCount = i
    table.insert(choices, string.format("%d %s", i, file))
  end

  if matchCount == 1 then
    local file = matches[matchCount]
    open(file)
    return
  end

  vim.ui.select(
    matches,
    { prompt = string.format("The '%s' does not exist. Choose from the following options:", fname) },
    function(file)
      if file ~= nil then
        open(file)
      end
    end
  )
end
aucmd("BufNewFile", {
  callback = handle_missing_file,
  group = group("CheckPrefixMatchFiles"),
})

-- o/Oによる行の追加時はコメント化しない
aucmd("FileType", {
  callback = function()
    vim.opt_local.fo:remove("o")
  end,
  group = group("FormatOptions"),
})

aucmd("FileType", {
  pattern = "ddu-ff",
  callback = function()
    vim.cmd([[setlocal signcolumn=no]])
  end,
  group = group("DduUiFf"),
})

aucmd("BufWritePre", {
  command = "Px2rem",
  group = group("Px2rem"),
})
