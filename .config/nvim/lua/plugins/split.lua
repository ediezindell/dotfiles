-- split viewでコードの全体を表示する
local function vsplit_and_sync()
  -- 現在のウィンドウのカーソル位置を取得
  local cursor_row, _ = unpack(vim.api.nvim_win_get_cursor(0))
  -- 現在のウィンドウの高さを取得
  local win_height = vim.api.nvim_win_get_height(0)
  -- 右側のウィンドウで表示する開始行を計算
  local start_row = cursor_row + win_height
  if start_row < 1 then
    start_row = 1
  end

  -- ウィンドウの分割
  vim.cmd("vsplit")

  -- -- 右側のウィンドウに移動
  -- vim.cmd("wincmd l")
  -- カーソルとスクロール位置を調整
  vim.api.nvim_win_set_cursor(0, { start_row, 0 })
  vim.cmd("normal! zt")
  -- スクロールの同期設定
  vim.wo.scrollbind = true

  -- 元のウィンドウに戻り、スクロールの同期設定
  vim.cmd("wincmd h")
  vim.wo.scrollbind = true
end

return {
  dir = "",
  name = "split",
  lazy = true,
  event = "BufEnter",
  config = function()
    vim.api.nvim_create_user_command("VSplit", vsplit_and_sync, {})
  end,
}
