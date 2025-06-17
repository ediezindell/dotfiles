---@type vim.lsp.Config
return {
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  settings = {
    refactor_auto_rename = true,
    complete_function_calls = true,
    vtsls = {
      enableMoveToFileCodeAction = true,
      autoUseWorkspaceTsdk = true,
      experimental = {
        completion = {
          enableServerSideFuzzyMatch = true,
          entriesLimit = 20,
        },
      },
    },
    typescript = {
      updateImportsOnFileMove = { enabled = "always" },
      suggest = {
        completeFunctionCalls = true,
      },
      tsserver = {
        useSeparateSyntaxServer = true,
        experimental = {
          enableProjectDiagnostics = true,
        },
      },
      preferences = {
        -- importModuleSpecifier = "project-relative",
        importModuleSpecifier = "non-relative",
      },
    },
  },
}
