return {
  "Shougo/ddu.vim",
  dependencies = {
    "vim-denops/denops.vim",
    ------------------------------
    -- | filter                   |
    ------------------------------
    "Shougo/ddu-filter-matcher_substring",
    "uga-rosa/ddu-filter-converter_devicon", -- icon
    ------------------------------
    -- | kinds                    |
    ------------------------------
    "Shougo/ddu-kind-file",
    "Shougo/ddu-kind-word",
    ------------------------------
    -- | source                   |
    ------------------------------
    "Shougo/ddu-source-file_rec",
    "4513ECHO/ddu-source-colorscheme", -- color scheme
    ------------------------------
    -- | ui                       |
    ------------------------------
    "Shougo/ddu-ui-ff", -- fuzzy_finder(あいまい検索)
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
          previewFloatingTitle = "Preview",
          previewSplit = "horizontal",
          prompt = "> ",
          split = "floating",
          startFilter = true,
        },
      },
      sourceOptions = {
        _ = {
          matchers = {
            "matcher_substring",
          },
          ignoreCase = true,
        },
      },
      kindOptions = {
        file = {
          defaultAction = "open",
        },
        word = {
          defaultAction = "append",
        },
      },
    })
    vim.fn["ddu#custom#patch_local"]("file_rec", {
      sources = {
        {
          name = { "file_rec" },
          options = {
            converters = {
              "converter_devicon",
            },
          },
          params = {
            ignoredDirectories = { "node_modules", ".git", ".vscode" },
          },
        },
      },
    })

    vim.fn["ddu#custom#patch_local"]("colorscheme", {
      ui = "ff",
      sources = {
        {
          name = { "colorscheme" },
        },
      },
      kindOptions = {
        colorscheme = {
          defaultAction = "set",
        },
      },
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "ddu-ff",
      callback = function()
        local opts = { noremap = true, silent = true, buffer = true }
        vim.keymap.set({ "n" }, "q", [[<Cmd>call ddu#ui#do_action("quit")<CR>]], opts)
        vim.keymap.set({ "n" }, "<Cr>", [[<Cmd>call ddu#ui#do_action("itemAction")<CR>]], opts)
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
  end,
}
