---@type vim.lsp.Config
return {
  ft = { "md", "markdown", "markdown.mdx" },
  ---@see https://github.com/remarkjs/remark-language-server
  settings = { remark = { requireConfig = true } },
}
