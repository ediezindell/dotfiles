return {
  "sindrets/diffview.nvim",
  -- event = "VimEnter",
  config = function()
    require("diffview").setup()

    -- keymap
    local opts = { noremap = true, silent = true }
    vim.keymap.set("n", "<leader>gd", ":DiffviewOpen<CR>", opts)
  end,
}
