---@type vim.lsp.Config
return {
  ft = { "lua" },
  settings = {
    Lua = {
      hint = { enable = true },
      format = { enable = true },
      diagnostics = {
        globals = { "vim", "wezterm" },
      },
      telemetry = {
        enable = false,
      },
      runtime = {
        version = "LuaJIT",
        pathStrict = true,
        path = { "?.lua", "?/init.lua" },
      },
      workspace = {
        checkThirdParty = "Disable",
      },
    },
  },
}
