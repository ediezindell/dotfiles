local dependencies = {
  "vim-denops/denops.vim",
  ------------------------------
  -- | filter                   |
  ------------------------------
  "Shougo/ddu-filter-matcher_substring",
  "Shougo/ddu-filter-matcher_files",
  "Shougo/ddu-filter-sorter_alpha",
  "uga-rosa/ddu-filter-converter_devicon",
  ------------------------------
  -- | kind                     |
  ------------------------------
  "Shougo/ddu-kind-file",
  ------------------------------
  -- | source                   |
  ------------------------------
  "Shougo/ddu-source-file_rec",
  "shun/ddu-source-rg",
  "uga-rosa/ddu-source-lsp",
  ------------------------------
  -- | ui                       |
  ------------------------------
  "Shougo/ddu-ui-ff",
}

local globalConfig = {
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
    "lsp",
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
}

local setAutocmd = function()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "ddu-ff",
    callback = function()
      local opts = { noremap = true, silent = true, buffer = true }
      vim.keymap.set({ "n" }, "q", [[<Cmd>call ddu#ui#do_action("quit")<CR>]], opts)
      vim.keymap.set({ "n" }, "<CR>", [[<Cmd>call ddu#ui#do_action("itemAction")<CR>]], opts)
      vim.keymap.set({ "n" }, "i", [[<Cmd>call ddu#ui#do_action("openFilterWindow")<CR>]], opts)
      vim.keymap.set({ "n" }, "P", [[<Cmd>call ddu#ui#do_action("togglePreview")<CR>]], opts)
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "ddu-ff-filter",
    callback = function()
      local opts = { noremap = true, silent = true, buffer = true }
      vim.keymap.set({ "n", "i" }, "<CR>", [[<Esc><Cmd>close<CR>]], opts)
    end,
  })
end

local keymap = function()
  NormalCommandKeymap("<leader>ff", 'call ddu#start(#{name: "file_rec"})', "ddu file_rec")
  NormalCommandKeymap("<leader>fg", 'call ddu#start(#{name: "rg"})', "ddu rg")
  NormalCommandKeymap(
    "<leader>fl",
    'call ddu#start(#{sync: v:true, sources: [#{name: "lsp_definition"}], uiParams: #{ff: #{immediateAction: "open"}}})',
    "ddu lsp-def"
  )
end

local config = function()
  vim.fn["ddu#custom#patch_global"](globalConfig)

  setAutocmd()
  keymap()
end

---@type LazySpec
local spec = {
  "Shougo/ddu.vim",
  -- lazy = false,
  dependencies = dependencies,
  config = config,
}

return spec
