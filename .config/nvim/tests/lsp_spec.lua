package.path = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)) .. "/?.lua;" .. package.path
local h = require("helper")

local SERVERS = { "vtsls", "denols", "tsgo" }

--- 3 つの config の root_dir を順に呼び、起動した server 名 -> root を返す
---@param bufnr integer
---@return table<string, string>
local function activate(bufnr)
  local started = {}
  for _, name in ipairs(SERVERS) do
    local config = vim.lsp.config[name]
    h.eq("function", type(config.root_dir), name .. " の root_dir は関数")
    config.root_dir(bufnr, function(dir)
      started[name] = dir
    end)
  end
  return started
end

do
  local root = h.fixture({ files = { ["deno.json"] = "{}", ["mod.ts"] = "" } })
  h.eq({ denols = root }, activate(h.buf(root .. "/mod.ts")), "deno プロジェクトは denols だけ起動する")
end

do
  local root = h.fixture({
    files = { ["package.json"] = [[{"devDependencies":{"typescript":"^7.0.2"}}]], ["a.ts"] = "" },
  })
  h.eq({ tsgo = root }, activate(h.buf(root .. "/a.ts")), "typescript 7 は tsgo だけ起動する")
end

do
  local root = h.fixture({
    files = {
      ["tsconfig.json"] = "{}",
      ["package.json"] = [[{"devDependencies":{"typescript":"^5.6.0"}}]],
      ["a.ts"] = "",
    },
  })
  h.eq({ vtsls = root }, activate(h.buf(root .. "/a.ts")), "typescript 5 は vtsls だけ起動する")
end

do
  local root = h.fixture({
    files = { ["package.json"] = [[{"devDependencies":{"typescript":"^7.0.2"}}]], ["a.ts"] = "" },
    exe = { "node_modules/.bin/tsc" },
  })
  local captured
  local original = vim.lsp.rpc.start
  vim.lsp.rpc.start = function(cmd)
    captured = cmd
    return {}
  end
  vim.lsp.config["tsgo"].cmd({}, { root_dir = root })
  vim.lsp.rpc.start = original
  h.eq(
    { root .. "/node_modules/.bin/tsc", "--lsp", "--stdio" },
    captured,
    "TypeScript 7 では local tsc を --lsp で起動する"
  )
end

do
  local root = h.fixture({
    files = { ["package.json"] = [[{"devDependencies":{"@typescript/native-preview":"latest"}}]], ["a.ts"] = "" },
    exe = { "node_modules/.bin/tsgo", "node_modules/.bin/tsc" },
  })
  local captured
  local original = vim.lsp.rpc.start
  vim.lsp.rpc.start = function(cmd)
    captured = cmd
    return {}
  end
  vim.lsp.config["tsgo"].cmd({}, { root_dir = root })
  vim.lsp.rpc.start = original
  h.eq(
    { root .. "/node_modules/.bin/tsgo", "--lsp", "--stdio" },
    captured,
    "tsgo と tsc の両方があれば tsgo を使う"
  )
end

h.finish()
