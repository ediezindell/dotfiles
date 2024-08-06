-- ターミナルを表示する
---@type LazySpec
local spec = {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      insert_mappings = true,
    })

    -- keymap
    local term_opts = { silent = true }
    vim.keymap.set("n", "<leader>t", ":ToggleTerm<CR>", term_opts)
  end,
  cmd = "ToggleTerm",
}

return spec
