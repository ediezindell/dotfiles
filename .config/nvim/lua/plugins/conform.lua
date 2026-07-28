--- Formatting configuration with conform.nvim
---@type LazySpec
local spec = {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      css = { "prettier" },
      html = { "prettier" },
      json = { "prettier" },
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
