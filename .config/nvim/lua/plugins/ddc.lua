return {
  "Shougo/ddc.vim",
  lazy = true,
  -- event = "VimEnter",
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
      autoCompleteEvents = {
        "InsertEnter",
        "TextChangedI",
        "CmdlineEnter",
        "CmdlineChanged",
      },
      backspaceCompletion = true,
      sources = {
        "lsp",
        "around",
        "file",
      },
      sourceOptions = {
        _ = {
          minAutoCompleteLength = 1,
          keywordPattern = [[(?:-?\d+(?:\.\d+)?|[a-zA-Z_]\w*(?:-\w*)*)]],
          matchers = { "matcher_fuzzy" },
          sorters = { "sorter_fuzzy" },
          converters = { "converter_fuzzy" },
          ignoreCase = true,
          timeout = 500,
        },
        lsp = {
          mark = "[LSP]",
          matchers = { "matcher_head" },
          sorters = { "sorter_lsp-kind" },
          forceCompletionPattern = [['\.\w*|:\w*|->\w*']],
          dup = "keep",
        },
        around = { mark = "A" },
        file = {
          mark = "F",
          isVolatile = true,
        },
      },
      sourceParams = {
        lsp = {
          enableResolveItem = true,
          enableAdditionalTextEdit = true,
          confirmBehavior = "replace",
          kindLabels = {
            class = "c",
          },
        },
      },
    })

    vimx.fn.ddc.enable()

    -- keymap
  end,
}
