---@type vim.lsp.Config
return {
  root_dir = function(bufnr, on_dir)
    require("toolchain").activate_ts(bufnr, "vtsls", on_dir)
  end,
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
        -- syntax 専用の軽量プロセスを分けると補完・ハイライトが semantic 処理で
        -- ブロックされないので有効のまま
        useSeparateSyntaxServer = true,
        experimental = {
          -- project 全体の診断は tsserver を常時 CPU で回し続けるので無効化。
          -- 開いていないファイルの型エラーは出なくなる（tsc / CI で拾う）
          enableProjectDiagnostics = false,
        },
      },
      preferences = {
        -- importModuleSpecifier = "project-relative",
        importModuleSpecifier = "non-relative",
      },
    },
  },
}
