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
    {
      dir = "~/git/ddu-source-tgrep",
    },
    "uga-rosa/ddu-filter-converter_devicon",
    "vim-denops/denops.vim",
  },
  init = function()
    local group = vim.api.nvim_create_augroup("DduAuGroup", { clear = true })

    -- 下部の statusline 表示用関数
    _G.ddu_statusline = function()
      local status = vim.w.ddu_ui_ff_status
      local name = (status and status.name) or vim.b.ddu_ui_name or "ddu"
      local input = (status and status.input and status.input ~= "") and (" " .. status.input) or ""

      -- 1. 初回描画時(statusがまだない)、または検索中の場合 (done == false)
      if not status or type(status) ~= "table" or status.done == false then
        return string.format(" [ddu-%s]%s [Searching...]", name, input)
      end

      -- 2. 検索完了で 0 件の場合
      local line_count = vim.api.nvim_buf_line_count(0)
      local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ""
      if line_count == 0 or (line_count == 1 and first_line == "") then
        return string.format(" [ddu-%s]%s [No matches]", name, input)
      end

      -- 3. 検索完了：ヒットあり（現在行 / 総件数）
      local cursor_line = vim.fn.line(".")
      return string.format(" [ddu-%s] %d/%d%s", name, cursor_line, line_count, input)
    end

    -- ddu-ff の全ウィンドウの statusline を上書き適用 & 再描画する関数
    local function apply_ddu_statusline()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "ddu-ff" then
          -- ウィンドウローカルの statusline を設定して ddu の空文字消去を上書き
          vim.wo[win].statusline = "%{v:lua.ddu_statusline()}"
        end
      end
      vim.cmd("redrawstatus")
    end

    -- FileType と BufWinEnter（ウィンドウ描画時）の両方で適用
    vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
      pattern = "ddu-ff",
      callback = function(ev)
        local opts = { noremap = true, silent = true, buffer = ev.buf }
        vim.keymap.set({ "n" }, "q", [[<Cmd>call ddu#ui#do_action("quit")<CR>]], opts)
        vim.keymap.set({ "n" }, "<CR>", [[<Cmd>call ddu#ui#do_action("itemAction")<CR>]], opts)
        vim.keymap.set({ "n" }, "i", [[<Cmd>call ddu#ui#do_action("openFilterWindow")<CR>]], opts)
        vim.keymap.set({ "n" }, "P", [[<Cmd>call ddu#ui#do_action("togglePreview")<CR>]], opts)
        vim.keymap.set({ "n" }, "p", [[<Cmd>call ddu#ui#do_action("toggleAutoAction")<CR>]], opts)

        apply_ddu_statusline()
      end,
      group = group,
    })

    -- 各種状態更新イベント時にも確実に適用
    vim.api.nvim_create_autocmd("User", {
      pattern = { "Ddu:updated", "Ddu:uiDone", "Ddu:uiOpenFilterWindow", "Ddu:uiCloseFilterWindow" },
      callback = function()
        apply_ddu_statusline()
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
    { "<space>ff", [[<Cmd>call ddu#start( #{ name: "file_rec" } )<CR>]], desc = "ddu file_rec" },
    { "<space>fF", [[<Cmd>call ddu#start( #{ name: "dir_rec" } )<CR>]], desc = "ddu dir_rec" },
    { "<space>f;", [[<Cmd>call ddu#start( #{ name: "file_external" } )<CR>]], desc = "ddu file_ext" },
    { "<space>ft", [[<Cmd>call ddu#start( #{ name: "tgrep" } )<CR>]], desc = "ddu tgrep" },
    { "<space>fg", [[<Cmd>call ddu#start( #{ name: "rg" } )<CR>]], desc = "ddu rg" },
    { "<space>fG", [[<Cmd>call ddu#start( #{ name: "rg_no_test" } )<CR>]], desc = "ddu rg (no test/stories)" },
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
    { "<space>fh", [[<Cmd>call ddu#start( #{ name: "git_status" } )<CR>]], desc = "ddu git_status" },
    { "<space>fj", [[<Cmd>call ddu#start( #{ name: "git_diff_main_files" } )<CR>]], desc = "ddu git_diff_main_files" },
  },
  config = function()
    -- local height = "&lines - 3"
    local height = "&lines - 4"
    -- local halfWidth = "&columns / 2"
    local halfWidth = "&columns / 2 - 1"
    local width = halfWidth .. " - 2"

    local rgArgs = { "--column", "--no-heading", "--color", "never", "--smart-case" }
    local rgNoTestArgs = vim.list_extend(vim.deepcopy(rgArgs), {
      "--glob",
      "!**/*.{test,spec}.*",
      "--glob",
      "!**/*.stories.*",
      "--glob",
      "!**/{__tests__,__stories__}/**",
    })
    local rgSourceOptions = {
      sorters = {},
      matchers = {},
      volatile = true,
      converters = { "converter_display_word", "converter_devicon", "converter_hl_dir" },
    }

    vim.fn["ddu#custom#alias"]("_", "source", "dir_rec", "file_external")
    vim.fn["ddu#custom#alias"]("_", "source", "mru", "mr")
    vim.fn["ddu#custom#alias"]("_", "source", "mrw", "mr")
    vim.fn["ddu#custom#alias"]("_", "source", "git_diff_main_files", "file_external")
    vim.fn["ddu#custom#alias"]("_", "source", "rg_no_test", "rg")
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
            { "&signcolumn", "no" },
            { "&foldcolumn", 0 },
            { "&foldenable", 0 },
            -- { "&number", 0 },
            { "&relativenumber", 0 },
            { "&wrap", 0 },
          },
          -- 起動時に preview すると描画が止まるので、toggleAutoAction で必要な時だけ有効にする
          startAutoAction = false,
          autoAction = { name = "preview", delay = 200 },
        },
      },
      sourceParams = {
        file_rec = {
          ignoredDirectories = { "node_modules", ".git", "dist", ".next", ".cache" },
        },
        rg = {
          args = rgArgs,
        },
        rg_no_test = {
          args = rgNoTestArgs,
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
        rg = rgSourceOptions,
        rg_no_test = rgSourceOptions,
        tgrep = rgSourceOptions,
      },
      kindOptions = {
        file = { defaultAction = "open" },
        git_status = { defaultAction = "open" },
      },
      filterParams = {
        matcher_substring = { highlightMatched = "Search" },
      },
    })

    local sources =
      { "file_rec", "dir_rec", "mr", "git_status", "rg", "rg_no_test", "tgrep", "file_external", "mru", "mrw" }
    for _, source in ipairs(sources) do
      vim.fn["ddu#custom#patch_local"](source, {
        sources = { source },
        uiParams = {
          ff = {
            overwriteStatusline = false,
            floatingTitle = source,
          },
        },
      })
    end

    -- 初回 ddu#start で拡張の import 待ちが出るので先読みする。loader は name ごとに別
    for _, source in ipairs(sources) do
      vim.fn["ddu#load"](source, "ui", { "ff" })
      vim.fn["ddu#load"](source, "kind", { "file" })
      vim.fn["ddu#load"](source, "source", { source })
      vim.fn["ddu#load"](source, "filter", {
        "matcher_substring",
        "sorter_alpha",
        "converter_display_word",
        "converter_devicon",
        "converter_hl_dir",
      })
    end
  end,
}

return spec
