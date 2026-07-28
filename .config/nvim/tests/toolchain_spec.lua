package.path = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)) .. "/?.lua;" .. package.path
local h = require("helper")
local toolchain = require("toolchain")

do
  local root = h.fixture({
    files = {
      ["package.json"] = [[{"devDependencies":{"typescript":"^7.0.2","eslint":"9.0.0"},"scripts":{"lint":"biome check"}}]],
      ["src/index.ts"] = "",
    },
  })
  local bufnr = h.buf(root .. "/src/index.ts")
  h.eq(true, toolchain.has_dep(bufnr, "eslint"), "devDependencies の eslint を検出する")
  h.eq(7, toolchain.dep_major(bufnr, "typescript"), "^7.0.2 のメジャー版は 7")
  h.eq(false, toolchain.has_dep(bufnr, "@biomejs/biome"), "scripts 内の biome を依存と誤検出しない")
  h.eq(nil, toolchain.dep_major(bufnr, "@biomejs/biome"), "未導入の依存はメジャー版が nil")
end

do
  local root = h.fixture({ files = { ["package.json"] = [[{"dependencies":{"typescript":"latest"}}]], ["a.ts"] = "" } })
  local bufnr = h.buf(root .. "/a.ts")
  h.eq(true, toolchain.has_dep(bufnr, "typescript"), "dependencies も見る")
  h.eq(nil, toolchain.dep_major(bufnr, "typescript"), "latest からはメジャー版を決められない")
end

do
  local root = h.fixture({ files = { ["a.ts"] = "" } })
  local bufnr = h.buf(root .. "/a.ts")
  h.eq(nil, toolchain.pkg(bufnr), "package.json が無ければ nil")
  h.eq(false, toolchain.has_dep(bufnr, "eslint"), "package.json が無ければ依存なし")
end

do
  local root = h.fixture({ files = { ["package.json"] = "{ broken", ["a.ts"] = "" } })
  local bufnr = h.buf(root .. "/a.ts")
  local original_notify_once = vim.notify_once
  local notify_called = false
  local notify_msg = nil
  vim.notify_once = function(msg, level)
    notify_called = true
    notify_msg = msg
  end
  h.eq(nil, toolchain.pkg(bufnr), "パースできない package.json は nil")
  h.eq(true, notify_called and notify_msg:find(root .. "/package.json") ~= nil, "パースエラー通知が呼ばれて package.json のパスが含まれる")
  vim.notify_once = original_notify_once
end

h.finish()
