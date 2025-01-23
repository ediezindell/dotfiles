---@type LazySpec
local spec = {
  "neovim/nvim-lspconfig",
  dependencies = {
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "nvimtools/none-ls.nvim",
    "nvimtools/none-ls-extras.nvim",
    "yioneko/nvim-vtsls",
  },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lspconfig = require("lspconfig")
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    lspconfig.html.setup({})
    lspconfig.cssls.setup({
      cmd = { "vscode-css-language-server" },
    })
    lspconfig.typos_lsp.setup({
      init_options = {
        config = "~/.config/nvim/spell/.typos.toml",
      },
    })

    lspconfig.denols.setup({
      root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc", "denops", ".git"),
      single_file_support = true,
      autostart = false,
      on_attach = function(_, buffer)
        vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
          buffer = buffer,
          callback = function()
            vim.cmd.DenolsCache()
          end,
        })
      end,
      init_options = {
        lint = true,
        unstable = true,
        suggest = {
          imports = {
            hosts = {
              ["https://deno.land"] = true,
              ["https://cdn.nest.land"] = true,
              ["https://crux.land"] = true,
              ["https://esm.sh"] = true,
            },
          },
        },
      },
      capabilities = capabilities,
    })
    lspconfig.vtsls.setup({
      capabilities = capabilities,
      autostart = false,
    })
    lspconfig.lua_ls.setup(require("lsp.lua"))
    lspconfig.rust_analyzer.setup({})
    lspconfig.intelephense.setup(require("lsp.php"))
    -- lspconfig.biome.setup(require("lsp.biome"))
    lspconfig.stylelint_lsp.setup({
      filetypes = {
        "css",
        "scss",
        "less",
        "sass",
        "postcss",
      },
      settings = {
        stylelintplus = {
          autoFixOnSave = true,
          autoFixOnFormat = true,
        },
      },
      capabilities = capabilities,
    })
    lspconfig.astro.setup({
      capabilities = capabilities,
    })
    lspconfig.tailwindcss.setup({
      capabilities = capabilities,
    })
    lspconfig.gopls.setup({
      capabilities = capabilities,
    })

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
      pattern = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
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
