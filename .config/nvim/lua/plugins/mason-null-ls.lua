-- null-ls (LSPではないものをLSP化する) を利用する
return {
  "jay-babu/mason-null-ls.nvim",
  lazy = false,
  dependencies = {
    "williamboman/mason.nvim",
    "nvimtools/none-ls.nvim",
    "nvimtools/none-ls-extras.nvim",
    "gbprod/none-ls-shellcheck.nvim",
    "nvim-lua/plenary.nvim",
    "vim-test/vim-test",
  },
  config = function()
    local mason_nls = require("mason-null-ls")
    mason_nls.setup({
      ensure_installed = {
        "typos-lsp",
        "lua-language-server",
        "typescript-language-server",
      },
      automatic_installation = true, -- 自動インストール有効化
    })
  end,
}
