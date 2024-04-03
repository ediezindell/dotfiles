return {
  "jay-babu/mason-null-ls.nvim",
  event = {
    "BufReadPre",
    "BufNewFile"
  },
  dependencies = {
    "williamboman/mason.nvim",
    "nvimtools/none-ls.nvim",
  },
  config = function()
    local mason_null_ls = require("mason-null-ls")
    mason_null_ls.setup({
      -- 自動インストールするLSP
      ensure_installed = {
        "stylua",
        "eslint",
        "prettier",
        "shfmt",
      },
      automatic_installation = true, -- 自動インストール有効化
      handlers = {
        function() end,
        -- Lua
        stylua = function()
          local null_ls = require("null-ls")
          null_ls.register(null_ls.builtins.formatting.stylua)
        end,
        -- shell script
        shfmt = function(source_name, methods)
          mason_null_ls.default_setup(source_name, methods)
        end,
      },
    })
  end,
}
