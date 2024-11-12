local options = {
  encoding = "utf-8", -- 内部文字コード
  fileencoding = "utf-8", -- ファイル書き込み時の文字コード
  list = true, -- 不可視文字を表示
  scrolloff = 4, -- 画面の端までスクロールしても指定した行数分の視界を確保する
  ignorecase = true, -- 大文字小文字を無視して検索
  smartcase = true, -- 大文字を含んだ文字列で検索した場合のみ大文字小文字を区別して検索
  inccommand = "split", -- 文字列置換をインタラクティブに表示する
  completeopt = { "menuone", "noinsert" }, -- menuoneで、対象が1件しかなくても常に補完ウィンドウを表示していて、noinsertで補完ウィンドウを表示時に挿入しない
  -- ambiwidth = "double", -- 全角文字を2文字分の幅で表示する
  cursorline = true, -- 現在行をハイライト
  cursorcolumn = true, -- 現在列をハイライト
  softtabstop = -1, -- マイナスにすることでshiftwidthに従う
  shiftwidth = 0, -- 0にするとtabstopに従う
  tabstop = 2, -- インデントの見た目の大きさ
  number = true, -- 行数表示
  expandtab = true, -- trueにするとタブではなくスペースが入力される
  numberwidth = 4, -- 行数表示の桁数
  incsearch = true, -- インクリメンタルサーチ
  shell = "zsh", -- デフォルトシェル
  relativenumber = true, -- 現在行からの相対的な行数を表示
  splitright = true, -- 新しいウィンドウを右に開く
  splitbelow = true, -- 新しいウィンドウを下に開く
  termguicolors = true, -- true colorを使う設定
  syntax = "enable", -- 構文ハイライト
  winblend = 0, -- floating windowsの背景透過度
  pumblend = 0, -- ポップアップメニューの背景透過度
  clipboard = "unnamedplus", -- クリップボードを共有
  signcolumn = "yes:2", -- 記号を常に2文字分の幅で表示
  title = true, -- 現在開いているファイル名などをタイトルに反映
  hlsearch = true, -- 検索ハイライト
  showcmd = true, -- 入力中のコマンドを表示
  helplang = { "ja", "en" }, -- ドキュメントの言語の優先度を設定
  hidden = true, -- バッファ切替時に保存していない時のアラートを非表示
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

vim.cmd("set whichwrap+=<,>,[,],h,l")
