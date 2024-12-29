---@type LazySpec
local spec = {
  "Shougo/ddu.vim",
  lazy = false,
  dependencies = {
    "Shougo/ddu-commands.vim",
    "Shougo/ddu-filter-converter_display_word",
    "Shougo/ddu-filter-matcher_files",
    "Shougo/ddu-filter-matcher_substring",
    "Shougo/ddu-filter-sorter_alpha",
    "Shougo/ddu-kind-file",
    "Shougo/ddu-source-file_rec",
    "Shougo/ddu-ui-ff",
    "kuuote/ddu-source-git_status",
    "kuuote/ddu-source-mr",
    "kyoh86/ddu-filter-converter_hl_dir",
    "lambdalisue/vim-mr",
    "matsui54/ddu-source-file_external",
    "shun/ddu-source-rg",
    "uga-rosa/ddu-filter-converter_devicon",
    "vim-denops/denops.vim",
    "matsui54/ddu-source-file_external",
  },
  init = function()
    local group = vim.api.nvim_create_augroup("DduAuGroup", { clear = true })
    local keymapOpts = { noremap = true, silent = true, buffer = true }
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "ddu-ff",
      callback = function()
        vim.keymap.set({ "n" }, "q", [[<Cmd>call ddu#ui#do_action("quit")<CR>]], keymapOpts)
        vim.keymap.set({ "n" }, "<CR>", [[<Cmd>call ddu#ui#do_action("itemAction")<CR>]], keymapOpts)
        vim.keymap.set({ "n" }, "i", [[<Cmd>call ddu#ui#do_action("openFilterWindow")<CR>]], keymapOpts)
        vim.keymap.set({ "n" }, "P", [[<Cmd>call ddu#ui#do_action("togglePreview")<CR>]], keymapOpts)
      end,
      group = group,
    })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "ddu-ff-filter",
      callback = function()
        vim.keymap.set({ "n", "i" }, "<CR>", [[<Esc><Cmd>close<CR>]], keymapOpts)
      end,
      group = group,
    })
  end,
  keys = {
    { "<space>ff", [[<Cmd>call ddu#start( #{ name: "file_rec" } )<CR>]],   desc = "ddu file_rec" },
    { "<space>fq", [[<Cmd>call ddu#start( #{ name: "rg" } )<CR>]],         desc = "ddu rg" },
    { "<space>fr", [[<Cmd>call ddu#start( #{ name: "mr" } )<CR>]],         desc = "ddu mr" },
    { "<space>fd", [[<Cmd>call ddu#start( #{ name: "git_status" } )<CR>]], desc = "ddu git_status" },
  },
  config = function()
    local height = "&lines - 3"
    local halfWidth = "&columns / 2"
    local width = halfWidth .. " - 2"

    vim.fn["ddu#custom#alias"]("files", "source", "dir_rec", "file_external")
    vim.fn["ddu#custom#patch_global"]({
      ui = "ff",
      uiParams = {
        ff = {
          -- window
          split = "floating",
          floatingBorder = "rounded",
          winHeight = height,
          winWidth = width,
          winRow = 0,
          winCol = 0,
          -- preview
          previewFloating = true,
          previewFloatingBorder = "rounded",
          previewHeight = height,
          previewWidth = width,
          previewRow = 2,
          previewCol = halfWidth .. " + 2",
          previewWindowOptions = {
            { "&signcolumn",     "no" },
            { "&foldcolumn",     0 },
            { "&foldenable",     0 },
            -- { "&number", 0 },
            { "&relativenumber", 0 },
            { "&wrap",           0 },
          },
          -- prompt
          prompt = "",
          -- action
          startAutoAction = true,
          autoAction = { name = "preview" },
          previewWindowOptions = {
            { "&signcolumn",     "no" },
            { "&relativenumber", 0 },
          },
        },
      },
      sources = { "file_rec" },
      sourceParams = {
        file_rec = { ignoredDirectories = { "node_modules", ".git", "dist", ".vscode", ".next" } },
        rg = { args = { "--column", "--no-heading", "--color", "never" } },
        dir_rec = { cmd = { "fd", ".", "-H", "-t", "d" } },
      },
      sourceOptions = {
        _ = {
          matchers = { "matcher_substring" },
          ignoreCase = true,
          sorters = { "sorter_alpha" },
        },
        file_rec = {
          converters = { "converter_devicon", "converter_hl_dir" },
        },
        mr = {
          converters = { "converter_devicon", "converter_hl_dir" },
        },
        git_status = {
          converters = { "converter_git_status", "converter_devicon", "converter_hl_dir" },
        },
        rg = {
          converters = { "converter_devicon", "converter_hl_dir" },
          matchers = { "converter_display_word", "matcher_substring" },
        },
      },
      kindOptions = {
        file = { defaultAction = "open" },
        git_status = { defaultAction = "open" },
      },
      filterParams = {
        matcher_substring = { highlightMatched = "Search" },
      },
    })

    vim.fn["ddu#custom#patch_local"]("file_external", {
      sources = { "file_external" },
      sourceParams = {
        file_external = {
          -- cmd = { 'fd', '.', '-H', '-E', '__pycache__', '-t', 'f' }
          cmd = { "fd", ".", "-H", "-t", "d" },
        },
      },
      uiParams = {
        ff = {
          floatingTitle = { { "file_external" } },
        },
      },
    })

    local sources = { "file_rec", "mr", "git_status", "rg" }
    for _, source in ipairs(sources) do
      vim.fn["ddu#custom#patch_local"](source, {
        sources = { source },
        uiParams = {
          ff = {
            floatingTitle = { { source } },
          },
        },
      })
    end
  end,
}

return spec
