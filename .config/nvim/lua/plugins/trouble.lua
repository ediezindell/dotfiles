return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {},
  config = function()
    require("trouble").setup()
    -- local opts = { noremap = true, silent = true }
    -- vim.keymap.set("n", "", [[*<Cmd>lua require("trouble").toggle("workspace_diagnostics")<CR>]], opts)
  end,
}
