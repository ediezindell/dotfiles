---@type LazySpec
local spec = {
  "aznhe21/actions-preview.nvim",
  event = "LspAttach",
  config = function()
    vim.keymap.set({ "v", "n" }, "ga", require("actions-preview").code_actions)
  end,
}

return spec
