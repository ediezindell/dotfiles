# JS/TS ツールチェーン自動判定 実装計画

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Neovim で開いた buffer の位置から JS/TS ツールチェーン (LSP / linter / formatter) を自動判定し、local install をグローバルより優先して起動する。

**Architecture:** 判定ロジックを `lua/toolchain.lua` の 1 モジュールに集約する。LSP は `after/lsp/*.lua` の `root_dir` コールバックで buffer 単位に起動可否を決める。conform と nvim-lint も同じモジュールを参照する。プロジェクトの目印が無い単独ファイルは `vim.ui.select` で tsgo / denols / no launch を選ばせる。

**Tech Stack:** Neovim 0.12 の `vim.lsp.config` / `vim.lsp.enable`、nvim-lspconfig (base config 提供)、conform.nvim、nvim-lint、mason-tool-installer

**設計:** `docs/superpowers/specs/2026-07-29-js-ts-toolchain-autodetect-design.md`

## Global Constraints

- 対象リポジトリは `/home/edie/git/dotfiles`、作業ブランチは `jules-7636377819295997141-ad8a8eb7` (PR #6 が open)
- `~/.config/nvim` はこのリポジトリの `.config/nvim` へのシンボリックリンク。実機確認は素の `nvim` で行える
- テストは `nvim -u NONE -l <spec>` で実行する。プラグインに依存しない (plenary も使わない)
- グローバルの `tsc` は版が特定できず `--lsp` を持たない可能性があるため、LSP の起動コマンド候補に入れない
- 既存の判定は package.json を正規表現でマッチしている。置き換え後は `vim.json.decode` + 依存キーの完全一致のみを使う
- コメントは「内部からも外部からも引けない情報」だけ書く。関数本体の言い直しは書かない
- 各タスクの最後に commit する。`--no-verify` は使わない

---

## File Structure

| ファイル | 責務 |
|---|---|
| `.config/nvim/lua/toolchain.lua` | 判定ロジックの単一の置き場。依存解析 / バイナリ解決 / LSP 選択 / linter・formatter 選択 |
| `.config/nvim/after/lsp/tsgo.lua` | tsgo (TypeScript 7 系) の起動条件とコマンド解決 |
| `.config/nvim/after/lsp/vtsls.lua` | vtsls の起動条件 (既存ファイルに `root_dir` を追加) |
| `.config/nvim/after/lsp/denols.lua` | denols の起動条件 (既存ファイルに `root_dir` を追加) |
| `.config/nvim/lua/lsp.lua` | LSP の有効化リストと `:TSLspSelect` の登録 |
| `.config/nvim/lua/autocmds.lua` | TypeScript LS 起動用 FileType autocmd を削除 |
| `.config/nvim/lua/plugins/conform.lua` | formatter の配線 |
| `.config/nvim/lua/plugins/nvim-lint.lua` | linter の配線 |
| `.config/nvim/lua/plugins/mason.lua` | `tsgo` / `oxfmt` の追加 |
| `.config/nvim/tests/helper.lua` | fixture 生成 / アサーション / 終了コード |
| `.config/nvim/tests/toolchain_spec.lua` | `toolchain.lua` のテスト |
| `.config/nvim/tests/lsp_spec.lua` | `after/lsp/*.lua` の配線テスト |

---

### Task 1: テスト基盤と package.json の依存解析

**Files:**
- Create: `.config/nvim/tests/helper.lua`
- Create: `.config/nvim/tests/toolchain_spec.lua`
- Create: `.config/nvim/lua/toolchain.lua`

**Interfaces:**
- Consumes: なし (最初のタスク)
- Produces:
  - `helper.fixture(spec: { files?: table<string,string>, dirs?: string[], exe?: string[] }): string` — tempdir に fixture を作り root パスを返す
  - `helper.buf(path: string): integer` — そのパスを指す buffer を作って bufnr を返す
  - `helper.eq(expected: any, actual: any, label: string)` — 比較して失敗を記録する
  - `helper.finish()` — 集計を出力し、失敗があれば終了コード 1 で終わる
  - `toolchain.pkg(bufnr: integer): table?` — buffer が属する package.json のパース結果
  - `toolchain.dep_version(bufnr: integer, name: string): string?`
  - `toolchain.has_dep(bufnr: integer, name: string): boolean`
  - `toolchain.dep_major(bufnr: integer, name: string): integer?`

- [ ] **Step 1: テストヘルパを書く**

`.config/nvim/tests/helper.lua`:

```lua
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
```

- [ ] **Step 2: 失敗するテストを書く**

`.config/nvim/tests/toolchain_spec.lua`:

```lua
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
  h.eq(nil, toolchain.pkg(bufnr), "パースできない package.json は nil")
end

h.finish()
```

- [ ] **Step 3: テストを実行して失敗を確認する**

Run: `cd /home/edie/git/dotfiles && nvim -u NONE -l .config/nvim/tests/toolchain_spec.lua`
Expected: `module 'toolchain' not found` を含むエラーで終了する

- [ ] **Step 4: `toolchain.lua` を実装する**

`.config/nvim/lua/toolchain.lua`:

```lua
--- JS/TS プロジェクトのツールチェーン判定
--- after/lsp/*.lua / conform / nvim-lint はすべてこのモジュールを参照する
local M = {}

local DEP_FIELDS = { "dependencies", "devDependencies" }

---@param bufnr integer
---@return string
local function buf_dir(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return vim.fn.getcwd()
  end
  return vim.fs.dirname(name)
end

---@param bufnr integer
---@param markers string[]|string[][]
---@return string?
local function root(bufnr, markers)
  return vim.fs.root(buf_dir(bufnr), markers)
end

local pkg_cache = {}

---@param bufnr integer
---@return table?
function M.pkg(bufnr)
  local dir = root(bufnr, { "package.json" })
  if not dir then
    return nil
  end
  local path = dir .. "/package.json"
  local stat = vim.uv.fs_stat(path)
  if not stat then
    return nil
  end
  local cached = pkg_cache[path]
  if cached and cached.mtime == stat.mtime.sec then
    return cached.data
  end
  local fd = io.open(path, "r")
  if not fd then
    return nil
  end
  local content = fd:read("*a")
  fd:close()
  local ok, data = pcall(vim.json.decode, content)
  if not ok or type(data) ~= "table" then
    vim.notify_once(("failed to parse %s"):format(path), vim.log.levels.WARN)
    data = nil
  end
  pkg_cache[path] = { mtime = stat.mtime.sec, data = data }
  return data
end

---@param bufnr integer
---@param name string
---@return string?
function M.dep_version(bufnr, name)
  local pkg = M.pkg(bufnr)
  if not pkg then
    return nil
  end
  for _, field in ipairs(DEP_FIELDS) do
    local deps = pkg[field]
    if type(deps) == "table" and type(deps[name]) == "string" then
      return deps[name]
    end
  end
  return nil
end

---@param bufnr integer
---@param name string
---@return boolean
function M.has_dep(bufnr, name)
  return M.dep_version(bufnr, name) ~= nil
end

--- "^7.0.2" からメジャー版を取り出す。"latest" / "workspace:*" 等は nil
---@param bufnr integer
---@param name string
---@return integer?
function M.dep_major(bufnr, name)
  local version = M.dep_version(bufnr, name)
  if not version then
    return nil
  end
  return tonumber(version:match("%d+"))
end

return M
```

- [ ] **Step 5: テストを実行して成功を確認する**

Run: `cd /home/edie/git/dotfiles && nvim -u NONE -l .config/nvim/tests/toolchain_spec.lua`
Expected: `9/9 passed` と表示され終了コード 0

- [ ] **Step 6: commit**

```bash
cd /home/edie/git/dotfiles
git add .config/nvim/tests/helper.lua .config/nvim/tests/toolchain_spec.lua .config/nvim/lua/toolchain.lua
git commit -m "feat(nvim): package.json の依存解析を toolchain モジュールに追加"
```

---

### Task 2: local install を優先するバイナリ解決

**Files:**
- Modify: `.config/nvim/lua/toolchain.lua`
- Modify: `.config/nvim/tests/toolchain_spec.lua`

**Interfaces:**
- Consumes: `toolchain.pkg` / `toolchain.has_dep` / `toolchain.dep_major` (Task 1)
- Produces:
  - `toolchain.local_bin(ctx: integer|string, name: string): string?` — `node_modules/.bin/<name>` を上方向に探して絶対パスを返す。グローバルにはフォールバックしない。`ctx` は bufnr でもディレクトリ / ファイルパスでもよい
  - `toolchain.bin(ctx: integer|string, name: string): string?` — `local_bin` を優先し、無ければグローバルの実行可能ファイル名

- [ ] **Step 1: 失敗するテストを追加する**

`.config/nvim/tests/toolchain_spec.lua` の `h.finish()` の直前に追加:

```lua
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
```

- [ ] **Step 2: テストを実行して失敗を確認する**

Run: `cd /home/edie/git/dotfiles && nvim -u NONE -l .config/nvim/tests/toolchain_spec.lua`
Expected: `attempt to call field 'bin' (a nil value)` を含むエラーで終了する

- [ ] **Step 3: `local_bin` / `bin` を実装する**

`.config/nvim/lua/toolchain.lua` の `buf_dir` を次の `base_dir` に差し替え、`root` の中の `buf_dir` 呼び出しも `base_dir` に変える:

```lua
---@param ctx integer|string bufnr、またはファイル / ディレクトリのパス
---@return string
local function base_dir(ctx)
  if type(ctx) == "number" then
    local name = vim.api.nvim_buf_get_name(ctx)
    return name == "" and vim.fn.getcwd() or vim.fs.dirname(name)
  end
  return vim.fn.isdirectory(ctx) == 1 and ctx or vim.fs.dirname(ctx)
end

---@param ctx integer|string
---@param markers string[]|string[][]
---@return string?
local function root(ctx, markers)
  return vim.fs.root(base_dir(ctx), markers)
end
```

`return M` の直前に追加:

```lua
---@param ctx integer|string
---@param name string
---@return string?
function M.local_bin(ctx, name)
  local found = vim.fs.find("node_modules", {
    path = base_dir(ctx),
    upward = true,
    type = "directory",
    limit = math.huge,
  })
  for _, dir in ipairs(found) do
    local candidate = dir .. "/.bin/" .. name
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end
  return nil
end

---@param ctx integer|string
---@param name string
---@return string?
function M.bin(ctx, name)
  local found = M.local_bin(ctx, name)
  if found then
    return found
  end
  if vim.fn.executable(name) == 1 then
    return name
  end
  return nil
end
```

- [ ] **Step 4: テストを実行して成功を確認する**

Run: `cd /home/edie/git/dotfiles && nvim -u NONE -l .config/nvim/tests/toolchain_spec.lua`
Expected: `15/15 passed` と表示され終了コード 0

- [ ] **Step 5: commit**

```bash
cd /home/edie/git/dotfiles
git add .config/nvim/lua/toolchain.lua .config/nvim/tests/toolchain_spec.lua
git commit -m "feat(nvim): local install を優先するバイナリ解決を追加"
```

---

### Task 3: TypeScript LS の自動判定と workspace root

**Files:**
- Modify: `.config/nvim/lua/toolchain.lua`
- Modify: `.config/nvim/tests/toolchain_spec.lua`

**Interfaces:**
- Consumes: `toolchain.has_dep` / `toolchain.dep_major` (Task 1)
- Produces:
  - `toolchain.is_deno(bufnr: integer): boolean`
  - `toolchain.ts_server(bufnr: integer): "denols"|"tsgo"|"vtsls"|nil` — 自動判定できないときは nil
  - `toolchain.project_root(bufnr: integer): string`
  - `toolchain.root_for(bufnr: integer, server: string): string`

- [ ] **Step 1: 失敗するテストを追加する**

`.config/nvim/tests/toolchain_spec.lua` の `h.finish()` の直前に追加:

```lua
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
```

- [ ] **Step 2: テストを実行して失敗を確認する**

Run: `cd /home/edie/git/dotfiles && nvim -u NONE -l .config/nvim/tests/toolchain_spec.lua`
Expected: `attempt to call field 'is_deno' (a nil value)` を含むエラーで終了する

- [ ] **Step 3: 判定関数を実装する**

`.config/nvim/lua/toolchain.lua` の `local DEP_FIELDS = ...` の下にマーカー定義を追加:

```lua
local DENO_MARKERS = { "deno.json", "deno.jsonc", "deno.lock", "denops" }
local NODE_MARKERS = { "tsconfig.json", "jsconfig.json", "package.json" }
local LOCK_MARKERS = { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock" }
```

`return M` の直前に追加:

```lua
---@param bufnr integer
---@return boolean
function M.is_deno(bufnr)
  return root(bufnr, DENO_MARKERS) ~= nil
end

--- 自動判定できる場合のみサーバー名を返す
---@param bufnr integer
---@return "denols"|"tsgo"|"vtsls"|nil
function M.ts_server(bufnr)
  if M.is_deno(bufnr) then
    return "denols"
  end
  if M.has_dep(bufnr, "@typescript/native-preview") or (M.dep_major(bufnr, "typescript") or 0) >= 7 then
    return "tsgo"
  end
  if root(bufnr, NODE_MARKERS) then
    return "vtsls"
  end
  return nil
end

---@param bufnr integer
---@return string
function M.project_root(bufnr)
  return root(bufnr, { LOCK_MARKERS, { ".git" } }) or root(bufnr, NODE_MARKERS) or base_dir(bufnr)
end

---@param bufnr integer
---@param server string
---@return string
function M.root_for(bufnr, server)
  if server == "denols" then
    return root(bufnr, { DENO_MARKERS, { ".git" } }) or base_dir(bufnr)
  end
  return M.project_root(bufnr)
end
```

- [ ] **Step 4: テストを実行して成功を確認する**

Run: `cd /home/edie/git/dotfiles && nvim -u NONE -l .config/nvim/tests/toolchain_spec.lua`
Expected: `26/26 passed` と表示され終了コード 0

- [ ] **Step 5: commit**

```bash
cd /home/edie/git/dotfiles
git add .config/nvim/lua/toolchain.lua .config/nvim/tests/toolchain_spec.lua
git commit -m "feat(nvim): TypeScript LS の自動判定と workspace root 解決を追加"
```

---

### Task 4: プロジェクト外ファイルの LSP 選択

**Files:**
- Modify: `.config/nvim/lua/toolchain.lua`
- Modify: `.config/nvim/tests/toolchain_spec.lua`

**Interfaces:**
- Consumes: `toolchain.ts_server` / `toolchain.root_for` (Task 3)
- Produces:
  - `toolchain.activate_ts(bufnr: integer, name: string, on_dir: fun(root_dir?: string))` — `name` を起動すべきなら `on_dir` を呼ぶ
  - `toolchain.ts_choice(bufnr: integer): string?` — 記録済みの選択。未選択 / no launch は nil
  - `toolchain.reselect_ts(bufnr: integer)` — 記録を破棄してクライアントを停止し再判定する

- [ ] **Step 1: 失敗するテストを追加する**

`.config/nvim/tests/toolchain_spec.lua` の `h.finish()` の直前に追加:

```lua
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
```

- [ ] **Step 2: テストを実行して失敗を確認する**

Run: `cd /home/edie/git/dotfiles && nvim -u NONE -l .config/nvim/tests/toolchain_spec.lua`
Expected: `attempt to call field 'activate_ts' (a nil value)` を含むエラーで終了する

- [ ] **Step 3: 選択ロジックを実装する**

`.config/nvim/lua/toolchain.lua` の `return M` の直前に追加:

```lua
local NO_LAUNCH = "no launch"
--- 自動判定できないときにユーザーに提示するサーバー
local PICKABLE = { "tsgo", "denols" }

--- ディレクトリ -> "tsgo" | "denols" | false (起動しない)
local decided = {}
--- ディレクトリ -> 応答待ちのコールバック
local waiting = {}

---@param bufnr integer
---@return string?
function M.ts_choice(bufnr)
  local choice = decided[base_dir(bufnr)]
  if choice then
    return choice
  end
  return nil
end

--- 同じディレクトリに対する問い合わせを 1 回のプロンプトに集約する
---@param dir string
---@param cb fun(choice: string|false)
local function ask(dir, cb)
  if decided[dir] ~= nil then
    cb(decided[dir])
    return
  end
  if waiting[dir] then
    table.insert(waiting[dir], cb)
    return
  end
  waiting[dir] = { cb }
  local items = vim.list_extend(vim.deepcopy(PICKABLE), { NO_LAUNCH })
  vim.ui.select(items, { prompt = "select LSP for TypeScript: " }, function(item)
    local choice = (item == nil or item == NO_LAUNCH) and false or item
    -- 中断は記録しない。次に開いたときまた尋ねる
    if item ~= nil then
      decided[dir] = choice
    end
    local waiters = waiting[dir] or {}
    waiting[dir] = nil
    for _, waiter in ipairs(waiters) do
      waiter(choice)
    end
  end)
end

--- vim.lsp.Config の root_dir から呼ぶ。起動すべきときだけ on_dir を呼ぶ
---@param bufnr integer
---@param name string
---@param on_dir fun(root_dir?: string)
function M.activate_ts(bufnr, name, on_dir)
  local server = M.ts_server(bufnr)
  if server then
    if server == name then
      on_dir(M.root_for(bufnr, name))
    end
    return
  end
  if not vim.tbl_contains(PICKABLE, name) then
    return
  end
  local dir = base_dir(bufnr)
  ask(dir, function(choice)
    if choice == name then
      on_dir(dir)
    end
  end)
end

---@param bufnr integer
function M.reselect_ts(bufnr)
  local dir = base_dir(bufnr)
  decided[dir] = nil
  waiting[dir] = nil
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if vim.tbl_contains(PICKABLE, client.name) then
      client:stop()
    end
  end
  vim.cmd("doautocmd nvim.lsp.enable FileType")
end
```

- [ ] **Step 4: テストを実行して成功を確認する**

Run: `cd /home/edie/git/dotfiles && nvim -u NONE -l .config/nvim/tests/toolchain_spec.lua`
Expected: `41/41 passed` と表示され終了コード 0

- [ ] **Step 5: commit**

```bash
cd /home/edie/git/dotfiles
git add .config/nvim/lua/toolchain.lua .config/nvim/tests/toolchain_spec.lua
git commit -m "feat(nvim): プロジェクト外ファイルの TypeScript LSP 選択を追加"
```

---

### Task 5: linter / formatter の選択

**Files:**
- Modify: `.config/nvim/lua/toolchain.lua`
- Modify: `.config/nvim/tests/toolchain_spec.lua`

**Interfaces:**
- Consumes: `toolchain.is_deno` / `toolchain.has_dep` / `toolchain.bin` / `toolchain.ts_choice` (Task 1-4)
- Produces:
  - `toolchain.linters(bufnr: integer): string[]` — nvim-lint に渡す linter 名
  - `toolchain.formatters(bufnr: integer, ft?: string): string[]` — conform に渡す formatter 名。`ft` 省略時は buffer の filetype

- [ ] **Step 1: 失敗するテストを追加する**

`.config/nvim/tests/toolchain_spec.lua` の `h.finish()` の直前に追加:

```lua
do
  local root = h.fixture({ files = { ["deno.json"] = "{}", ["a.ts"] = "" } })
  local bufnr = h.buf(root .. "/a.ts")
  h.eq({}, toolchain.linters(bufnr), "deno は denols の診断に任せる")
  h.eq({ "deno_fmt" }, toolchain.formatters(bufnr, "typescript"), "deno は deno_fmt")
end

do
  local root = h.fixture({ files = { ["biome.json"] = "{}", ["package.json"] = "{}", ["a.ts"] = "" } })
  local bufnr = h.buf(root .. "/a.ts")
  h.eq({}, toolchain.linters(bufnr), "biome は LSP の診断に任せる")
  h.eq({ "biome" }, toolchain.formatters(bufnr, "typescript"), "biome プロジェクトは biome")
end

do
  local root = h.fixture({
    files = { ["package.json"] = [[{"devDependencies":{"@biomejs/biome":"^2.0.0"}}]], ["a.ts"] = "" },
  })
  h.eq(
    { "biome" },
    toolchain.formatters(h.buf(root .. "/a.ts"), "css"),
    "biome は設定ファイルが無くても依存で検出する"
  )
end

do
  local root = h.fixture({
    files = { ["package.json"] = [[{"devDependencies":{"oxlint":"^1.0.0","eslint":"^9.0.0"}}]], ["a.ts"] = "" },
    exe = { "node_modules/.bin/oxlint", "node_modules/.bin/eslint", "node_modules/.bin/prettier" },
  })
  local bufnr = h.buf(root .. "/a.ts")
  h.eq({ "oxlint", "eslint" }, toolchain.linters(bufnr), "oxlint と eslint は両方実行する")
  h.eq({ "prettier" }, toolchain.formatters(bufnr, "typescript"), "他に無ければ prettier")
end

do
  local root = h.fixture({ files = { ["eslint.config.js"] = "", ["package.json"] = "{}", ["a.ts"] = "" } })
  h.eq(
    { "eslint_d" },
    toolchain.linters(h.buf(root .. "/a.ts")),
    "local eslint が無ければ eslint_d にフォールバックする"
  )
end

do
  local root = h.fixture({ files = { ["package.json"] = "{}", ["a.ts"] = "" } })
  local bufnr = h.buf(root .. "/a.ts")
  h.eq({}, toolchain.linters(bufnr), "何も検出しなければ linter は空")
  h.eq({}, toolchain.formatters(bufnr, "typescript"), "prettier も無ければ formatter は空")
end

do
  local root = h.fixture({
    files = { [".oxfmtrc.json"] = "{}", ["package.json"] = "{}", ["a.ts"] = "" },
    exe = { "node_modules/.bin/prettier" },
  })
  local bufnr = h.buf(root .. "/a.ts")
  h.eq({ "oxfmt" }, toolchain.formatters(bufnr, "typescript"), "oxfmt は JS/TS に使う")
  h.eq({ "prettier" }, toolchain.formatters(bufnr, "css"), "oxfmt は css には使わない")
end

do
  local root = h.fixture({ files = { ["a.ts"] = "" }, exe = { "node_modules/.bin/prettier" } })
  local bufnr = h.buf(root .. "/a.ts")
  vim.ui.select = function(_, _, on_choice)
    on_choice("denols")
  end
  toolchain.activate_ts(bufnr, "denols", function() end)
  h.eq(
    { "deno_fmt" },
    toolchain.formatters(bufnr, "typescript"),
    "denols を選んだプロジェクト外ファイルは deno_fmt"
  )
end
```

- [ ] **Step 2: テストを実行して失敗を確認する**

Run: `cd /home/edie/git/dotfiles && nvim -u NONE -l .config/nvim/tests/toolchain_spec.lua`
Expected: `attempt to call field 'linters' (a nil value)` を含むエラーで終了する

- [ ] **Step 3: 選択関数を実装する**

`.config/nvim/lua/toolchain.lua` のマーカー定義群に追加:

```lua
local BIOME_MARKERS = { "biome.json", "biome.jsonc", ".biome.json", ".biome.jsonc" }
local OXLINT_MARKERS = { ".oxlintrc.json", "oxlint.json" }
local OXFMT_MARKERS = { ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts" }
local ESLINT_MARKERS = {
  "eslint.config.js",
  "eslint.config.mjs",
  "eslint.config.cjs",
  "eslint.config.ts",
  "eslint.config.mts",
  "eslint.config.cts",
  ".eslintrc",
  ".eslintrc.js",
  ".eslintrc.cjs",
  ".eslintrc.json",
  ".eslintrc.yml",
  ".eslintrc.yaml",
}
local JS_FILETYPES = {
  "javascript",
  "javascriptreact",
  "javascript.jsx",
  "typescript",
  "typescriptreact",
  "typescript.tsx",
}
```

`return M` の直前に追加:

```lua
---@param bufnr integer
---@return boolean
local function has_biome(bufnr)
  return root(bufnr, BIOME_MARKERS) ~= nil or M.has_dep(bufnr, "@biomejs/biome")
end

---@param bufnr integer
---@return boolean
local function has_eslint(bufnr)
  return root(bufnr, ESLINT_MARKERS) ~= nil or M.has_dep(bufnr, "eslint")
end

---@param bufnr integer
---@return boolean
local function has_oxlint(bufnr)
  return root(bufnr, OXLINT_MARKERS) ~= nil or M.has_dep(bufnr, "oxlint")
end

---@param bufnr integer
---@return boolean
local function has_oxfmt(bufnr)
  return root(bufnr, OXFMT_MARKERS) ~= nil or M.has_dep(bufnr, "oxfmt")
end

--- deno / biome は LSP が同じ診断を出すので nvim-lint では走らせない
---@param bufnr integer
---@return string[]
function M.linters(bufnr)
  if M.is_deno(bufnr) or has_biome(bufnr) then
    return {}
  end
  local linters = {}
  if has_oxlint(bufnr) then
    table.insert(linters, "oxlint")
  end
  if has_eslint(bufnr) then
    table.insert(linters, M.bin(bufnr, "eslint") and "eslint" or "eslint_d")
  end
  return linters
end

---@param bufnr integer
---@param ft? string
---@return string[]
function M.formatters(bufnr, ft)
  ft = ft or vim.bo[bufnr].filetype
  if M.is_deno(bufnr) or M.ts_choice(bufnr) == "denols" then
    return { "deno_fmt" }
  end
  if has_biome(bufnr) then
    return { "biome" }
  end
  if has_oxfmt(bufnr) and vim.tbl_contains(JS_FILETYPES, ft) then
    return { "oxfmt" }
  end
  if M.bin(bufnr, "prettier") then
    return { "prettier" }
  end
  return {}
end
```

- [ ] **Step 4: テストを実行して成功を確認する**

Run: `cd /home/edie/git/dotfiles && nvim -u NONE -l .config/nvim/tests/toolchain_spec.lua`
Expected: `54/54 passed` と表示され終了コード 0

- [ ] **Step 5: commit**

```bash
cd /home/edie/git/dotfiles
git add .config/nvim/lua/toolchain.lua .config/nvim/tests/toolchain_spec.lua
git commit -m "feat(nvim): linter / formatter の選択ロジックを追加"
```

---

### Task 6: LSP の配線

**Files:**
- Create: `.config/nvim/after/lsp/tsgo.lua`
- Create: `.config/nvim/tests/lsp_spec.lua`
- Modify: `.config/nvim/after/lsp/vtsls.lua`
- Modify: `.config/nvim/after/lsp/denols.lua`
- Modify: `.config/nvim/lua/lsp.lua`
- Modify: `.config/nvim/lua/autocmds.lua:216-253`
- Modify: `.config/nvim/lua/plugins/mason.lua`

**Interfaces:**
- Consumes: `toolchain.activate_ts` (Task 4)、`toolchain.local_bin` (Task 2)
- Produces: `vim.lsp.config["vtsls"|"denols"|"tsgo"].root_dir` が buffer 単位で起動判定する関数になる。`:TSLspSelect` コマンド

- [ ] **Step 1: 失敗するテストを書く**

`.config/nvim/tests/lsp_spec.lua`:

```lua
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
```

- [ ] **Step 2: テストを実行して失敗を確認する**

Run: `cd /home/edie/git/dotfiles && nvim -u NONE -l .config/nvim/tests/lsp_spec.lua`
Expected: `vtsls の root_dir は関数` の FAIL (実際は `nil`) を含み、終了コード 1

- [ ] **Step 3: `after/lsp/tsgo.lua` を作る**

`.config/nvim/after/lsp/tsgo.lua`:

```lua
local toolchain = require("toolchain")

--- @typescript/native-preview の tsgo と TypeScript 7 の tsc は同じ LSP を話す。
--- グローバルの tsc は版を特定できず --lsp を持たない可能性があるため候補に入れない。
---@param dir string?
---@return string
local function resolve_cmd(dir)
  if dir then
    for _, name in ipairs({ "tsgo", "tsc" }) do
      local bin = toolchain.local_bin(dir, name)
      if bin then
        return bin
      end
    end
  end
  return "tsgo"
end

---@type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    local cmd = resolve_cmd((config or {}).root_dir)
    return vim.lsp.rpc.start({ cmd, "--lsp", "--stdio" }, dispatchers)
  end,
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  root_dir = function(bufnr, on_dir)
    toolchain.activate_ts(bufnr, "tsgo", on_dir)
  end,
}
```

- [ ] **Step 4: `after/lsp/vtsls.lua` に `root_dir` を追加する**

`.config/nvim/after/lsp/vtsls.lua` の先頭とテーブル先頭を次のように変える (`settings` 以下は変更しない):

```lua
---@type vim.lsp.Config
return {
  root_dir = function(bufnr, on_dir)
    require("toolchain").activate_ts(bufnr, "vtsls", on_dir)
  end,
  filetypes = {
```

- [ ] **Step 5: `after/lsp/denols.lua` に `root_dir` を追加する**

`.config/nvim/after/lsp/denols.lua` の `single_file_support = true,` の行を次で置き換える。`single_file_support` は Neovim 0.11 以降では参照されないフィールドで、`root_dir` が常に root を返すようになるため削除する:

```lua
  root_dir = function(bufnr, on_dir)
    require("toolchain").activate_ts(bufnr, "denols", on_dir)
  end,
```

- [ ] **Step 6: `lsp.lua` を更新する**

`.config/nvim/lua/lsp.lua` を全置き換え:

```lua
vim.lsp.enable({
  "astro",
  "biome",
  "cssls",
  "denols",
  "gopls",
  "html",
  "intelephense",
  "jsonls",
  "lua_ls",
  "pug",
  "remark_ls",
  "rust-analyzer",
  "stylelint",
  "tailwindcss",
  "tsgo",
  "twiggy_language_server",
  "typos_lsp",
  "vtsls",
})

vim.api.nvim_create_user_command("TSLspSelect", function()
  require("toolchain").reselect_ts(0)
end, { desc = "TypeScript の LSP を選び直す" })
```

- [ ] **Step 7: `autocmds.lua` から TypeScript LS 起動 autocmd を削除する**

`.config/nvim/lua/autocmds.lua` の 216 行目のコメント `-- TypeScriptのLS起動設定` から 253 行目の `})` までを削除する。削除対象は `aucmd("FileType", { pattern = { "javascript", ... }, callback = ... })` のブロック全体で、`vim.lsp.enable("vtsls")` / `vim.lsp.enable("denols")` とコメントアウトされた `vim.ui.select` を含む。直後の `aucmd("QuickfixCmdPost", ...)` は残す。

- [ ] **Step 8: `mason.lua` に `tsgo` を追加する**

`.config/nvim/lua/plugins/mason.lua` の `"vtsls",` の次の行に追加:

```lua
          "tsgo",
```

- [ ] **Step 9: テストを実行して成功を確認する**

Run: `cd /home/edie/git/dotfiles && nvim -u NONE -l .config/nvim/tests/lsp_spec.lua`
Expected: `14/14 passed` と表示され終了コード 0

- [ ] **Step 10: 既存のテストが壊れていないことを確認する**

Run: `cd /home/edie/git/dotfiles && nvim -u NONE -l .config/nvim/tests/toolchain_spec.lua`
Expected: `54/54 passed` と表示され終了コード 0

- [ ] **Step 11: commit**

```bash
cd /home/edie/git/dotfiles
git add .config/nvim/after/lsp/tsgo.lua .config/nvim/after/lsp/vtsls.lua .config/nvim/after/lsp/denols.lua \
        .config/nvim/lua/lsp.lua .config/nvim/lua/autocmds.lua .config/nvim/lua/plugins/mason.lua \
        .config/nvim/tests/lsp_spec.lua
git commit -m "feat(nvim): TypeScript LSP を root_dir で buffer 単位に起動判定"
```

---

### Task 7: formatter の配線

**Files:**
- Modify: `.config/nvim/lua/plugins/conform.lua`
- Modify: `.config/nvim/lua/plugins/mason.lua`
- Create: `.config/nvim/tests/conform_spec.lua`

**Interfaces:**
- Consumes: `toolchain.formatters` (Task 5)
- Produces: `require("plugins.conform").opts.formatters_by_ft` の JS/TS/css/json エントリが `fun(bufnr): string[]` になる

- [ ] **Step 1: 失敗するテストを書く**

`.config/nvim/tests/conform_spec.lua`:

```lua
package.path = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)) .. "/?.lua;" .. package.path
local h = require("helper")
local by_ft = require("plugins.conform").opts.formatters_by_ft

do
  local root = h.fixture({ files = { ["biome.json"] = "{}", ["package.json"] = "{}", ["a.ts"] = "" } })
  local bufnr = h.buf(root .. "/a.ts")
  vim.bo[bufnr].filetype = "typescript"
  h.eq("function", type(by_ft.typescript), "typescript は関数で選択する")
  h.eq({ "biome" }, by_ft.typescript(bufnr), "biome プロジェクトは biome")
end

do
  local root = h.fixture({ files = { ["deno.json"] = "{}", ["a.tsx"] = "" } })
  local bufnr = h.buf(root .. "/a.tsx")
  vim.bo[bufnr].filetype = "typescriptreact"
  h.eq({ "deno_fmt" }, by_ft.typescriptreact(bufnr), "deno プロジェクトは deno_fmt")
end

do
  local root = h.fixture({
    files = { ["package.json"] = "{}", ["a.css"] = "" },
    exe = { "node_modules/.bin/prettier" },
  })
  local bufnr = h.buf(root .. "/a.css")
  vim.bo[bufnr].filetype = "css"
  h.eq({ "prettier" }, by_ft.css(bufnr), "css も同じ選択ロジックを通る")
end

do
  h.eq({ "stylua" }, by_ft.lua, "lua は stylua 固定")
  h.eq({ "prettier" }, by_ft.markdown, "markdown は prettier 固定")
end

h.finish()
```

- [ ] **Step 2: テストを実行して失敗を確認する**

Run: `cd /home/edie/git/dotfiles && nvim -u NONE -l .config/nvim/tests/conform_spec.lua`
Expected: `biome プロジェクトは biome` の FAIL (現在の実装は `prettier` を返す) を含み、終了コード 1

- [ ] **Step 3: `conform.lua` を全置き換えする**

`.config/nvim/lua/plugins/conform.lua`:

```lua
--- Formatting configuration with conform.nvim
--- コマンド解決 (node_modules/.bin 優先) は conform builtin に任せる
local function select_formatter(bufnr)
  return require("toolchain").formatters(bufnr)
end

---@type LazySpec
local spec = {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      javascript = select_formatter,
      javascriptreact = select_formatter,
      typescript = select_formatter,
      typescriptreact = select_formatter,
      css = select_formatter,
      json = select_formatter,
      html = { "prettier" },
      markdown = { "prettier" },
      astro = { "prettier" },
      lua = { "stylua" },
    },
    default_format_opts = {
      lsp_format = "fallback",
    },
  },
}

return spec
```

- [ ] **Step 4: `mason.lua` に `oxfmt` を追加する**

`.config/nvim/lua/plugins/mason.lua` の `"oxlint",` の次の行に追加:

```lua
          "oxfmt",
```

- [ ] **Step 5: テストを実行して成功を確認する**

Run: `cd /home/edie/git/dotfiles && nvim -u NONE -l .config/nvim/tests/conform_spec.lua`
Expected: `6/6 passed` と表示され終了コード 0

- [ ] **Step 6: commit**

```bash
cd /home/edie/git/dotfiles
git add .config/nvim/lua/plugins/conform.lua .config/nvim/lua/plugins/mason.lua .config/nvim/tests/conform_spec.lua
git commit -m "feat(nvim): formatter 選択を toolchain モジュールに統合し oxfmt を追加"
```

---

### Task 8: linter の配線

**Files:**
- Modify: `.config/nvim/lua/plugins/nvim-lint.lua`

**Interfaces:**
- Consumes: `toolchain.linters` / `toolchain.bin` / `toolchain.project_root` (Task 2, 3, 5)
- Produces: nvim-lint の autocmd が buffer ごとに `toolchain.linters` の結果だけを実行し、`try_lint` の `opts.cwd` と `opts.wrap_linter` で cwd とコマンドを buffer 位置から解決する

- [ ] **Step 1: プラグインを同期して nvim-lint を入れる**

Run: `cd /home/edie/git/dotfiles && nvim --headless "+Lazy! sync" +qa 2>&1 | tail -5`
Expected: エラーなく終了し、`ls ~/.local/share/nvim/lazy/nvim-lint` が存在する

- [ ] **Step 2: 失敗する統合テストを書く**

`.config/nvim/tests/lint_spec.lua`:

```lua
package.path = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)) .. "/?.lua;" .. package.path
local h = require("helper")

vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/lazy/nvim-lint")

local lint = require("lint")
local spec = require("plugins.nvim-lint")

-- try_lint を差し替えて、呼び出し回数と引数だけを観測する
local calls, last = 0, nil
lint.try_lint = function(names, opts)
  calls = calls + 1
  last = { names = names, opts = opts }
end

spec.config()

---@param bufnr integer
---@param ft string
---@return { calls: integer, names?: string[], opts?: table }
local function run(bufnr, ft)
  calls, last = 0, nil
  vim.bo[bufnr].filetype = ft
  vim.api.nvim_set_current_buf(bufnr)
  vim.api.nvim_exec_autocmds("BufWritePost", { buffer = bufnr })
  return { calls = calls, names = last and last.names, opts = last and last.opts }
end

do
  local root = h.fixture({
    files = { ["package.json"] = [[{"devDependencies":{"oxlint":"^1.0.0","eslint":"^9.0.0"}}]], ["a.ts"] = "" },
    exe = { "node_modules/.bin/oxlint", "node_modules/.bin/eslint" },
  })
  local result = run(h.buf(root .. "/a.ts"), "typescript")
  h.eq({ "oxlint", "eslint" }, result.names, "oxlint と eslint を両方実行する")
  h.eq(root, result.opts.cwd, "project root を cwd にする")
  h.eq(
    root .. "/node_modules/.bin/eslint",
    result.opts.wrap_linter({ name = "eslint", cmd = "eslint" }).cmd,
    "eslint は local install を使う"
  )
  h.eq(
    root .. "/node_modules/.bin/oxlint",
    result.opts.wrap_linter({ name = "oxlint", cmd = "oxlint" }).cmd,
    "oxlint は local install を使う"
  )
end

do
  local root = h.fixture({ files = { ["deno.json"] = "{}", ["a.ts"] = "" } })
  h.eq({ calls = 0 }, run(h.buf(root .. "/a.ts"), "typescript"), "deno プロジェクトでは try_lint を呼ばない")
end

do
  local root = h.fixture({ files = { ["biome.json"] = "{}", ["package.json"] = "{}", ["a.ts"] = "" } })
  h.eq({ calls = 0 }, run(h.buf(root .. "/a.ts"), "typescript"), "biome プロジェクトでは try_lint を呼ばない")
end

do
  local root = h.fixture({ files = { ["package.json"] = "{}", ["a.ts"] = "" } })
  h.eq({ calls = 0 }, run(h.buf(root .. "/a.ts"), "typescript"), "検出ゼロなら try_lint を呼ばない")
end

do
  local root = h.fixture({ files = { ["a.html"] = "" } })
  h.eq({ calls = 1 }, run(h.buf(root .. "/a.html"), "html"), "JS/TS 以外は引数なしで try_lint を呼ぶ")
  h.eq({ "markuplint" }, lint.linters_by_ft.html, "html は markuplint")
end

h.finish()
```

- [ ] **Step 3: テストを実行して失敗を確認する**

Run: `cd /home/edie/git/dotfiles && nvim -u NONE -l .config/nvim/tests/lint_spec.lua`
Expected: `project root を cwd にする` の FAIL (現在の実装は `opts` を渡さないため `attempt to index a nil value` を含む出力) となり、終了コード 1

- [ ] **Step 4: `nvim-lint.lua` を全置き換えする**

`try_lint` の `opts.wrap_linter` は cmd / args の評価前に呼ばれ、`vim.deepcopy` された linter を受け取る。`lint.linters[name]` を直接書き換えると `require` のキャッシュ経由で全プロジェクトに漏れるので、必ず `wrap_linter` 側で解決する。

`.config/nvim/lua/plugins/nvim-lint.lua`:

```lua
--- Linting configuration with nvim-lint
local JS_FILETYPES = {
  javascript = true,
  javascriptreact = true,
  typescript = true,
  typescriptreact = true,
}

---@type LazySpec
local spec = {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")
    local toolchain = require("toolchain")

    lint.linters_by_ft = {
      astro = { "markuplint" },
      html = { "markuplint" },
    }

    local function lint_buffer()
      local bufnr = vim.api.nvim_get_current_buf()
      if not JS_FILETYPES[vim.bo[bufnr].filetype] then
        lint.try_lint()
        return
      end

      local linters = toolchain.linters(bufnr)
      if #linters == 0 then
        return
      end

      lint.try_lint(linters, {
        cwd = toolchain.project_root(bufnr),
        -- nvim-lint 標準の cmd 解決は nvim の cwd 基準なので buffer 位置から解決し直す
        wrap_linter = function(linter)
          linter.cmd = toolchain.bin(bufnr, linter.name) or linter.cmd
          return linter
        end,
      })
    end

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = vim.api.nvim_create_augroup("lint", { clear = true }),
      callback = lint_buffer,
    })
  end,
}

return spec
```

- [ ] **Step 5: テストを実行して成功を確認する**

Run: `cd /home/edie/git/dotfiles && nvim -u NONE -l .config/nvim/tests/lint_spec.lua`
Expected: `9/9 passed` と表示され終了コード 0

- [ ] **Step 6: commit**

```bash
cd /home/edie/git/dotfiles
git add .config/nvim/lua/plugins/nvim-lint.lua .config/nvim/tests/lint_spec.lua
git commit -m "feat(nvim): linter 選択を toolchain モジュールに統合し local install を優先"
```

---

### Task 9: 実機での確認

**Files:**
- Create: `/tmp/toolchain-check/` 配下の fixture (コミットしない)

**Interfaces:**
- Consumes: Task 1-8 のすべて
- Produces: なし (確認のみ)

- [ ] **Step 1: 全テストを通す**

Run:
```bash
cd /home/edie/git/dotfiles
for f in .config/nvim/tests/*_spec.lua; do echo "== $f"; nvim -u NONE -l "$f" || echo "FAILED: $f"; done
```
Expected: 4 つの spec すべてが `N/N passed` で、`FAILED:` が出ない

- [ ] **Step 2: プラグインとツールを同期する**

Run: `cd /home/edie/git/dotfiles && nvim --headless "+Lazy! sync" +qa 2>&1 | tail -5`
Expected: エラーなく終了する

Run: `ls ~/.local/share/nvim/mason/bin/ | grep -E "biome|eslint_d|oxlint|oxfmt|tsgo"`
Expected: `biome` / `eslint_d` / `oxlint` / `oxfmt` / `tsgo` が並ぶ (mason-tool-installer の初回起動時インストールが終わっていない場合は素の `nvim` を一度起動して待つ)

- [ ] **Step 3: fixture を作る**

Run:
```bash
mkdir -p /tmp/toolchain-check
cd /tmp/toolchain-check
mkdir -p deno biome oxlint-eslint prettier-only ts7 bare
echo '{}' > deno/deno.json && echo 'const a=1' > deno/mod.ts
echo '{}' > biome/biome.json && echo '{}' > biome/package.json && echo 'const a=1' > biome/a.ts
echo '{"devDependencies":{"oxlint":"^1.76.0","eslint":"^9.0.0"}}' > oxlint-eslint/package.json
echo 'const a=1' > oxlint-eslint/a.ts
echo '{"devDependencies":{"prettier":"^3.0.0"}}' > prettier-only/package.json
echo 'const a=1' > prettier-only/a.ts
echo '{"devDependencies":{"typescript":"^7.0.2"}}' > ts7/package.json
echo 'const a=1' > ts7/a.ts
echo 'const a=1' > bare/a.ts
for d in oxlint-eslint prettier-only ts7; do (cd $d && npm install --no-audit --no-fund >/dev/null 2>&1); done
```
Expected: エラーなく終了し、`ls /tmp/toolchain-check/ts7/node_modules/.bin/tsc` が存在する

- [ ] **Step 4: 判定結果を確認する**

Run:
```bash
cd /home/edie/git/dotfiles && cat > /tmp/toolchain-check/probe.lua <<'EOF'
local toolchain = require("toolchain")
for _, dir in ipairs({ "deno", "biome", "oxlint-eslint", "prettier-only", "ts7" }) do
  local path = "/tmp/toolchain-check/" .. dir
  local file = path .. (dir == "deno" and "/mod.ts" or "/a.ts")
  local bufnr = vim.fn.bufadd(file)
  vim.fn.bufload(bufnr)
  print(("%-14s lsp=%-8s linters=%-22s formatters=%s"):format(
    dir,
    tostring(toolchain.ts_server(bufnr)),
    table.concat(toolchain.linters(bufnr), ","),
    table.concat(toolchain.formatters(bufnr, "typescript"), ",")
  ))
end
EOF
nvim --headless -c "luafile /tmp/toolchain-check/probe.lua" -c "qa" 2>&1
```
Expected:
```
deno           lsp=denols   linters=                       formatters=deno_fmt
biome          lsp=vtsls    linters=                       formatters=biome
oxlint-eslint  lsp=vtsls    linters=oxlint,eslint          formatters=prettier
prettier-only  lsp=vtsls    linters=                       formatters=prettier
ts7            lsp=tsgo     linters=                       formatters=prettier
```

- [ ] **Step 5: セッションを跨いだ LSP の attach を確認する**

既存実装ではここが壊れていた (Node プロジェクトを開いた後に Deno プロジェクトを開くと両方の LS が起動する) ため、回帰確認として必ず実施する。

Run:
```bash
cd /home/edie/git/dotfiles && cat > /tmp/toolchain-check/attach.lua <<'EOF'
local function names()
  local result = {}
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    table.insert(result, client.name)
  end
  table.sort(result)
  return table.concat(result, ",")
end
vim.cmd("edit /tmp/toolchain-check/oxlint-eslint/a.ts")
vim.cmd("sleep 3")
vim.cmd("edit /tmp/toolchain-check/deno/mod.ts")
vim.cmd("sleep 3")
print("deno buffer: " .. names())
vim.cmd("edit /tmp/toolchain-check/oxlint-eslint/a.ts")
vim.cmd("sleep 2")
print("node buffer: " .. names())
EOF
nvim --headless -c "luafile /tmp/toolchain-check/attach.lua" -c "qa!" 2>&1
```
Expected: `deno buffer:` に `denols` が含まれ `vtsls` / `tsgo` が含まれない。`node buffer:` に `vtsls` が含まれ `denols` が含まれない

- [ ] **Step 6: プロジェクト外ファイルの選択が配線されていることを確認する**

`vim.ui.select` を差し替えて、実際の起動経路でプロンプトが 1 回だけ出ることを確認する。

Run:
```bash
cd /home/edie/git/dotfiles && cat > /tmp/toolchain-check/select.lua <<'EOF'
local prompts = 0
vim.ui.select = function(items, _, on_choice)
  prompts = prompts + 1
  print("prompt " .. prompts .. ": " .. table.concat(items, "/"))
  on_choice("tsgo")
end
vim.cmd("edit /tmp/toolchain-check/bare/a.ts")
vim.cmd("sleep 3")
local names = {}
for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
  table.insert(names, client.name)
end
print("clients: " .. table.concat(names, ","))
vim.cmd("edit /tmp/toolchain-check/bare/b.ts")
vim.cmd("sleep 1")
print("total prompts: " .. prompts)
EOF
nvim --headless -c "luafile /tmp/toolchain-check/select.lua" -c "qa!" 2>&1
```
Expected: `prompt 1: tsgo/denols/no launch` が 1 行だけ出て、`clients: tsgo`、`total prompts: 1` が出る

- [ ] **Step 7: 対話 UI をユーザーに確認してもらう**

`vim.ui.select` の実 UI と `:TSLspSelect` は TTY が必要なので、ユーザーに次を依頼する。

```
nvim /tmp/toolchain-check/bare/a.ts
```

確認内容:
1. `select LSP for TypeScript:` のプロンプトが 1 回だけ出る
2. `tsgo` を選ぶと `:lua =vim.lsp.get_clients({ bufnr = 0 })` で tsgo だけが attach している
3. `:edit /tmp/toolchain-check/bare/b.ts` を開いても再度尋ねられない
4. `:TSLspSelect` で再びプロンプトが出て、`denols` を選ぶと denols に切り替わる
5. `no launch` を選ぶとどちらも attach しない

- [ ] **Step 8: 保存時フォーマットを確認する**

Run:
```bash
cd /home/edie/git/dotfiles && printf 'const  a   =  1\n' > /tmp/toolchain-check/prettier-only/a.ts \
  && nvim --headless -c "edit /tmp/toolchain-check/prettier-only/a.ts" -c "sleep 2" -c "write" -c "qa!" 2>&1 \
  && cat /tmp/toolchain-check/prettier-only/a.ts
```
Expected: `const a = 1;` に整形されている

- [ ] **Step 9: fixture を片付ける**

Run: `rm -rf /tmp/toolchain-check`
Expected: エラーなく終了する

- [ ] **Step 10: 設計ドキュメントに実機確認の結果を追記して commit**

`docs/superpowers/specs/2026-07-29-js-ts-toolchain-autodetect-design.md` の「検証」節の末尾に、Step 4 の実際の出力と Step 5, 6, 8 の結果、および Step 7 でユーザーが確認した内容を追記する。

```bash
cd /home/edie/git/dotfiles
git add docs/superpowers/specs/2026-07-29-js-ts-toolchain-autodetect-design.md
git commit -m "docs: JS/TS ツールチェーン自動判定の実機確認結果を追記"
```

---

## 実装上の注意

- `vim.lsp.config[name]` は rtp 上の `lsp/<name>.lua` を `vim.tbl_deep_extend("force", ...)` で順に重ねる。後に見つかったファイルが勝つため、`after/lsp/` の設定が nvim-lspconfig の `lsp/` を上書きする。テストではこの順序を作るために `helper.lua` が rtp を組み立てている
- `vim.lsp.enable` の起動判定は `FileType` autocmd (augroup `nvim.lsp.enable`) が駆動する。`reselect_ts` の `doautocmd nvim.lsp.enable FileType` はこれを再発火させている
- `cmd` がテーブルの場合、`vim.lsp.enable` は `vim.fn.executable(cmd[1])` を検証して失敗時はそのサーバーを起動しない (ユーザーにエラーは出ない)。`tsgo` は関数形式なのでこの検証を通る
- `after/lsp/tsgo.lua` の `cmd` は `config.root_dir` からバイナリを探すので、monorepo でパッケージ配下だけに `node_modules/.bin/tsc` がある構成では root 側までしか遡らない。これは nvim-lspconfig 本体の `lsp/tsgo.lua` と同じ挙動
- `lint.linters[name]` は `require("lint.linters." .. name)` の戻り値をそのまま返す。Lua の `require` はモジュールをキャッシュするので、ここに代入すると全プロジェクトに漏れる。`try_lint` の `opts.wrap_linter` は `vim.deepcopy` された linter を受け取るため、buffer ごとの上書きはこちらで行う
- テスト内で `vim.ui.select` を差し替えると以降のブロックにも残る。選択を伴うテストは各ブロックの冒頭で必ず差し替え直す
