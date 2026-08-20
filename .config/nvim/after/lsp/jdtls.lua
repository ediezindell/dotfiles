--- jdtls 自体を起動する JVM のパスを java_home で解決する。
--- -F (failfast) が無いとバージョン不一致でも exit 0 でデフォルト JVM を返してしまう。
---@param version string
---@return string?
local function resolve_java_home(version)
  local output = vim.trim(vim.fn.system({ "/usr/libexec/java_home", "-F", "-v", version }))
  if output:sub(1, 1) == "/" then
    return output
  end
  return nil
end

---@type vim.lsp.Config
return {
  ---@param dispatchers? vim.lsp.rpc.Dispatchers
  ---@param config vim.lsp.ClientConfig
  cmd = function(dispatchers, config)
    local data_dir = vim.fs.joinpath(vim.fn.stdpath("cache"), "jdtls", "workspace")
    if config.root_dir then
      data_dir = vim.fs.joinpath(data_dir, (config.root_dir:gsub("/", "%%")))
    end
    local java_home = resolve_java_home("21")
    local opts
    if java_home then
      opts = { env = { JAVA_HOME = java_home } }
    end
    return vim.lsp.rpc.start({ "jdtls", "-data", data_dir }, dispatchers, opts)
  end,
  init_options = {},
  ---@param config vim.lsp.ClientConfig
  before_init = function(_, config)
    local java17 = resolve_java_home("17")
    if not java17 then
      return
    end
    config.init_options = vim.tbl_deep_extend("force", config.init_options or {}, {
      settings = {
        java = {
          configuration = {
            runtimes = { { name = "JavaSE-17", path = java17 } },
          },
        },
      },
    })
  end,
}
