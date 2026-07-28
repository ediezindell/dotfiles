# JS/TS ツールチェーン自動判定 設計

対象: `.config/nvim` の LSP / linter / formatter 選択ロジック
関連 PR: #6 (`Replace none-ls with conform.nvim and nvim-lint`)

## 背景

PR #6 で none-ls を conform.nvim + nvim-lint に置き換え、deno / biome / eslint / oxlint の切り替えを導入した。しかし以下が未達または不正確な状態で残っている。

### 未対応

- built-in TypeScript LS (TypeScript 7 系) の選択肢がない。LSP は vtsls / denols の 2 択のみ
- formatter に oxfmt がない

### 既存実装の不具合

- `nvim-lint.lua` の再読み込み条件 `not has_deno and (not has_biome or not has_oxlint)` は、片方だけ検出済みでも package.json を読み直す。意図した「両方未検出なら読む」になっていない
- package.json の依存判定が `content:match('"biome"')` の正規表現。`scripts` 内の文字列などにマッチして誤検出する
- eslint が無条件実行のため、eslint 未導入プロジェクトで保存ごとに実行エラーが出る
- 検出ロジックが `conform.lua` / `nvim-lint.lua` / `autocmds.lua` の 3 箇所に重複している
- LSP を FileType autocmd 内で `vim.lsp.enable()` する方式のため、1 セッションで Node プロジェクトと Deno プロジェクトを跨ぐと両方の LS が以降すべてのバッファで起動する
- nvim-lint 標準の `eslint` / `oxlint` は `./node_modules/.bin/` を **nvim の cwd 基準** で探す。cwd がプロジェクト外だと local install を取り逃がす

## 前提となる調査結果

実機・npm registry・各プラグインのソースで確認した事実。

### TypeScript 7

- `typescript` の `latest` は 7.0.2。bin は `tsc` のみ (`{ tsc: 'bin/tsc' }`)
- `tsc --lsp --stdio` が JSON-RPC で応答することを実測で確認 (`initialize` に対し LSP 準拠のレスポンスを返す)
- `@typescript/native-preview` は 7.0.0-dev 系で bin は `tsgo`
- したがって built-in TS LS の起動コマンドは `tsc` と `tsgo` の 2 系統。`tsc` は版によって `--lsp` を持たないため、**版が特定できないグローバル `tsc` は使えない**

### 各プラグインの既存実装

- nvim-lspconfig は `lsp/tsgo.lua` を持ち、local install 優先と deno 除外を実装済み。ただし解決先は `root_dir .. '/node_modules/.bin/tsgo'` のみで、monorepo のパッケージ単位 `node_modules` は見ない
- conform.nvim は `prettier` / `biome` / `oxfmt` / `deno_fmt` の builtin を持ち、`util.from_node_modules` により **local install 優先が既定**
- nvim-lint は `stdin = false` かつ `append_fname ~= false` のとき対象ファイル名を引数末尾に付与する。よって oxlint は cwd 全体ではなく単一ファイルを lint する

### ツールの入手性

- `oxfmt` 0.61.0 / `oxlint` 1.76.0 はいずれも `--lsp` を持つ
- mason registry に `oxfmt` / `oxlint` / `tsgo` / `vtsls` / `eslint_d` / `eslint-lsp` が存在する (`typescript-go` という名前では存在しない)

## 設計

### 1. 検出モジュール `lua/toolchain.lua` (新規)

判定ロジックを 1 モジュールに集約し、LSP / conform / nvim-lint がすべてこれを参照する。

公開 API:

| 関数 | 返り値 |
|---|---|
| `M.pkg(bufnr)` | buffer から上方向に探した package.json を `vim.json.decode` でパースした table。パスと mtime をキーにキャッシュする |
| `M.has_dep(bufnr, name)` | `dependencies` / `devDependencies` のキー完全一致で判定 |
| `M.dep_major(bufnr, name)` | バージョン指定子からメジャー版を数値で取り出す (`"^7.0.2"` → `7`) |
| `M.bin(bufnr, name)` | buffer のディレクトリから上方向に `node_modules/.bin/<name>` を探索し絶対パスを返す。無ければグローバルの実行可能ファイル名、それも無ければ `nil` |
| `M.ts_server(bufnr)` | `"denols"` / `"tsgo"` / `"vtsls"` / `nil` (同期。プロジェクト判定できないとき `nil`) |
| `M.activate_ts(bufnr, name, on_dir)` | `name` の LS をこの buffer で起動すべきなら `on_dir()` を呼ぶ。判定できない場合はユーザーに選択させる (非同期) |
| `M.linters(bufnr)` | 実行すべき linter 名のリスト |
| `M.formatters(bufnr)` | 実行すべき formatter 名のリスト |

判定ルール (いずれも buffer 位置からの上方向探索):

| 対象 | 条件 |
|---|---|
| deno | `deno.json` / `deno.jsonc` / `deno.lock` / `denops` |
| built-in TS LS | deps に `@typescript/native-preview`、または `typescript` の major が 7 以上 |
| vtsls | 上記以外で `tsconfig.json` / `jsconfig.json` / `package.json` のいずれかがある |

上表のどの条件にも当てはまらない場合 (プロジェクト外で単独の `.ts` ファイルを開いた場合など) は自動判定せず、ユーザーに選択させる。詳細は次節。
| biome | `biome.json` / `biome.jsonc` / `.biome.json` / `.biome.jsonc`、または deps の `@biomejs/biome` |
| eslint | `eslint.config.{js,mjs,cjs,ts,mts,cts}` / `.eslintrc*`、または deps の `eslint` |
| oxlint | `.oxlintrc.json` / `oxlint.json`、または deps の `oxlint` |
| oxfmt | `.oxfmtrc.json` / `.oxfmtrc.jsonc` / `oxfmt.config.ts`、または deps の `oxfmt` |
| prettier | 上記のどれも該当しないときの fallback。設定ファイルは見ず、`prettier` コマンドが解決できるかだけで判定する |

### 2. LSP — `root_dir` コールバックによる buffer 単位の起動判定

`lsp.lua` で `vtsls` / `denols` / `tsgo` をすべて `vim.lsp.enable()` し、起動可否は各 `after/lsp/*.lua` の `root_dir` コールバックで判定する。`root_dir` が `on_dir()` を呼ばなければその buffer では起動しない。

`autocmds.lua` の TypeScript LS 起動用 FileType autocmd は削除する。

3 つの `after/lsp/*.lua` はいずれも `root_dir = function(bufnr, on_dir) require("toolchain").activate_ts(bufnr, "<名前>", on_dir) end` の形にする。

- `after/lsp/vtsls.lua` — 判定結果が `vtsls` のときだけ起動
- `after/lsp/denols.lua` — 判定結果が `denols` のときだけ起動
- `after/lsp/tsgo.lua` (新規) — 判定結果が `tsgo` のときだけ起動。cmd の解決順は local `tsgo` → local `tsc` (`typescript` major が 7 以上のときのみ) → グローバル `tsgo`。グローバル `tsc` は版が特定できないため候補に入れない

#### プロジェクト外のファイルはユーザーに選択させる

`M.ts_server` が `nil` を返す場合 (プロジェクトの目印が何も見つからない場合)、`vim.ui.select` で `tsgo` / `denols` / `no launch` を提示し、選ばれたものだけを起動する。これは既存実装の `autocmds.lua` にコメントアウトで残っていた挙動を、選択肢を現行のサーバー構成 (vtsls ではなく tsgo) に合わせて復活させるもの。vtsls はこの選択肢には出さない。

`root_dir` コールバックは `on_dir` を非同期に呼んでよい (Neovim 0.12 の実装で、`on_dir` は `vim.schedule` 経由でクライアント起動につながる) ため、選択 UI の結果を待ってから起動できる。

denols と tsgo の両方が有効化されているので、1 つの buffer に対して `root_dir` が 2 回呼ばれる。プロンプトが二重に出ないよう、`toolchain.lua` 側で以下を管理する。

- 選択結果はファイルの所属ディレクトリをキーに記録する。同じディレクトリの別ファイルを開いたときは再度尋ねない
- `no launch` を選んだ場合も「起動しない」という決定として記録し、再度尋ねない
- 最初の `root_dir` 呼び出しが選択 UI を開き、決定前に来た 2 つ目の呼び出しは待ち行列に入れる。決定時に待ち行列をまとめて解決する

起動時に渡す root はファイルの所属ディレクトリとする。

判断をやり直せるように、ユーザーコマンド `:TSLspSelect` を追加する。現在の buffer の所属ディレクトリの記録を破棄し、該当クライアントを停止して選択し直す。

### 3. linter — nvim-lint

優先順位は deno > biome > (oxlint + eslint)。

- deno プロジェクト — denols が `init_options.lint = true` で診断を出すため nvim-lint は実行しない
- biome プロジェクト — biome LSP が診断を出すため nvim-lint は実行しない
- 上記以外 — 検出された oxlint と eslint を両方実行する。両方入っている構成 (oxlint で高速チェック + eslint で残りをカバー) をそのまま反映する
- 検出ゼロ — 何も実行しない

local install 優先のため、`lint.linters.<name>.cmd` を実行直前に `M.bin(bufnr, ...)` の結果で上書きする。これにより nvim の cwd に依存しなくなる。eslint は local install が無い場合、mason 管理の `eslint_d` にフォールバックする (linter 名を差し替える)。

### 4. formatter — conform.nvim

優先順位は `deno_fmt` → `biome` → `oxfmt` → `prettier`。

local install 優先は conform builtin の `util.from_node_modules` が既に満たしているため、コマンド解決は builtin に委ねる。

prettier がどこにも解決できない場合は空リストを返し、`default_format_opts.lsp_format = "fallback"` により LSP フォーマットに落とす。存在しないコマンドを指定して実行エラーを出すことを避ける。

プロジェクト外のファイルでは、LSP 選択で記録済みの決定を参照する。`denols` を選んでいれば `deno_fmt`、それ以外は上記の通常の優先順位に従う。conform 側は同期的に呼ばれるため、記録された決定を読むだけで、ここから選択 UI を開くことはしない。

対象 filetype は現状維持 (javascript / typescript / javascriptreact / typescriptreact / css / json / html / markdown / astro / lua)。`css` と `json` も同じ選択ロジックを通す。

### 5. mason

`ensure_installed` に `oxfmt` と `tsgo` を追加する。`oxlint` / `eslint_d` / `prettier` は既存のまま。

## 検証

`/tmp` 配下に以下 5 パターンの最小プロジェクトを作り、`vim.lsp.get_clients()` と `:ConformInfo`、`require("lint").get_running()` で期待どおりのツールが選ばれることを確認する。

| パターン | 期待する LSP | 期待する linter | 期待する formatter |
|---|---|---|---|
| deno (`deno.json`) | denols | なし | deno_fmt |
| biome (`biome.json`) | vtsls + biome | なし | biome |
| oxlint + eslint (両方 devDeps) | vtsls | oxlint + eslint | prettier |
| prettier のみ | vtsls | なし | prettier |
| typescript 7 + prettier (devDeps) | tsgo | なし | prettier |
| プロジェクト外の単独 `.ts` ファイル | 選択 UI で選んだもののみ | なし | `denols` を選べば deno_fmt、他は prettier |

プロジェクト外のファイルについては加えて次を確認する。

- 選択 UI が 1 回だけ表示される (denols / tsgo で二重に出ない)
- `tsgo` を選ぶと tsgo のみ、`denols` を選ぶと denols のみが attach する
- `no launch` を選ぶとどちらも attach しない
- 同じディレクトリの 2 つ目のファイルを開いても再度尋ねられない
- `:TSLspSelect` で選び直せる

加えて、1 セッション内で deno プロジェクトと Node プロジェクトのファイルを順に開き、それぞれのバッファに意図した LS のみが attach していることを確認する (既存実装のグローバル有効化不具合の回帰確認)。

## 影響範囲

| ファイル | 変更 |
|---|---|
| `.config/nvim/lua/toolchain.lua` | 新規 |
| `.config/nvim/after/lsp/tsgo.lua` | 新規 |
| `.config/nvim/after/lsp/vtsls.lua` | `root_dir` 追加 |
| `.config/nvim/after/lsp/denols.lua` | `root_dir` 追加 |
| `.config/nvim/lua/lsp.lua` | `vtsls` / `denols` / `tsgo` を有効化 |
| `.config/nvim/lua/autocmds.lua` | TypeScript LS 起動用 FileType autocmd を削除 |
| `.config/nvim/lua/plugins/conform.lua` | 検出モジュール参照に置き換え、oxfmt 追加 |
| `.config/nvim/lua/plugins/nvim-lint.lua` | 検出モジュール参照に置き換え、local bin 解決を追加 |
| `.config/nvim/lua/plugins/mason.lua` | `oxfmt` / `tsgo` を追加 |

## 却下した選択肢

| 選択肢 | 却下理由 |
|---|---|
| 既存実装 (FileType autocmd + 各所に検出ロジック) を延長して tsgo / oxfmt 分岐だけ追加 | 検出ロジックの 3 重複と LSP のグローバル有効化不具合が残る |
| プロジェクトごとに `.nvim.lua` (exrc) で使うツールを手動指定 | 自動判定という要件を満たさない |
| oxlint を `oxlint --lsp` で LSP として使う | nvim-lint と LSP の 2 機構が混在する。oxlint と eslint を並走させる構成では nvim-lint に統一した方が設定が 1 箇所で済む |
| biome / deno でも nvim-lint を実行する | biome LSP / denols が同じ診断を出すため二重表示になる |
| プロジェクト外のファイルでは何も起動しない、または tsgo を無条件で起動する | 単独ファイルが deno スクリプトである場合を判定する材料がない。既存実装が選択 UI を用意していた意図に沿ってユーザーに選ばせる |
