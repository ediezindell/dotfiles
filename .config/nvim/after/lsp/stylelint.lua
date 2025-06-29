---@type vim.lsp.Config
return {
  filetypes = {
    "css",
    "scss",
    "less",
    "sass",
    "postcss",
  },
  settings = {
    stylelintplus = {
      autoFixOnSave = true,
      autoFixOnFormat = true,
    },
  },
}
