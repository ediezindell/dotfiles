--- テスト用ヘルパ
--- 実行: nvim -u NONE -l .config/nvim/tests/<name>_spec.lua
local M = {}

local here = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))
local config_dir = vim.fs.dirname(here)

-- after/lsp を lspconfig より後ろに置くことで、after 側の設定が勝つ
vim.opt.runtimepath:prepend(config_dir)
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/lazy/nvim-lspconfig")
vim.opt.runtimepath:append(config_dir .. "/after")

local total = 0
local failures = 0

---@param spec { files?: table<string, string>, dirs?: string[], exe?: string[] }
---@return string root
function M.fixture(spec)
  local root = vim.fn.tempname()
  vim.fn.mkdir(root, "p")
  for _, dir in ipairs(spec.dirs or {}) do
    vim.fn.mkdir(root .. "/" .. dir, "p")
  end
  for rel, content in pairs(spec.files or {}) do
    local path = root .. "/" .. rel
    vim.fn.mkdir(vim.fs.dirname(path), "p")
    local fd = assert(io.open(path, "w"))
    fd:write(content)
    fd:close()
  end
  for _, rel in ipairs(spec.exe or {}) do
    local path = root .. "/" .. rel
    vim.fn.mkdir(vim.fs.dirname(path), "p")
    local fd = assert(io.open(path, "w"))
    fd:write("#!/bin/sh\n")
    fd:close()
    assert(vim.uv.fs_chmod(path, 493))
  end
  return root
end

---@param path string
---@return integer
function M.buf(path)
  local bufnr = vim.fn.bufadd(path)
  vim.fn.bufload(bufnr)
  return bufnr
end

---@param expected any
---@param actual any
---@param label string
function M.eq(expected, actual, label)
  total = total + 1
  if vim.deep_equal(expected, actual) then
    return
  end
  failures = failures + 1
  io.write(
    ("FAIL %s\n  expected: %s\n  actual:   %s\n"):format(label, vim.inspect(expected), vim.inspect(actual))
  )
end

function M.finish()
  io.write(("%d/%d passed\n"):format(total - failures, total))
  vim.cmd("cquit " .. (failures > 0 and 1 or 0))
end

return M
