-- `-` でファイルエクスプローラーを開く
return {
  "stevearc/oil.nvim",
  opts = {},
  -- event = { "BufReadPre", "BufNewFile" },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("oil").setup({
      default_file_explorer = false,
      columns = {
        "permissions",
        "size",
        "mtime",
        "icon",
      },
    })
    local opts = {}
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", opts)
  end,
}
