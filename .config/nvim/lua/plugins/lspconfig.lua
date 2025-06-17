---@type LazySpec
local spec = {
  "neovim/nvim-lspconfig",
  dependencies = {
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    {
      "nvimtools/none-ls.nvim",
      config = function()
        local null_ls = require("null-ls")
        local opts = {
          prefer_local = "node_modules/.bin",
        }
        null_ls.setup({
          sources = {
            require("none-ls.diagnostics.eslint").with(opts),
            require("none-ls.code_actions.eslint").with(opts),
            null_ls.builtins.formatting.prettier.with(opts),
            -- null_ls.builtins.formatting.biome,
            null_ls.builtins.formatting.stylua,
            null_ls.builtins.diagnostics.markuplint.with({
              extra_filetypes = { "astro" },
              command = "markuplint",
            }),
          },
        })
      end,
    },
    "nvimtools/none-ls-extras.nvim",
    "yioneko/nvim-vtsls",
    "b0o/schemastore.nvim",
    "SmiteshP/nvim-navic",
  },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    -- Set up global LSP configuration
    vim.lsp.config("*", {
      capabilities = require("cmp_nvim_lsp").default_capabilities(),
      on_attach = function(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
          require("nvim-navic").attach(client, bufnr)
        end
      end,
    })
  end,
}

return spec
