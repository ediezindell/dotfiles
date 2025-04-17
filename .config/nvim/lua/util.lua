---keymapを設定する
Keymap = function(mode, lhs, rhs, desc, _opts)
  local opts = _opts or { noremap = true, silent = true, desc = desc }
  vim.keymap.set(mode, lhs, rhs, opts)
end

---インサートモードのkeymapを設定する
InsertKeymap = function(lhs, rhs, desc, opts)
  Keymap("i", lhs, rhs, desc, opts)
end

---ノーマルモードのkeymapを設定する
NormalKeymap = function(lhs, rhs, desc, opts)
  Keymap("n", lhs, rhs, desc, opts)
end

---ビジュアルモードのkeymapを設定する
VisualKeymap = function(lhs, rhs, desc, opts)
  Keymap("x", lhs, rhs, desc, opts)
end

---ターミナルモードのkeymapを設定する
TermKeymap = function(lhs, rhs, desc, opts)
  Keymap("t", lhs, rhs, desc, opts)
end

---モーション用のkeymapを設定する
MotionKeymap = function(lhs, rhs, desc, opts)
  Keymap({ "x", "o" }, lhs, rhs, desc, opts)
end

---コマンドを実行するkeymapを設定する
CommandKeymap = function(lhs, command, desc, opts)
  NormalKeymap(lhs, "<Cmd>" .. command .. "<CR>", desc, opts)
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

---highlight groupから色を抽出
---@see https://www.reddit.com/r/neovim/comments/oxddk9/comment/h7maerh/
GetHighlightColor = function(hlgroup)
  local fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(hlgroup)), "fg#")
  local bg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(hlgroup)), "bg#")
  return {
    fg = fg,
    bg = bg,
  }
end
