-- null-ls (LSPではないものをLSP化する) を利用する
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
    "jay-babu/mason-null-ls.nvim",
    lazy = false,
    dependencies = {
      "nvimtools/none-ls.nvim",
      "nvimtools/none-ls-extras.nvim",
      "gbprod/none-ls-shellcheck.nvim",
      "nvim-lua/plenary.nvim",
      "vim-test/vim-test",
    },
    opts = {
      ensure_installed = {
        "typos-lsp",
        "lua-language-server",
        "vtsls",
        "stylua",
        -- "css-lsp",
        "stylelint-lsp",
        -- "emmet-language-server",
        "tailwindcss-language-server",
        "html-lsp",
        "astro-language-server",
        "markuplint",
        "intelephense",
        "gopls",
        "remark-language-server",
        "python-lsp-server",
      },
      automatic_installation = true,
    },
  },
}

return spec
