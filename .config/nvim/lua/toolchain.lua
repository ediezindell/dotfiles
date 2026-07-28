--- JS/TS プロジェクトのツールチェーン判定
local M = {}

local DEP_FIELDS = { "dependencies", "devDependencies" }

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

return M
