return {
  "iamcco/markdown-preview.nvim",
  -- cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = "cd app && yarn install",
  init = function()
    -- ファイルタイプを指定
    vim.g.mkdp_filetypes = {
      "markdown",
    }
  end,
  ft = { "markdown" }, -- markdownファイルを開いた場合のみ読み込み
}
