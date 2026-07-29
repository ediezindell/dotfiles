--- Formatting configuration with conform.nvim
--- コマンド解決 (node_modules/.bin 優先) は conform builtin に任せる
local function select_formatter(bufnr)
  return require("toolchain").formatters(bufnr)
end

---@type LazySpec
local spec = {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      javascript = select_formatter,
      javascriptreact = select_formatter,
      typescript = select_formatter,
      typescriptreact = select_formatter,
      css = select_formatter,
      json = select_formatter,
      html = { "prettier" },
      markdown = { "prettier" },
      astro = { "prettier" },
      lua = { "stylua" },
    },
    default_format_opts = {
      lsp_format = "fallback",
    },
  },
}

return spec
