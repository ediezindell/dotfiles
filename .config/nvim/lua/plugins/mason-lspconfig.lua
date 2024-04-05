return {
  "williamboman/mason-lspconfig.nvim",
  dependencies = {
    "williamboman/mason.nvim",
    "neovim/nvim-lspconfig",
    "Shougo/ddc-source-lsp",
    "uga-rosa/ddc-source-lsp-setup",
  },
  lazy = false,
  config = function()
    local lspconfig = require("lspconfig")
    local masonLspconfig = require("mason-lspconfig")
    masonLspconfig.setup({
      -- 自動インストールするLSP
      ensure_installed = require("lsp.list"),
    })
    masonLspconfig.setup_handlers({
      function(server_name)
        require("ddc_source_lsp_setup").setup()
        lspconfig[server_name].setup({})
      end,
      lua_ls = function()
        lspconfig.lua_ls.setup(require("lsp.lua")) -- 外部設定ファイルの読み込み
      end,
      intelephense = function()
        lspconfig.intelephense.setup(require("lsp.php")) -- 外部設定ファイルの読み込み
      end,
    })

    -- keymap
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(_)
        vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
        vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
        vim.keymap.set("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>")
        vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.rename()<CR>")
        vim.keymap.set("n", "gn", "<cmd>lua vim.lsp.buf.rename()<CR>")
        vim.keymap.set("n", "ga", "<cmd>lua vim.lsp.buf.code_action()<CR>")
        vim.keymap.set("n", "ge", "<cmd>lua vim.diagnostic.open_float()<CR>")
        vim.keymap.set("n", "g]", "<cmd>lua vim.diagnostic.goto_next()<CR>")
        vim.keymap.set("n", "g[", "<cmd>lua vim.diagnostic.goto_prev()<CR>")
      end,
    })
  end,
}
