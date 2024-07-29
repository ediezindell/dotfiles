---keymapを設定する
---@param mode string モード
---@param lhs string 入力
---@param rhs string 実行内容
Keymap = function(mode, lhs, rhs)
  local opts = { noremap = true, silent = true }
  vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
end

---ノーマルモードのkeymapを設定する
---@param lhs string 入力
---@param rhs string 実行内容
NormalKeymap = function(lhs, rhs)
  Keymap("n", lhs, rhs)
end

---ノーマルモードでコマンドを実行するkeymapを設定する
---@param lhs string 入力
---@param command string コマンド
NormalCommandKeymap = function(lhs, command)
  NormalKeymap(lhs, "<Cmd>" .. command .. "<CR>")
end
