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
    local null_ls = require("null-ls")
    local mason_null_ls = require("mason-null-ls")
    mason_null_ls.setup({
      ensure_installed = {
        "prettierd",
        -- "biome",
        "stylua",
        "eslint_d",
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
    local fmt = null_ls.builtins.formatting
    -- local diag = null_ls.builtins.diagnostics
    null_ls.setup({
      -- 自動インストールするLSP
      sources = {
        fmt.prettierd,
        -- fmt.biome,
        fmt.stylua,
        require("none-ls.diagnostics.eslint_d"),
        require("none-ls.formatting.eslint_d"),
        require("none-ls.code_actions.eslint_d"),
        require("none-ls-shellcheck.diagnostics"),
        require("none-ls-shellcheck.code_actions"),
        fmt.shfmt,
        -- fmt.deno_fmt,
      },
      on_attach = function(client, bufnr)
        -- 保存前フォーマット
        if client.supports_method("textDocument/formatting") then
          vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({
                async = false,
                bufnr = bufnr,
                filter = function(c)
                  local disabled_format_clients = { "lua_ls" }
                  return not vim.tbl_contains(disabled_format_clients, c.name)
                end,
              })
            end,
          })
        end
      end,
    })
  end,
}
