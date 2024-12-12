---@type LazySpec
local spec = {
  "Shougo/ddu.vim",
  lazy = false,
  dependencies = {
    "vim-denops/denops.vim",
    -- ui
    "Shougo/ddu-ui-ff",
    -- filter
    "Shougo/ddu-filter-matcher_substring",
    "Shougo/ddu-filter-matcher_files",
    "Shougo/ddu-filter-sorter_alpha",
    "uga-rosa/ddu-filter-converter_devicon",
    -- kind
    "Shougo/ddu-kind-file",
    -- source
    "Shougo/ddu-source-file_rec",
    "shun/ddu-source-rg",
    "uga-rosa/ddu-source-lsp",
  },
  init = function()
    local dduAuGroup = vim.api.nvim_create_augroup("DduAuGroup", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "ddu-ff",
      callback = function()
        local opts = { noremap = true, silent = true, buffer = true }
        vim.keymap.set({ "n" }, "q", [[<Cmd>call ddu#ui#do_action("quit")<CR>]], opts)
        vim.keymap.set({ "n" }, "<CR>", [[<Cmd>call ddu#ui#do_action("itemAction")<CR>]], opts)
        vim.keymap.set({ "n" }, "i", [[<Cmd>call ddu#ui#do_action("openFilterWindow")<CR>]], opts)
        vim.keymap.set({ "n" }, "P", [[<Cmd>call ddu#ui#do_action("togglePreview")<CR>]], opts)
      end,
      group = dduAuGroup
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "ddu-ff-filter",
      callback = function()
        local opts = { noremap = true, silent = true, buffer = true }
        vim.keymap.set({ "n", "i" }, "<CR>", [[<Esc><Cmd>close<CR>]], opts)
      end,
      group = dduAuGroup
    })
  end,
  keys = {
    { "<space>ff", '<Cmd>call ddu#start(#{name: "file_rec"})<CR>',                                                                                desc = "ddu file_rec" },
    { "<space>fg", '<Cmd>call ddu#start(#{name: "rg"})<CR>',                                                                                      desc = "ddu rg" },
    { "<space>fl", '<Cmd>call ddu#start(#{sync: v:true, sources: [#{name: "lsp_definition"}], uiParams: #{ff: #{immediateAction: "open"}}})<CR>', desc = "ddu lsp-def" }
  },
  config = function()
    vim.fn["ddu#custom#patch_global"]({
      ui = "ff",
      uiParams = {
        ff = {
          filterFloatingPosition = "bottom",
          filterSplitDirection = "floating",
          floatingBorder = "rounded",
          previewFloating = true,
          previewFloatingBorder = "rounded",
          previewSplit = "horizontal",
          prompt = "> ",
          split = "floating",
          startFilter = true,
        },
      },
      sources = {
        "file_rec",
        "rg",
      },
      sourceParams = {
        file_rec = { ignoredDirectories = { "node_modules", ".git", "dist", ".vscode" } },
        rg = { args = { "--ignore-case", "--column", "--no-heading", "--color", "never" } },
      },
      sourceOptions = {
        _ = {
          matchers = { "matcher_substring" },
          ignoreCase = true,
          sorters = "sorter_alpha",
        },
        file_rec = {
          converters = { "converter_devicon" },
        },
        rg = {
          matchers = { "matcher_substring", "matcher_files" },
        },
      },
      kindOptions = {
        file = { defaultAction = "open" },
        lsp = { defaultAction = "open" },
        lsp_codeAction = { defaultAction = "apply" },
      },
      filterParams = {
        matcher_substring = { highlightMatched = "Search" },
      },
    })
  end,
}

return spec
