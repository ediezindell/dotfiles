---@type LazySpec
local spec = {
  "Shougo/ddu.vim",
  lazy = false,
  dependencies = {
    "vim-denops/denops.vim",
    "Shougo/ddu-filter-matcher_files",
    "Shougo/ddu-filter-matcher_substring",
    "Shougo/ddu-filter-sorter_alpha",
    "Shougo/ddu-kind-file",
    "Shougo/ddu-source-file_rec",
    "Shougo/ddu-ui-ff",
    "kuuote/ddu-source-git_status",
    "kyoh86/ddu-filter-converter_hl_dir",
    "shun/ddu-source-rg",
    "uga-rosa/ddu-filter-converter_devicon",
    "Shougo/ddu-commands.vim",
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
      group = group
    })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "ddu-ff-filter",
      callback = function()
        vim.keymap.set({ "n", "i" }, "<CR>", [[<Esc><Cmd>close<CR>]], keymapOpts)
      end,
      group = group
    })
  end,
  keys = {
    { "<space>ff", [[<Cmd>call ddu#start( #{ name: "file_rec" } )<CR>]],   desc = "ddu file_rec" },
    { "<space>fd", [[<Cmd>call ddu#start( #{ name: "rg" } )<CR>]],         desc = "ddu file_rec" },
    { "<space>fg", [[<Cmd>call ddu#start( #{ name: "git_status" } )<CR>]], desc = "ddu git_status" },
  },
  config = function()
    vim.fn["ddu#custom#patch_global"]({
      ui = "ff",
      uiParams = {
        ff = {
          split = 'floating',
          winHeight = '&lines',
          winWidth = '&columns / 2',
          winRow = 0,
          winCol = 0,
          previewFloating = true,
          previewHeight = '&lines',
          previewWidth = '&columns / 2',
          previewRow = 1,
          previewCol = '&columns / 2',
          -- floatingBorder        = "rounded",
          -- previewFloating       = true,
          -- previewRow            = 12,
          -- previewFloatingBorder = "rounded",
          -- prompt                = "> ",
          -- previewWidth          = "&columns / 2",
          -- previewHeight         = 16,
          -- split                 = "floating",
        },
      },
      sources = {
        "file_rec",
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
          converters = { "converter_devicon", "converter_hl_dir" },
        },
        rg = {
          matchers = { "matcher_substring", "matcher_files" },
        },
        git_status = {
          converters = { "converter_git_status" }
        }
      },
      kindOptions = {
        file = { defaultAction = "open" },
        git_status = { defaultAction = "open" }
      },
      filterParams = {
        matcher_substring = { highlightMatched = "Search" },
      },
    })

    local sources = { "file_rec", "rg", "git_status" }
    for _, source in ipairs(sources) do
      vim.fn["ddu#custom#patch_local"](source, {
        sources = { source },
        uiParams = {
          ff = {
            floatingTitle = { { source } }
          }
        }
      })
    end
  end
}

return spec
