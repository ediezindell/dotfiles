local function get_project_config()
  local root_files = {
    ".eslintrc",
    ".eslintrc.js",
    ".eslintrc.cjs",
    ".eslintrc.yaml",
    ".eslintrc.yml",
    ".eslintrc.json",
    "eslint.config.js",
    "eslint.config.mjs",
    "eslint.config.cjs",
    "eslint.config.ts",
    "eslint.config.mts",
    "eslint.config.cts",
    "biome.json",
  }
  for _, root_file in ipairs(root_files) do
    if vim.fn.findfile(root_file, ".;") ~= "" then
      if root_file:find("eslint") then
        return { formatter = "eslint", linter = "prettier" }
      elseif root_file == "biome.json" then
        return { formatter = "biome" }
      end
    end
  end
  return nil
end

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
    local nls = require("null-ls")
    local mason_nls = require("mason-null-ls")
    local fmt = nls.builtins.formatting

    local shellcheck = require("none-ls-shellcheck")

    mason_nls.setup({
      ensure_installed = {
        "biome",
        "stylua",
        "eslint_d",
        "php-cs-fixer",
        -- "shfmt",
        -- "deno",
      },
      automatic_installation = true, -- 自動インストール有効化
      handlers = {
        function() end,
        stylua = function()
          nls.register(fmt.stylua)
        end,
        biome = function()
          local config = get_project_config()
          if config and config.formatter == "biome" then
            print("this is biome project!")
          end
        end,
        ["php-cs-fixer"] = function()
          nls.register(fmt["php-cs-fixer"])
        end,
      },
    })

    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
    nls.setup({
      -- 自動インストールするLSP
      sources = {
        fmt.biome,
        fmt.stylua,
        shellcheck.diagnostics,
        shellcheck.code_actions,
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
                  local disabled_format_clients = {
                    "lua_ls",
                  }
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
