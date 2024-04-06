return {
  "Shougo/ddu.vim",
  dependencies = {
    "vim-denops/denops.vim",
    "Shougo/ddu-ui-ff",
    "Shougo/ddu-ui-filer",
    "ryota2357/ddu-column-icon_filename",
    "Shougo/ddu-commands.vim",
    ------------------------------
    -- | filter                  |
    ------------------------------
    "uga-rosa/ddu-filter-converter_devicon", -- icon
    "ryota2357/ddu-column-icon_filename",
    "yuki-yano/ddu-filter-fzf",
    ------------------------------
    -- | kinds                   |
    ------------------------------
    "Shougo/ddu-kind-file",
    "Shougo/ddu-kind-word",
    ------------------------------
    -- | source                  |
    ------------------------------
    "Shougo/ddu-source-file",
    "Shougo/ddu-source-file_rec",
    "shun/ddu-source-rg",
    "shun/ddu-source-buffer",
    "Shougo/ddu-source-line",
    "Shougo/ddu-source-register",
    ------------------------------
    -- | ui                      |
    ------------------------------
    "Shougo/ddu-ui-ff", -- fuzzy_finder(あいまい検索)
  },
  config = function()
    ------------------------------
    -- | global                  |
    ------------------------------
    vim.fn["ddu#custom#patch_global"]({
      ui = "ff",
      uiParams = {
        ff = {
          floatingBorder = "rounded", -- フローティングウィンドウのborder設定
          filterFloatingPosition = "bottom",
          filterSplitDirection = "floating", -- フィルターをフローティングウィンドウで表示
          previewFloating = true,
          previewFloatingBorder = "rounded",
          previewFloatingTitle = "Preview",
          previewSplit = "horizontal",
          prompt = "> ", -- フィルター入力欄の表示
          split = "floating", -- フローティングウィンドウで表示する
          startFilter = true, -- 自動的にフィルターも表示する
          startAutoAction = true,
          autoAction = { name = "preview", delay = 0 },
        },
      },
      sourceOptions = {
        _ = {
          matchers = { "matcher_fzf" },
          sorters = { "sorter_fzf" },
          ignoreCase = true,
        },
        file = {
          columns = { "icon_filename" },
        },
        line = {
          sorters = {},
        },
      },
      filterParams = {
        matcher_fzf = {
          highlightMatched = "Search",
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
      actionOptions = {
        narrow = {
          quit = true,
        },
      },
    })

    ------------------------------
    -- | local                   |
    ------------------------------
    vim.fn["ddu#custom#patch_local"]("file_rec", {
      sources = {
        {
          name = "file_rec",
          params = {
            ignoredDirectories = { "node_modules", ".git", ".vscode" },
          },
        },
      },
    })
    vim.fn["ddu#custom#patch_local"]("filer", {
      ui = "filer",
      sources = {
        { name = "file", params = {} },
      },
      resume = true,
    })
    vim.fn["ddu#custom#patch_local"]("grep", {
      sourceParams = {
        rg = {
          args = {
            "--column",
            "--no-heading",
            "--color",
            "never",
            "-i",
          },
        },
      },
      uiParams = {
        ff = {
          startFilter = false,
        },
      },
      resume = true,
    })

    ------------------------------
    -- | keymap                  |
    ------------------------------
    local opts = { noremap = true, silent = true, buffer = true }
    vim.keymap.set({ "n" }, "<leader>fd", [[<Cmd>call ddu#start(#{name:"file_rec"})<CR>]], opts)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "ddu-ff",
      callback = function()
        vim.keymap.set({ "n" }, "q", [[<Cmd>call ddu#ui#do_action("quit")<CR>]], opts)
        vim.keymap.set(
          { "n" },
          "<CR>",
          [[<Cmd>call ddu#ui#do_action("closePreviewWindow")<CR><Cmd>call ddu#ui#do_action("itemAction")<CR>]],
          opts
        )
        vim.keymap.set({ "n" }, "i", [[<Cmd>call ddu#ui#do_action("openFilterWindow")<CR>]], opts)
      end,
    })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "ddu-ff-filter",
      callback = function()
        vim.keymap.set({ "n", "i" }, "<CR>", [[<Esc><Cmd>call ddu#ui#do_action("leaveFilterWindow")<CR>]], opts)
      end,
    })
  end,
}
