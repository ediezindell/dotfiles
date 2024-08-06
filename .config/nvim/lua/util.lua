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

---Debounce a function
---@param func function
---@param wait number
---@see https://zenn.dev/vim_jp/articles/68eb77d2f2a37a
Debounce = function(func, wait)
  local timer_id
  ---@vararg any
  return function()
    if timer_id ~= nil then
      vim.uv.timer_stop(timer_id)
    end
    timer_id = assert(vim.uv.new_timer())
    vim.uv.timer_start(timer_id, wait, 0, function()
      func()
      timer_id = nil
    end)
  end
end
