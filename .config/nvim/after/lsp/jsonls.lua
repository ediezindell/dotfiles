---@type vim.lsp.Config
return {
  ft = { "json", "jsonc", "jsonl" },
  settings = {
    json = {
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
    },
  },
}
