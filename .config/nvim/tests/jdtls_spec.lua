package.path = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)) .. "/?.lua;" .. package.path
local h = require("helper")

--- vim.lsp.rpc.start をモックして jdtls の cmd 配列と起動 opts をキャプチャする
---@param root string
---@return string[], table?
local function captured_cmd(root)
  local captured, captured_opts
  local original = vim.lsp.rpc.start
  vim.lsp.rpc.start = function(cmd, _, opts)
    captured = cmd
    captured_opts = opts
    return {}
  end
  vim.lsp.config["jdtls"].cmd({}, { root_dir = root })
  vim.lsp.rpc.start = original
  return captured, captured_opts
end

--- vim.fn.system を差し替え、fn(cmd) の戻り値をそのまま system の出力にする
---@param fn fun(cmd: string[]): string
---@param body fun()
local function with_mocked_system(fn, body)
  local original = vim.fn.system
  vim.fn.system = fn
  local ok, err = pcall(body)
  vim.fn.system = original
  if not ok then
    error(err, 0)
  end
end

---@param cmd string[]
---@return string?
local function data_arg(cmd)
  for i, arg in ipairs(cmd) do
    if arg == "-data" then
      return cmd[i + 1]
    end
  end
  return nil
end

do
  local root = h.fixture({ files = { ["build.gradle"] = "" } })
  local workspace = data_arg(captured_cmd(root))
  local expected = vim.fs.joinpath(vim.fn.stdpath("cache"), "jdtls", "workspace", (root:gsub("/", "%%")))
  h.eq(expected, workspace, "シンプルな root dir から workspace パスが生成される")
end

do
  local root = h.fixture({ dirs = { "my project あ" } })
  local special_root = root .. "/my project あ"
  local workspace = data_arg(captured_cmd(special_root))
  local expected = vim.fs.joinpath(vim.fn.stdpath("cache"), "jdtls", "workspace", (special_root:gsub("/", "%%")))
  h.eq(expected, workspace, "root dir の basename がスペース/日本語を含んでも有効な workspace パスになる")
end

do
  local root_a = h.fixture({ dirs = { "backend" } }) .. "/backend"
  local root_b = h.fixture({ dirs = { "frontend" } }) .. "/frontend"
  local workspace_a = data_arg(captured_cmd(root_a))
  local workspace_b = data_arg(captured_cmd(root_b))
  h.eq(false, workspace_a == workspace_b, "basename が異なる root dir では異なる workspace パスが返る")
end

do
  local root = h.fixture({ dirs = { "work/backend", "sandbox/backend" } })
  local root_a = root .. "/work/backend"
  local root_b = root .. "/sandbox/backend"
  local workspace_a = data_arg(captured_cmd(root_a))
  local workspace_b = data_arg(captured_cmd(root_b))
  h.eq(false, workspace_a == workspace_b, "basename が同じでも親ディレクトリが違えば workspace パスは衝突しない")
end

do
  local root = h.fixture({ files = { ["build.gradle"] = "" } })
  local captured_env
  with_mocked_system(function()
    return "/fake/corretto21\n"
  end, function()
    local _, opts = captured_cmd(root)
    captured_env = opts and opts.env
  end)
  h.eq(
    "/fake/corretto21",
    captured_env and captured_env.JAVA_HOME,
    "java_home コマンドの成功結果が JAVA_HOME として cmd の env に渡る"
  )
end

do
  local root = h.fixture({ files = { ["build.gradle"] = "" } })
  local captured_opts
  with_mocked_system(function()
    return "The operation couldn't be completed. Unable to locate a Java Runtime.\n"
  end, function()
    local _, opts = captured_cmd(root)
    captured_opts = opts
  end)
  local has_java_home = captured_opts ~= nil and captured_opts.env ~= nil and captured_opts.env.JAVA_HOME ~= nil
  h.eq(false, has_java_home, "java_home コマンドが失敗したら JAVA_HOME を cmd の env に含めない")
end

do
  local root = h.fixture({ files = { ["build.gradle"] = "" } })
  local captured_env, java17_path
  with_mocked_system(function(cmd)
    if cmd[4] == "21" then
      return "/fake/corretto21\n"
    elseif cmd[4] == "17" then
      return "/fake/corretto17\n"
    end
    return ""
  end, function()
    local _, opts = captured_cmd(root)
    captured_env = opts and opts.env

    local config = { init_options = {} }
    vim.lsp.config["jdtls"].before_init({}, config)
    local runtimes = vim.tbl_get(config, "init_options", "settings", "java", "configuration", "runtimes") or {}
    for _, rt in ipairs(runtimes) do
      if rt.name == "JavaSE-17" then
        java17_path = rt.path
      end
    end
  end)
  h.eq("/fake/corretto21", captured_env and captured_env.JAVA_HOME, "cmd 起動用 JAVA_HOME は 21 の解決結果")
  h.eq("/fake/corretto17", java17_path, "init_options の JavaSE-17 パスは 17 の解決結果で、21 とは異なる")
end

do
  local captured_runtimes
  with_mocked_system(function()
    return "The operation couldn't be completed. Unable to locate a Java Runtime.\n"
  end, function()
    local config = { init_options = {} }
    vim.lsp.config["jdtls"].before_init({}, config)
    captured_runtimes = vim.tbl_get(config, "init_options", "settings", "java", "configuration", "runtimes")
  end)
  h.eq(
    true,
    captured_runtimes == nil or #captured_runtimes == 0,
    "java_home コマンドが失敗したら runtimes に JavaSE-17 エントリを追加しない"
  )
end

h.finish()
