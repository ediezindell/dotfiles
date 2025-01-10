---@alias Rhs string | function
---@alias KeymapFunc fun(mode: string | string[], lhs: string, rhs: Rhs, desc: string)
---@alias ModeKeymapFunc fun(lhs: string, rhs: Rhs, desc: string)

---keymapを設定する
---@type KeymapFunc
Keymap = function(mode, lhs, rhs, desc)
  local opts = { noremap = true, silent = true, desc = desc }
  vim.keymap.set(mode, lhs, rhs, opts)
end

---インサートモードのkeymapを設定する
---@type ModeKeymapFunc
InsertKeymap = function(lhs, rhs, desc)
  Keymap("i", lhs, rhs, desc)
end

---ノーマルモードのkeymapを設定する
---@type ModeKeymapFunc
NormalKeymap = function(lhs, rhs, desc)
  Keymap("n", lhs, rhs, desc)
end

---ビジュアルモードのkeymapを設定する
---@type ModeKeymapFunc
VisualKeymap = function(lhs, rhs, desc)
  Keymap("x", lhs, rhs, desc)
end

---モーション用のkeymapを設定する
---@type ModeKeymapFunc
MotionKeymap = function(lhs, rhs, desc)
  Keymap({ "x", "o" }, lhs, rhs, desc)
end

---コマンドを実行するkeymapを設定する
---@type ModeKeymapFunc
CommandKeymap = function(lhs, command, desc)
  NormalKeymap(lhs, "<Cmd>" .. command .. "<CR>", desc)
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

---エスケープしたクリップボードの内容で検索する
SearchByClipboard = function()
  local escape_special_chars = function(str)
    local escape_table = {
      ["<"] = [[\<]],
      [">"] = [[\>]],
      ["("] = [[\(]],
      [")"] = [[\)]],
      ["{"] = [[\{]],
      ["}"] = [[\}]],
      ["["] = [[\[]],
      ["]"] = "\\]",
      ["/"] = [[\/]],
      ["\\"] = [[\\]],
      ['"'] = [[\"]],
      ["'"] = [[\']],
      ["="] = [[\=]],
      ["."] = [[\.]],
      ["?"] = [[\?]],
      ["*"] = [[\*]],
      ["+"] = [[\+]],
      ["-"] = [[\-]],
      ["^"] = [[\^]],
      ["$"] = [[\$]],
      ["\n"] = [[\n]],
      ["@"] = [[\@]],
    }
    return str:gsub(".", function(c)
      return escape_table[c] or c
    end)
  end
  local search_term = escape_special_chars(vim.fn.getreg("+"))
  local command = "/" .. search_term
  vim.api.nvim_feedkeys(command, "c", true)
end
