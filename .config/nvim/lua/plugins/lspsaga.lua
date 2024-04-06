return {
  "kkharji/lspsaga.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  -- event = "LspAttach",
  config = function()
    local saga = require("lspsaga")
    saga.init_lsp_saga({
      -- 記号の再設定
      error_sign = "",
      warn_sign = "",
      hint_sign = "󰌵",
      infor_sign = "",

      -- LSPとファイル種別の対応
      server_filetype_map = {
        typescript = "typescript",
      },
    })

    -- 見た目の設定
    local floatConfig = {
      focusable = true,
      style = "minimal",
      border = "rounded",
    }
    vim.diagnostic.config({
      virtual_text = {
        spacing = 4,
        -- prefix = "●",
      },
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = floatConfig,
    })
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, floatConfig)
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, floatConfig)
  end,
}
