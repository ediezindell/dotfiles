---@type LazySpec
local spec = {
  "Shougo/ddu.vim",
  event = "VeryLazy",
  dependencies = {
    "kuuote/ddu-source-git_status",
    "kuuote/ddu-source-mr",
    "kyoh86/ddu-filter-converter_hl_dir",
    "matsui54/ddu-source-file_external",
    "Shougo/ddu-commands.vim",
    "Shougo/ddu-filter-converter_display_word",
    "Shougo/ddu-filter-matcher_files",
    "Shougo/ddu-filter-matcher_substring",
    "Shougo/ddu-filter-sorter_alpha",
    "Shougo/ddu-kind-file",
    "Shougo/ddu-source-file_rec",
    "Shougo/ddu-ui-ff",
    "shun/ddu-source-rg",
    "uga-rosa/ddu-filter-converter_devicon",
    "vim-denops/denops.vim",
  },
  init = function()
    local group = vim.api.nvim_create_augroup("DduAuGroup", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "ddu-ff",
      callback = function(ev)
        local opts = { noremap = true, silent = true, buffer = ev.buf }
        vim.keymap.set({ "n" }, "q", [[<Cmd>call ddu#ui#do_action("quit")<CR>]], opts)
        vim.keymap.set({ "n" }, "<CR>", [[<Cmd>call ddu#ui#do_action("itemAction")<CR>]], opts)
        vim.keymap.set({ "n" }, "i", [[<Cmd>call ddu#ui#do_action("openFilterWindow")<CR>]], opts)
        vim.keymap.set({ "n" }, "P", [[<Cmd>call ddu#ui#do_action("togglePreview")<CR>]], opts)
      end,
      group = group,
    })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "ddu-ff-filter",
      callback = function(ev)
        local opts = { noremap = true, silent = true, buffer = ev.buf }
        vim.keymap.set({ "n", "i" }, "<CR>", [[<Cmd>call ddu#ui#do_action("closeFilterWindow")<CR>]], opts)
        vim.keymap.set({ "n", "i" }, "<Esc>", [[<Cmd>call ddu#ui#do_action("closeFilterWindow")<CR>]], opts)
      end,
      group = group,
    })
  end,
  keys = {
    { "<space>ff", [[<Cmd>call ddu#start( #{ name: "file_rec" } )<CR>]],      desc = "ddu file_rec" },
    { "<space>fF", [[<Cmd>call ddu#start( #{ name: "dir_rec" } )<CR>]],       desc = "ddu dir_rec" },
    { "<space>f;", [[<Cmd>call ddu#start( #{ name: "file_external" } )<CR>]], desc = "ddu file_ext" },
    { "<space>fg", [[<Cmd>call ddu#start( #{ name: "rg" } )<CR>]],            desc = "ddu rg" },
    {
      "<space>fru",
      [[<Cmd>call ddu#start( #{ name: "mru" } )<CR>]],
      desc = "ddu mru",
    },
    {
      "<space>frw",
      [[<Cmd>call ddu#start( #{ name: "mrw" } )<CR>]],
      desc = "ddu mrw",
    },
    { "<space>fh",  [[<Cmd>call ddu#start( #{ name: "git_status" } )<CR>]],          desc = "ddu git_status" },
    { "<space>fGm", [[<Cmd>call ddu#start( #{ name: "git_diff_main_files" } )<CR>]], desc = "ddu git_diff_main_files" },
  },
  config = function()
    local height = "&lines - 3"
    local halfWidth = "&columns / 2"
    local width = halfWidth .. " - 2"

    vim.fn["ddu#custom#alias"]("_", "source", "dir_rec", "file_external")
    vim.fn["ddu#custom#alias"]("_", "source", "mru", "mr")
    vim.fn["ddu#custom#alias"]("_", "source", "mrw", "mr")
    vim.fn["ddu#custom#alias"]("_", "source", "git_diff_main_files", "file_external")
    vim.fn["ddu#custom#patch_global"]({
      ui = "ff",
      uiParams = {
        ff = {
          -- window
          split = "floating",
          floatingBorder = "rounded",
          winHeight = height,
          winWidth = width .. " + 1",
          winRow = 0,
          winCol = 0,
          -- preview
          previewFloating = true,
          previewFloatingBorder = "rounded",
          previewHeight = height,
          previewWidth = width,
          previewRow = 2,
          previewCol = halfWidth .. " + 1",
          previewWindowOptions = {
            { "&signcolumn",     "no" },
            { "&foldcolumn",     0 },
            { "&foldenable",     0 },
            -- { "&number", 0 },
            { "&relativenumber", 0 },
            { "&wrap",           0 },
          },
          -- action
          startAutoAction = true,
          -- 既定の delay は 10ms でほぼ debounce されず、スクロール中に
          -- preview（buffer 生成 + filetype 検出 + autocmd 一式）が連発する
          autoAction = { name = "preview", delay = 200 },
        },
      },
      sourceParams = {
        file_rec = {
          ignoredDirectories = { "node_modules", ".git", "dist", ".next", ".cache" },
        },
        rg = {
          args = { "--column", "--no-heading", "--color", "never", "--smart-case" },
        },
        mru = {
          kind = "mru",
        },
        mrw = {
          kind = "mrw",
        },
        dir_rec = {
          cmd = { "fd", ".", "-H", "-t", "d" },
          ignoredDirectories = { "node_modules", ".git", "dist", ".next", ".cache" },
        },
        git_diff_main_files = {
          cmd = { "git", "diff", "main", "--name-only" },
        },
      },
      sourceOptions = {
        _ = {
          matchers = { "matcher_substring" },
          ignoreCase = true,
          smartCase = true,
          sorters = { "sorter_alpha" },
          converters = { "converter_devicon", "converter_hl_dir" },
        },
        rg = {
          sorters = {},
          matchers = {},
          volatile = true,
          converters = { "converter_display_word", "converter_devicon", "converter_hl_dir" },
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

    local sources = { "file_rec", "dir_rec", "mr", "git_status", "rg", "file_external", "mru", "mrw" }
    for _, source in ipairs(sources) do
      vim.fn["ddu#custom#patch_local"](source, {
        sources = { source },
        uiParams = {
          ff = {
            floatingTitle = source,
          },
        },
      })
    end
  end,
}

return spec
