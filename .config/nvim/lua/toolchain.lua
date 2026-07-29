--- JS/TS プロジェクトのツールチェーン判定
local M = {}

local DEP_FIELDS = { "dependencies", "devDependencies" }
local DENO_MARKERS = { "deno.json", "deno.jsonc", "deno.lock", "denops" }
local NODE_MARKERS = { "tsconfig.json", "jsconfig.json", "package.json" }
local LOCK_MARKERS = { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock" }
local BIOME_MARKERS = { "biome.json", "biome.jsonc", ".biome.json", ".biome.jsonc" }
local OXLINT_MARKERS = { ".oxlintrc.json", "oxlint.json" }
local OXFMT_MARKERS = { ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts" }
local ESLINT_MARKERS = {
  "eslint.config.js",
  "eslint.config.mjs",
  "eslint.config.cjs",
  "eslint.config.ts",
  "eslint.config.mts",
  "eslint.config.cts",
  ".eslintrc",
  ".eslintrc.js",
  ".eslintrc.cjs",
  ".eslintrc.json",
  ".eslintrc.yml",
  ".eslintrc.yaml",
}
local JS_FILETYPES = {
  "javascript",
  "javascriptreact",
  "javascript.jsx",
  "typescript",
  "typescriptreact",
  "typescript.tsx",
}

---@param ctx integer|string bufnr、またはファイル / ディレクトリのパス
---@return string
local function base_dir(ctx)
  if type(ctx) == "number" then
    local name = vim.api.nvim_buf_get_name(ctx)
    return name == "" and vim.fn.getcwd() or vim.fs.dirname(name)
  end
  return vim.fn.isdirectory(ctx) == 1 and ctx or vim.fs.dirname(ctx)
end

---@param ctx integer|string
---@param markers string[]|string[][]
---@return string?
local function root(ctx, markers)
  return vim.fs.root(base_dir(ctx), markers)
end

local pkg_cache = {}

---@param bufnr integer
---@return table?
function M.pkg(bufnr)
  local dir = root(bufnr, { "package.json" })
  if not dir then
    return nil
  end
  local path = dir .. "/package.json"
  local stat = vim.uv.fs_stat(path)
  if not stat then
    return nil
  end
  local cached = pkg_cache[path]
  if cached and cached.mtime == stat.mtime.sec then
    return cached.data
  end
  local fd = io.open(path, "r")
  if not fd then
    return nil
  end
  local content = fd:read("*a")
  fd:close()
  local ok, data = pcall(vim.json.decode, content)
  if not ok or type(data) ~= "table" then
    vim.notify_once(("failed to parse %s"):format(path), vim.log.levels.WARN)
    data = nil
  end
  pkg_cache[path] = { mtime = stat.mtime.sec, data = data }
  return data
end

---@param bufnr integer
---@param name string
---@return string?
function M.dep_version(bufnr, name)
  local pkg = M.pkg(bufnr)
  if not pkg then
    return nil
  end
  for _, field in ipairs(DEP_FIELDS) do
    local deps = pkg[field]
    if type(deps) == "table" and type(deps[name]) == "string" then
      return deps[name]
    end
  end
  return nil
end

---@param bufnr integer
---@param name string
---@return boolean
function M.has_dep(bufnr, name)
  return M.dep_version(bufnr, name) ~= nil
end

--- "^7.0.2" からメジャー版を取り出す。"latest" / "workspace:*" 等は nil
---@param bufnr integer
---@param name string
---@return integer?
function M.dep_major(bufnr, name)
  local version = M.dep_version(bufnr, name)
  if not version then
    return nil
  end
  return tonumber(version:match("%d+"))
end

---@param ctx integer|string
---@param name string
---@return string?
function M.local_bin(ctx, name)
  local found = vim.fs.find("node_modules", {
    path = base_dir(ctx),
    upward = true,
    type = "directory",
    limit = math.huge,
  })
  for _, dir in ipairs(found) do
    local candidate = dir .. "/.bin/" .. name
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end
  return nil
end

---@param ctx integer|string
---@param name string
---@return string?
function M.bin(ctx, name)
  local found = M.local_bin(ctx, name)
  if found then
    return found
  end
  if vim.fn.executable(name) == 1 then
    return name
  end
  return nil
end

---@param bufnr integer
---@return boolean
function M.is_deno(bufnr)
  return root(bufnr, DENO_MARKERS) ~= nil
end

--- 自動判定できる場合のみサーバー名を返す
---@param bufnr integer
---@return "denols"|"tsgo"|"vtsls"|nil
function M.ts_server(bufnr)
  if M.is_deno(bufnr) then
    return "denols"
  end
  if M.has_dep(bufnr, "@typescript/native-preview") or (M.dep_major(bufnr, "typescript") or 0) >= 7 then
    return "tsgo"
  end
  if root(bufnr, NODE_MARKERS) then
    return "vtsls"
  end
  return nil
end

---@param bufnr integer
---@return string
function M.project_root(bufnr)
  return root(bufnr, { LOCK_MARKERS, { ".git" } }) or root(bufnr, NODE_MARKERS) or base_dir(bufnr)
end

---@param bufnr integer
---@param server string
---@return string
function M.root_for(bufnr, server)
  if server == "denols" then
    return root(bufnr, { DENO_MARKERS, { ".git" } }) or base_dir(bufnr)
  end
  return M.project_root(bufnr)
end

local NO_LAUNCH = "no launch"
--- 自動判定できないときにユーザーに提示するサーバー
local PICKABLE = { "tsgo", "denols" }

--- ディレクトリ -> "tsgo" | "denols" | false (起動しない)
local decided = {}
--- ディレクトリ -> 応答待ちのコールバック
local waiting = {}

---@param bufnr integer
---@return string?
function M.ts_choice(bufnr)
  local choice = decided[base_dir(bufnr)]
  if choice == false then
    return nil
  end
  return choice
end

--- 同じディレクトリに対する問い合わせを 1 回のプロンプトに集約する
---@param dir string
---@param cb fun(choice: string|false)
local function ask(dir, cb)
  if decided[dir] ~= nil then
    cb(decided[dir])
    return
  end
  if waiting[dir] then
    table.insert(waiting[dir], cb)
    return
  end
  waiting[dir] = { cb }
  local items = vim.list_extend(vim.deepcopy(PICKABLE), { NO_LAUNCH })
  vim.ui.select(items, { prompt = "select LSP for TypeScript: " }, function(item)
    local choice = item
    if item == nil or item == NO_LAUNCH then
      choice = false
    end
    -- 中断は記録しない。次に開いたときまた尋ねる
    if item ~= nil then
      decided[dir] = choice
    end
    local waiters = waiting[dir] or {}
    waiting[dir] = nil
    for _, waiter in ipairs(waiters) do
      waiter(choice)
    end
  end)
end

--- 起動すべきと判定できたときだけ on_dir を呼ぶ
---@param bufnr integer
---@param name string
---@param on_dir fun(root_dir?: string)
function M.activate_ts(bufnr, name, on_dir)
  local server = M.ts_server(bufnr)
  if server then
    if server == name then
      on_dir(M.root_for(bufnr, name))
    end
    return
  end
  if not vim.tbl_contains(PICKABLE, name) then
    return
  end
  local dir = base_dir(bufnr)
  ask(dir, function(choice)
    if choice == name then
      on_dir(dir)
    end
  end)
end

function M.reselect_ts()
  local bufnr = vim.api.nvim_get_current_buf()
  local dir = base_dir(bufnr)
  if waiting[dir] then
    return
  end
  decided[dir] = nil
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if vim.tbl_contains(PICKABLE, client.name) then
      client:stop()
    end
  end
  vim.cmd("doautocmd nvim.lsp.enable FileType")
end

---@param bufnr integer
---@return boolean
local function has_biome(bufnr)
  return root(bufnr, BIOME_MARKERS) ~= nil or M.has_dep(bufnr, "@biomejs/biome")
end

---@param bufnr integer
---@return boolean
local function has_eslint(bufnr)
  return root(bufnr, ESLINT_MARKERS) ~= nil or M.has_dep(bufnr, "eslint")
end

---@param bufnr integer
---@return boolean
local function has_oxlint(bufnr)
  return root(bufnr, OXLINT_MARKERS) ~= nil or M.has_dep(bufnr, "oxlint")
end

---@param bufnr integer
---@return boolean
local function has_oxfmt(bufnr)
  return root(bufnr, OXFMT_MARKERS) ~= nil or M.has_dep(bufnr, "oxfmt")
end

--- deno / biome は LSP が同じ診断を出すので nvim-lint では走らせない
---@param bufnr integer
---@return string[]
function M.linters(bufnr)
  if M.is_deno(bufnr) or has_biome(bufnr) then
    return {}
  end
  local linters = {}
  if has_oxlint(bufnr) then
    table.insert(linters, "oxlint")
  end
  if has_eslint(bufnr) then
    table.insert(linters, M.bin(bufnr, "eslint") and "eslint" or "eslint_d")
  end
  return linters
end

---@param bufnr integer
---@param ft? string
---@return string[]
function M.formatters(bufnr, ft)
  ft = ft or vim.bo[bufnr].filetype
  if M.is_deno(bufnr) or M.ts_choice(bufnr) == "denols" then
    return { "deno_fmt" }
  end
  if has_biome(bufnr) then
    return { "biome" }
  end
  if has_oxfmt(bufnr) and vim.tbl_contains(JS_FILETYPES, ft) then
    return { "oxfmt" }
  end
  if M.bin(bufnr, "prettier") then
    return { "prettier" }
  end
  return {}
end

return M
