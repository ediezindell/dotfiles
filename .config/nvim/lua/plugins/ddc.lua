return {
  "Shougo/ddc.vim",
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
    "Shougo/ddc-source-lsp",
    "LumaKernel/ddc-source-file",
    ------------------------------
    -- | ui                      |
    ------------------------------
    "Shougo/ddc-ui-native", -- nvim本体の補完機能を利用
  },
  config = function()
    vim.fn["ddc#custom#patch_global"]({
      ui = "native",
      sources = {
        "lsp",
        "around",
        "file",
      },
      sourceOptions = {
        lsp = {
          mark = "lsp",
          forceCompletionPattern = "\\.\\w*|::\\w*|->\\w*",
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
      },
      sourceParams = {
        lsp = {
          snippetEngine = vim.fn["denops#callback#register"]({
            function(body)
              return vim.fn["vsnip#anonymous"](body)
            end,
          }),
          enableResolveItem = true,
          enableAdditionalTextEdit = true,
        },
      },
    })
    vim.fn["ddc#enable"]()
  end,
}
