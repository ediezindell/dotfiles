local rtp = vim.api.nvim_get_runtime_file("", true)
return {
  settings = {
    Lua = {
      hint = { enable = true },
      format = { enable = true },
      runtime = {
        version = "LuaJIT",
        checkThirdParty = true,
      },
      diagnostics = {
        globals = { "vim", "wezterm" },
      },
      workspace = {
        library = rtp,
      },
      telemetry = {
        enable = false,
      },
    },
  },
}
