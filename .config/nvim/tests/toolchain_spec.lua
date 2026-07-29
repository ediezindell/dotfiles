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

do
  local root = h.fixture({
    files = { ["package.json"] = "{}", ["packages/app/src/index.ts"] = "" },
    exe = { "node_modules/.bin/prettier", "packages/app/node_modules/.bin/eslint" },
  })
  local bufnr = h.buf(root .. "/packages/app/src/index.ts")
  h.eq(
    root .. "/packages/app/node_modules/.bin/eslint",
    toolchain.bin(bufnr, "eslint"),
    "最も近い node_modules/.bin を使う"
  )
  h.eq(
    root .. "/node_modules/.bin/prettier",
    toolchain.bin(bufnr, "prettier"),
    "上位の node_modules/.bin まで遡る"
  )
  h.eq(nil, toolchain.local_bin(bufnr, "oxlint"), "local に無ければ local_bin は nil")
  h.eq("sh", toolchain.bin(bufnr, "sh"), "local に無ければグローバルにフォールバックする")
  h.eq(nil, toolchain.bin(bufnr, "no-such-command-xyz"), "どこにも無ければ nil")
  h.eq(
    root .. "/node_modules/.bin/prettier",
    toolchain.local_bin(root, "prettier"),
    "ディレクトリパスからも解決できる"
  )
end

do
  local root = h.fixture({ files = { ["deno.json"] = "{}", ["mod.ts"] = "" } })
  local bufnr = h.buf(root .. "/mod.ts")
  h.eq(true, toolchain.is_deno(bufnr), "deno.json があれば deno プロジェクト")
  h.eq("denols", toolchain.ts_server(bufnr), "deno プロジェクトは denols")
  h.eq(root, toolchain.root_for(bufnr, "denols"), "denols の root は deno.json のディレクトリ")
end

do
  local root = h.fixture({ files = { ["denops/foo/main.ts"] = "" } })
  local bufnr = h.buf(root .. "/denops/foo/main.ts")
  h.eq("denols", toolchain.ts_server(bufnr), "denops ディレクトリがあれば denols")
end

do
  local root = h.fixture({
    files = { ["package.json"] = [[{"devDependencies":{"typescript":"~7.1.0"}}]], ["a.ts"] = "" },
  })
  h.eq("tsgo", toolchain.ts_server(h.buf(root .. "/a.ts")), "typescript 7 系なら tsgo")
end

do
  local root = h.fixture({
    files = {
      ["package.json"] = [[{"devDependencies":{"@typescript/native-preview":"latest","typescript":"5.6.0"}}]],
      ["a.ts"] = "",
    },
  })
  h.eq("tsgo", toolchain.ts_server(h.buf(root .. "/a.ts")), "native-preview があれば tsgo")
end

do
  local root = h.fixture({
    files = {
      ["tsconfig.json"] = "{}",
      ["package.json"] = [[{"devDependencies":{"typescript":"^5.6.0"}}]],
      ["a.ts"] = "",
    },
  })
  h.eq("vtsls", toolchain.ts_server(h.buf(root .. "/a.ts")), "typescript 5 系なら vtsls")
end

do
  local root = h.fixture({ files = { ["a.ts"] = "" } })
  h.eq(nil, toolchain.ts_server(h.buf(root .. "/a.ts")), "目印が何も無ければ nil")
end

do
  local root = h.fixture({
    files = {
      ["pnpm-lock.yaml"] = "",
      ["packages/app/package.json"] = "{}",
      ["packages/app/a.ts"] = "",
    },
  })
  local bufnr = h.buf(root .. "/packages/app/a.ts")
  h.eq(root, toolchain.project_root(bufnr), "lock ファイルのあるディレクトリが project root")
  h.eq(root, toolchain.root_for(bufnr, "vtsls"), "vtsls の root は project root")
end

do
  local root = h.fixture({ files = { ["packages/app/package.json"] = "{}", ["packages/app/a.ts"] = "" } })
  local bufnr = h.buf(root .. "/packages/app/a.ts")
  h.eq(
    root .. "/packages/app",
    toolchain.project_root(bufnr),
    "lock ファイルが無ければ package.json のディレクトリ"
  )
end

do
  local root = h.fixture({ files = { ["a.ts"] = "" } })
  local bufnr = h.buf(root .. "/a.ts")
  local prompts = 0
  vim.ui.select = function(items, _, on_choice)
    prompts = prompts + 1
    h.eq({ "tsgo", "denols", "no launch" }, items, "選択肢は tsgo / denols / no launch")
    on_choice("tsgo")
  end

  local started = {}
  for _, name in ipairs({ "vtsls", "denols", "tsgo" }) do
    toolchain.activate_ts(bufnr, name, function(dir)
      started[name] = dir
    end)
  end
  h.eq(1, prompts, "プロンプトは 1 回だけ表示される")
  h.eq({ tsgo = root }, started, "選んだ tsgo だけが起動する")
  h.eq("tsgo", toolchain.ts_choice(bufnr), "選択結果が記録される")

  local second = root .. "/b.ts"
  local fd = assert(io.open(second, "w"))
  fd:close()
  local started2 = {}
  toolchain.activate_ts(h.buf(second), "tsgo", function(dir)
    started2.tsgo = dir
  end)
  h.eq(1, prompts, "同じディレクトリの別ファイルでは再度尋ねない")
  h.eq({ tsgo = root }, started2, "記録済みの選択で起動する")
end

do
  local root = h.fixture({ files = { ["a.ts"] = "" } })
  local bufnr = h.buf(root .. "/a.ts")
  local prompts, respond = 0, nil
  vim.ui.select = function(_, _, on_choice)
    prompts = prompts + 1
    respond = on_choice
  end
  local started = {}
  toolchain.activate_ts(bufnr, "denols", function(dir)
    started.denols = dir
  end)
  toolchain.activate_ts(bufnr, "tsgo", function(dir)
    started.tsgo = dir
  end)
  h.eq(1, prompts, "応答前に 2 件来てもプロンプトは 1 回")
  respond("denols")
  h.eq({ denols = root }, started, "選んだ denols だけが起動する")
  h.eq("denols", toolchain.ts_choice(bufnr), "denols が記録される")
end

do
  local root = h.fixture({ files = { ["a.ts"] = "" } })
  local bufnr = h.buf(root .. "/a.ts")
  vim.ui.select = function(_, _, on_choice)
    on_choice("no launch")
  end
  local started = {}
  toolchain.activate_ts(bufnr, "tsgo", function(dir)
    started.tsgo = dir
  end)
  toolchain.activate_ts(bufnr, "denols", function(dir)
    started.denols = dir
  end)
  h.eq({}, started, "no launch を選ぶとどちらも起動しない")
  h.eq(nil, toolchain.ts_choice(bufnr), "no launch は選択として記録されない")
end

do
  local root = h.fixture({ files = { ["a.ts"] = "" } })
  local bufnr = h.buf(root .. "/a.ts")
  local prompts = 0
  vim.ui.select = function(_, _, on_choice)
    prompts = prompts + 1
    on_choice(nil)
  end
  toolchain.activate_ts(bufnr, "tsgo", function() end)
  toolchain.activate_ts(bufnr, "tsgo", function() end)
  h.eq(2, prompts, "中断した場合は記録せず次回また尋ねる")
end

do
  local root = h.fixture({ files = { ["tsconfig.json"] = "{}", ["a.ts"] = "" } })
  local bufnr = h.buf(root .. "/a.ts")
  local prompts = 0
  vim.ui.select = function(_, _, on_choice)
    prompts = prompts + 1
    on_choice("tsgo")
  end
  local started = {}
  toolchain.activate_ts(bufnr, "vtsls", function(dir)
    started.vtsls = dir
  end)
  h.eq(0, prompts, "自動判定できる場合は尋ねない")
  h.eq({ vtsls = root }, started, "判定結果の vtsls が起動する")
  h.eq(nil, toolchain.ts_choice(bufnr), "自動判定の結果は選択として記録しない")
end

do
  local root = h.fixture({ files = { ["a.ts"] = "" } })
  local bufnr = h.buf(root .. "/a.ts")
  h.eq(nil, toolchain.ts_choice(bufnr), "未決定なら ts_choice は nil")
end

do
  local root = h.fixture({ files = { ["a.ts"] = "" } })
  local bufnr = h.buf(root .. "/a.ts")
  local prompts = 0
  vim.ui.select = function(_, _, on_choice)
    prompts = prompts + 1
    on_choice("no launch")
  end
  toolchain.activate_ts(bufnr, "tsgo", function() end)
  toolchain.activate_ts(bufnr, "tsgo", function() end)
  h.eq(1, prompts, "no launch 決定後の再問い合わせはプロンプトを開かない")
end

do
  local root = h.fixture({ files = { ["a.ts"] = "" } })
  local bufnr = h.buf(root .. "/a.ts")
  vim.ui.select = function(_, _, on_choice)
    on_choice("tsgo")
  end
  toolchain.activate_ts(bufnr, "tsgo", function() end)
  vim.api.nvim_set_current_buf(bufnr)
  vim.api.nvim_create_augroup("nvim.lsp.enable", { clear = false })
  toolchain.reselect_ts()
  h.eq(nil, toolchain.ts_choice(bufnr), "reselect_ts は記録済みの選択を消す")
end

do
  local root = h.fixture({ files = { ["a.ts"] = "" } })
  local bufnr = h.buf(root .. "/a.ts")
  local respond
  vim.ui.select = function(_, _, on_choice)
    respond = on_choice
  end
  toolchain.activate_ts(bufnr, "tsgo", function() end)
  vim.api.nvim_set_current_buf(bufnr)
  vim.api.nvim_create_augroup("nvim.lsp.enable", { clear = false })
  toolchain.reselect_ts()
  respond("tsgo")
  h.eq("tsgo", toolchain.ts_choice(bufnr), "プロンプト表示中の reselect_ts は何もせず、応答は通常通り記録される")
end

h.finish()
