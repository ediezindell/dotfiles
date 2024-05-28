-- マクロ記録時にカラーテーマを変更する
-- ref: https://zenn.dev/vim_jp/articles/68eb77d2f2a37a
---Debounce a function
---@param func function
---@param wait number
local debounce = function(func, wait)
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
return {
  dir = "",
  name = "macrocolor",
  lazy = true,
  event = "BufEnter",
  opts = {
    default = "monokai",
    macro = "monokai_ristretto",
    check_interval = 200,
  },
  config = function(_, opts)
    local changeColorScheme = debounce(
      vim.schedule_wrap(function()
        local reg = vim.fn.reg_recording()
        if reg ~= "" then
          vim.cmd.colorscheme(opts.macro)
        else
          vim.cmd.colorscheme(opts.default)
        end
      end),
      opts.check_interval
    )
    vim.on_key(changeColorScheme)
  end,
}
