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

-- 日本語入力での誤入力を自動修正（よく使うもののみ安全に実装）
local japanese_corrections = {
  -- 基本的なコマンド（ASCII文字のみ使用）
  ["qa"] = "qa",   -- くぁ -> qa
  ["wq"] = "wq",   -- われq -> wq
  ["w"] = "w",     -- ｗ -> w
  ["q"] = "q",     -- q -> q
  ["e"] = "e",     -- え -> e
  ["h"] = "h",     -- ｈ -> h
  ["vs"] = "vs",   -- ｖｓ -> vs
  ["sp"] = "sp",   -- ｓp -> sp
  ["bd"] = "bd",   -- ぶd -> bd
  ["buf"] = "buf", -- ぶf -> buf
  ["tab"] = "tab", -- たあb -> tab
  ["set"] = "set", -- せt -> set
  ["git"] = "git", -- ぎt -> git
  ["lsp"] = "lsp", -- lsp -> lsp
  ["tel"] = "tel", -- てl -> tel (telescope)
}

-- 安全なabbreviationの設定
for _, cmd in pairs(japanese_corrections) do
  pcall(function()
    vim.cmd(string.format("cnoreabbrev %s %s", cmd, cmd))
  end)
end

-- より高度な日本語入力修正（CmdlineChangedイベントを使用）
local function fix_japanese_input()
  local cmdline = vim.fn.getcmdline()
  local pos = vim.fn.getcmdpos()

  -- よくある日本語誤入力パターンの修正
  local corrections = {
    ["くぁ"] = "qa",
    ["われq"] = "wq",
    ["われ"] = "wre",
    ["えでぃt"] = "edit",
    ["えx"] = "ex",
    ["せt"] = "set",
    ["ぶd"] = "bd",
    ["たあb"] = "tab",
    ["ぎt"] = "git",
    ["てl"] = "tel",
    ["ｗ"] = "w",
    ["ｈ"] = "h",
    ["ｖｓ"] = "vs",
    ["ｓp"] = "sp",
  }

  for japanese, english in pairs(corrections) do
    if cmdline:find("^" .. japanese) then
      local new_cmdline = cmdline:gsub("^" .. japanese, english)
      vim.fn.setcmdline(new_cmdline)
      break
    end
  end
end

-- CmdlineChangedイベントで日本語入力を監視
aucmd("CmdlineChanged", {
  pattern = ":",
  callback = function()
    pcall(fix_japanese_input)
  end,
  group = group("JapaneseInputFix"),
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
    K = function()
      vim.lsp.buf.hover({ border = "rounded" })
    end,
    gd = vim.lsp.buf.definition,
    gt = vim.lsp.buf.type_definition,
    gr = vim.lsp.buf.rename,
    gn = vim.lsp.buf.rename,
    -- ga = vim.lsp.buf.code_action,
    ge = vim.diagnostic.open_float,
    ["g]"] = function()
      vim.diagnostic.jump({ count = 1, float = true })
    end,
    ["g["] = function()
      vim.diagnostic.jump({ count = -1, float = true })
    end,
  }

  for key, func in pairs(mappings) do
    vim.keymap.set("n", key, func, { buffer = 0 })
  end
end
aucmd("LspAttach", {
  callback = set_lsp_keymaps,
  group = group("LspKeymap"),
})

-- 保存時にフォーマットを実行
aucmd("BufWritePre", {
  callback = function()
    vim.lsp.buf.format({
      filter = function()
        return vim.g.disable_auto_format ~= true and vim.b.disable_auto_format ~= true
      end,
    })
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
  group = group("SaveScrollPosition"),
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
  dname = dname == "." and vim.fn.getcwd() or dname
  local files_in_dir = vim.split(vim.fn.glob(dname .. "/*"), "\n")

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
      open(vim.fn.getcwd())
      return
    else
      return
    end
  end

  local matchCount = 0
  local choices = {}
  for i, file in ipairs(matches) do
    matchCount = i
    table.insert(choices, string.format("%d %s", i, dname .. "/" .. file))
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

aucmd("TextYankPost", {
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ timeout = 300 })
  end,
  group = group("HighlightYank"),
})

-- TypeScriptのLS起動設定
aucmd("FileType", {
  pattern = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
    "astro",
  },
  callback = function()
    local ts_root = vim.fs.root(0, {
      "tsconfig.json",
      "jsconfig.json",
    })
    local deno_root = vim.fs.root(0, {
      "deno.json",
      "deno.jsonc",
      "denops",
    })

    if ts_root ~= nil then
      vim.lsp.enable("vtsls")
    elseif deno_root ~= nil then
      vim.lsp.enable("denols")
      -- else
      --   local NO_LAUNCH = "no launch"
      --   vim.ui.select({ "vtsls", "denols", NO_LAUNCH }, {
      --     prompt = "select LSP for TypeScript: ",
      --   }, function(item)
      --     if item ~= NO_LAUNCH then
      --       vim.lsp.enable(item)
      --     end
      --   end)
    end
  end,
})

aucmd("QuickfixCmdPost", {
  pattern = "*",
  callback = function()
    local qf_list = vim.fn.getqflist()
    if #qf_list > 0 then
      vim.cmd.copen()
    end
  end,
  group = group("QuickfixOpen"),
})

aucmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local fname = vim.fn.expand("<afile>")
    if fname == "/tmp/input" or fname == "/private/tmp/input" then
      vim.cmd("ConnectSocket")
    end
  end,
  group = group("ConnectSocket"),
})

local function apply_eslint_fix_all()
  local bufnr = vim.api.nvim_get_current_buf()
  local total_lines = vim.api.nvim_buf_line_count(bufnr)

  local params = {
    textDocument = vim.lsp.util.make_text_document_params(),
    range = {
      start = { line = 0, character = 0 },
      ["end"] = { line = total_lines - 1, character = 0 }, -- 行末文字数は0でもよい（多くのLSPが自動補正する）
    },
    context = {
      only = { "source" },
      diagnostics = vim.diagnostic.get(bufnr),
    },
  }

  vim.lsp.buf_request_all(bufnr, "textDocument/codeAction", params, function(results)
    for _, res in pairs(results) do
      for _, action in ipairs(res.result or {}) do
        if action.edit or action.command then
          if action.edit then
            print(action.edit)
          elseif action.command then
            print(action.command)
          end
          -- vim.lsp.buf.execute_command(action)
        end
      end
    end
  end)
end

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.js", "*.ts", "*.jsx", "*.tsx" },
  callback = apply_eslint_fix_all,
})
