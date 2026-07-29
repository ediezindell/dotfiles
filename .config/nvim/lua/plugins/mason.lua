-- Tool installation management with mason and mason-tool-installer
---@type LazySpec[]
local spec = {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    cmd = {
      "Mason",
      "MasonInstall",
      "MasonUninstall",
      "MasonUninstallAll",
      "MasonLog",
      "MasonUpdate",
    },
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
        border = "single",
      },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          -- LSP Servers
          "biome",
          "typos-lsp",
          "lua-language-server",
          "vtsls",
          "tsgo",
          "stylelint-lsp",
          "tailwindcss-language-server",
          "html-lsp",
          "astro-language-server",
          "intelephense",
          "gopls",
          "remark-language-server",
          "python-lsp-server",
          "twiggy-language-server",
          -- Formatters & Linters
          "stylua",
          "markuplint",
          "prettier",
          "eslint_d",
          "oxlint",
          "oxfmt",
        },
      })
    end,
  },
  {
    "vim-test/vim-test",
    cmd = { "TestNearest", "TestFile", "TestSuite", "TestLast", "TestVisit" },
  },
}

return spec
