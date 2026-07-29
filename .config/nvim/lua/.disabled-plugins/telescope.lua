-- fuzzy finder
---@type LazySpec
local spec = {
  "nvim-telescope/telescope.nvim",
  event = "VimEnter",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
    "danielvolchek/tailiscope.nvim",
    {
      "notjedi/nvim-rooter.lua",
      config = true,
    },
    {
      "prochri/telescope-all-recent.nvim",
      dependencies = {
        "nvim-telescope/telescope.nvim",
        "kkharji/sqlite.lua",
        -- optional, if using telescope for vim.ui.select
        "stevearc/dressing.nvim",
      },
      opts = {
        -- your config goes here
      },
    },
  },
  keys = {
    {
      "<space>fb",
      function()
        require("telescope.builtin").buffers()
      end,
      desc = "telescope buffers",
    },
    {
      "<space>ff",
      function()
        require("telescope.builtin").find_files()
      end,
      desc = "telescope find_files",
    },
    {
      "<space>fg",
      function()
        require("telescope.builtin").live_grep({
          glob_pattern = "!.git",
        })
      end,
      desc = "telescope live_grep",
    },
    {
      "<space>fh",
      function()
        require("telescope.builtin").help_tags()
      end,
      desc = "telescope help",
    },
    {
      "<space>fr",
      "<Cmd>Telescope resume<CR>",
      desc = "telescope resume",
    },
    {
      "<space>ft",
      "<Cmd>Telescope tailwind<CR>",
      desc = "telescope Tailwind CSS",
    },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local builtin = require("telescope.builtin")
    local action_state = require("telescope.actions.state")

    telescope.setup({
      defaults = {
        mappings = {
          i = {
            ["<esc>"] = actions.close,
          },
          n = {
            ["<esc>"] = actions.close,
            [":"] = actions.close,
            ["q"] = actions.close,
          },
        },
        path_display = {
          -- filename_first = {
          --   reverse_directories = false,
          -- },
        },
        layout_strategy = "vertical",
        -- winblend = 20,
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
        },
      },
      pickers = {
        find_files = {
          hidden = true,
          file_ignore_patterns = { ".git" },
        },
      },
      extensions = {
        tailiscope = {
          default = "base",
          doc_icon = "󱏿  ",
          maps = {
            i = {
              back = "<C-h>",
              open_doc = "<C-o>",
            },
          },
        },
      },
    })

    require("telescope").load_extension("tailiscope")

    --- 前回のpickerの前後の候補を開く
    --- @see https://qiita.com/delphinus/items/3462185863139bdd81ba
    local function get_picker(prompt_bufnr)
      local picker = action_state.get_current_picker(prompt_bufnr)
      if not picker then
        vim.notify("found no picker", vim.log.levels.WARN)
        return
      elseif picker.manager:num_results() <= 1 then
        vim.notify("picker has no entry to open", vim.log.levels.WARN)
        actions.close(prompt_bufnr)
        if picker.initial_mode == "insert" then
          vim.api.nvim_feedkeys([[<C-\><C-n>]], "i", true)
        end
        return
      end
      return picker
    end
    local function resume_and_select(change)
      return function()
        vim.api.nvim_create_autocmd("User", {
          group = vim.api.nvim_create_augroup("resume_and_select", {}),
          pattern = "TelescopeResumePost",
          once = true,
          callback = function(args)
            local picker = get_picker(args.buf)
            if picker then
              picker:move_selection(change)
              vim.schedule_wrap(actions.select_default)(args.buf)
            end
          end,
        })

        builtin.resume({})
      end
    end
    NormalKeymap("<Leader>fj", resume_and_select(1), "Resume Telescope picker and open the next candidate")
    NormalKeymap("<Leader>fk", resume_and_select(-1), "Resume Telescope picker and open the previous candidate")

    local find_file_from_pj_root = function()
      local root = require("nvim-rooter").get_root()
      print(root)
      local opts = nil
      if root ~= nil then
        opts = {
          root = root,
        }
      end
      require("telescope.builtin").find_files(opts)
    end

    -- NormalKeymap("<space>ff", find_file_from_pj_root, "telescope find_files (from project root)")
  end,
}

return spec
