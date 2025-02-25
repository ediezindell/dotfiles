---@type LazySpec
local spec = {
  "neovim/nvim-lspconfig",
  dependencies = {
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "nvimtools/none-ls.nvim",
    "nvimtools/none-ls-extras.nvim",
    "yioneko/nvim-vtsls",
    "b0o/schemastore.nvim",
    "SmiteshP/nvim-navic",
  },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lspconfig = require("lspconfig")
    lspconfig.util.default_config = vim.tbl_extend("force", lspconfig.util.default_config, {
      capabilities = require("cmp_nvim_lsp").default_capabilities(),
      on_attach = function(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
          require("nvim-navic").attach(client, bufnr)
        end
      end,
    })
    lspconfig.html.setup({})
    lspconfig.cssls.setup({
      cmd = { "vscode-css-language-server" },
    })
    lspconfig.typos_lsp.setup({
      init_options = {
        config = "~/.config/nvim/spell/.typos.toml",
      },
    })
    lspconfig.denols.setup(require("lsp.deno"))
    lspconfig.vtsls.setup({
      autostart = false,
    })
    lspconfig.lua_ls.setup(require("lsp.lua"))
    lspconfig.rust_analyzer.setup({})
    lspconfig.intelephense.setup(require("lsp.php"))
    lspconfig.biome.setup({
      autostart = false,
    })
    lspconfig.stylelint_lsp.setup(require("lsp.stylelint"))
    lspconfig.astro.setup({})
    lspconfig.tailwindcss.setup({})
    lspconfig.gopls.setup({})
    -- please run: go install github.com/opa-oz/pug-lsp@latest
    lspconfig.pug.setup({})
    lspconfig.jsonls.setup(require("lsp.json"))

    -- フォーマッターとリンターの設定
    local null_ls = require("null-ls")

    null_ls.setup({
      sources = {
        require("none-ls.diagnostics.eslint"),
        require("none-ls.code_actions.eslint"),
        null_ls.builtins.formatting.prettier,
        -- null_ls.builtins.formatting.biome,
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.diagnostics.markuplint.with({
          extra_filetypes = { "astro" },
          command = "markuplint",
        }),
      },
    })

    -- TypeScriptのLS起動設定
    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
        "astro",
      },
      callback = function()
        local configs = require("lspconfig.configs")

        local ts_root = vim.fs.root(0, {
          "tsconfig.json",
          "jsconfig.json",
        })
        local deno_root = vim.fs.root(0, {
          "deno.json",
          "deno.jsonc",
          "denops",
        })

        if ts_root ~= nil then
          configs.vtsls.launch()
        elseif deno_root ~= nil then
          configs.denols.launch()
        end
      end,
    })
  end,
}

return spec
