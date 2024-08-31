---@type LazySpec
local spec = {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = "VeryLazy",
  config = function()
    require("todo-comments").setup({})
    vim.keymap.set("n", "]x", function()
      require("todo-comments").jump_next()
    end, { desc = "Next todo comment" })

    vim.keymap.set("n", "[x", function()
      require("todo-comments").jump_prev()
    end, { desc = "Previous todo comment" })
  end
}

return spec
