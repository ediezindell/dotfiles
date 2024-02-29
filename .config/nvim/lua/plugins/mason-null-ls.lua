return {
  "jay-babu/mason-null-ls.nvim",
  -- event = {
  --   "BufReadPre",
  --   "BufNewFile"
  -- },
  dependencies = {
    "williamboman/mason.nvim",
    "nvimtools/none-ls.nvim",
  },
  config = function()
    local mason_null_ls = require("mason-null-ls")
    mason_null_ls.setup({
      ensure_installed = {
        "stylua",
        "eslint",
        "prettier",
      },
      automatic_installation = true,
      handlers = {
        function() end,
        stylua = function()
          local null_ls = require("null-ls")
          null_ls.register(null_ls.builtins.formatting.stylua)
        end,
        shfmt = function(source_name, methods)
          mason_null_ls.default_setup(source_name, methods)
        end,
      },
    })
  end,
}
