return {
  "Shougo/ddc.vim",
  -- event = "VimEnter",
  lazy = false,
  dependencies = {
    "vim-denops/denops.vim",
    "tani/ddc-fuzzy",
    ------------------------------
    -- | filter                  |
    ------------------------------
    "Shougo/ddc-filter-matcher_head",
    ------------------------------
    -- | rank                    |
    ------------------------------
    "Shougo/ddc-filter-sorter_rank",
    ------------------------------
    -- | source                  |
    ------------------------------
    "Shougo/ddc-source-around",
    "Shougo/ddc-source-nvim-lsp",
    "LumaKernel/ddc-source-file",
    ------------------------------
    -- | ui                      |
    ------------------------------
    "Shougo/ddc-ui-native", -- nvim本体の補完機能を利用
  },
  config = function()
    vim.fn["ddc#custom#patch_global"]("ui", "native")
    vim.fn["ddc#custom#patch_global"]("sources", {
      "nvim-lsp",
      "file",
      "around",
    })
    vim.fn["ddc#custom#patch_global"]("sourceOptions", {
      ["nvim-lsp"] = {
        mark = "lsp",
        forceCompletionPattern = "\\.\\w*|::\\w*|->\\w*",
        -- dup = "force",
      },
      file = {
        mark = "F",
        isVolatile = true,
        forceCompletionPattern = "\\S/\\S*",
      },
      around = { mark = "A" },
      _ = {
        matchers = { "matcher_fuzzy" },
        sorters = { "sorter_fuzzy" },
        converters = { "converter_fuzzy" },
      },
    })
    vim.fn["ddc#enable"]()
  end,
}
