vim.lsp.enable({
  "astro",
  "biome",
  "cssls",
  "denols",
  "gopls",
  "html",
  "intelephense",
  "jsonls",
  "lua_ls",
  "pug",
  "remark_ls",
  "rust-analyzer",
  "stylelint",
  "tailwindcss",
  "tsgo",
  "twiggy_language_server",
  "typos_lsp",
  "vtsls",
})

vim.api.nvim_create_user_command("TSLspSelect", function()
  require("toolchain").reselect_ts()
end, { desc = "TypeScript の LSP を選び直す" })
