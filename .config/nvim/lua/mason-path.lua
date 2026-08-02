local M = {}

--- mason が管理するコマンドを名前で解決できるようにする。
--- LSP の起動判定は起動シーケンス中に走るため、遅延イベントではなく起動時に呼ぶ必要がある。
function M.prepend()
  local bin = vim.fn.stdpath("data") .. "/mason/bin"
  if vim.tbl_contains(vim.split(vim.env.PATH, ":", { plain = true }), bin) then
    return
  end
  vim.env.PATH = bin .. ":" .. vim.env.PATH
end

return M
