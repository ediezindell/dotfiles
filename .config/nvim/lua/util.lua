Keymap = function(mode, lhs, rhs)
  local opts = { noremap = true, silent = true }
  vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
end
NormalKeymap = function(lhs, rhs)
  Keymap("n", lhs, rhs)
end
