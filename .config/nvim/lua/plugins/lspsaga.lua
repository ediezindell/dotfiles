return {
  "kkharji/lspsaga.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local saga = require("lspsaga")
    saga.init_lsp_saga({
      error_sign = "",
      warn_sign = "",
      hint_sign = "󰌵",
      infor_sign = "",
    })

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
