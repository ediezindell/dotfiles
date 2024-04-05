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
    local vimx = require("artemis")

    vimx.fn.ddc.custom.patch_global({
      ui = "native",
      sources = {
        "lsp",
        "around",
        "file",
      },
      sourceOptions = {
        _ = {
          matchers = { "matcher_fuzzy" },
          sorters = { "sorter_fuzzy" },
          converters = { "converter_fuzzy" },
        },
        lsp = {
          mark = "[LSP]",
          dup = "keep",
          keywordPattern = { [["\k+"]] },
          sorters = { "sorter_lsp-kind" },
        },
        around = { mark = "A" },
        file = {
          mark = "F",
          isVolatile = true,
        },
      },
      sourceParams = {
        lsp = {
          snippetEngine = vim.fn["denops#callback#register"](function(body)
            vim.fn["vsnip#anonymous"](body)
          end),
          enableResolveItem = true,
          enableAdditionalTextEdit = true,
          confirmBehavior = "insert",
        },
      },
    })

    vimx.fn.ddc.enable()

    -- keymap
  end,
}
