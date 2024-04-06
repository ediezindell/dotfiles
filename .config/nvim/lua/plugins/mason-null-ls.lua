return {
  "jay-babu/mason-null-ls.nvim",
  -- lazy = false,
  dependencies = {
    "williamboman/mason.nvim",
    "nvimtools/none-ls.nvim",
    "nvim-lua/plenary.nvim",
    "vim-test/vim-test",
  },
  config = function()
    require("mason").setup()
    local null_ls = require("null-ls")
    local mason_null_ls = require("mason-null-ls")
    mason_null_ls.setup({
      ensure_installed = {
        "prettierd",
        "biome",
        "stylua",
        -- "eslint",
        "shfmt",
        -- "deno",
      },
      automatic_installation = true, -- 自動インストール有効化
      handlers = {
        function() end,
        -- Lua
        stylua = function()
          null_ls.register(null_ls.builtins.formatting.stylua)
        end,
        -- shell script
        shfmt = function(source_name, methods)
          mason_null_ls.default_setup(source_name, methods)
        end,
      },
    })
    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
    null_ls.setup({
      -- 自動インストールするLSP
      sources = {
        null_ls.builtins.formatting.prettierd,
        null_ls.builtins.formatting.biome,
        null_ls.builtins.formatting.stylua,
        -- null_ls.builtins.formatting.eslint,
        null_ls.builtins.formatting.shfmt,
        -- null_ls.builtins.formatting.deno_fmt,
      },
      on_attach = function(client, bufnr)
        -- 保存前フォーマット
        if client.supports_method("textDocument/formatting") then
          vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ bufnr = bufnr })
            end,
          })
        end
      end,
    })
  end,
}
