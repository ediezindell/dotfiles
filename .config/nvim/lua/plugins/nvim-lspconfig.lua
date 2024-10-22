---@type LazySpec
local spec = {
  "neovim/nvim-lspconfig",
  dependencies = {
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "nvimtools/none-ls.nvim",
    "nvimtools/none-ls-extras.nvim",
  },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lspconfig = require("lspconfig")
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local lspList = {
      "html",
      "cssls",
    }
    for _, server_name in ipairs(lspList) do
      lspconfig[server_name].setup({})
    end
    lspconfig.typos_lsp.setup({
      init_options = {
        config = "~/.config/nvim/spell/.typos.toml",
      },
    })

    lspconfig.denols.setup({
      root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
      init_options = {
        lint = true,
        unstable = true,
        suggest = {
          imports = {
            hosts = {
              ["https://deno.land"] = true,
              ["https://cdn.nest.land"] = true,
              ["https://crux.land"] = true,
            },
          },
        },
      },
      capabilities = capabilities,
    })
    lspconfig.vtsls.setup({
      root_dir = lspconfig.util.root_pattern("package.json"),
      capabilities = capabilities,
      single_file_support = false,
    })
    lspconfig.lua_ls.setup(require("lsp.lua"))
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
    lspconfig.emmet_language_server.setup({
      capabilities = capabilities,
    })
    lspconfig.astro.setup({
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
  end,
}

return spec
