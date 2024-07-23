-- `-` でファイルエクスプローラーを開く
local tb = function(value)
  if value == nil then
    return false
  elseif type(value) == "boolean" then
    return value
  elseif type(value) == "number" then
    return value ~= 0
  elseif type(value) == "string" then
    return string.lower(value) == "true"
  else
    return false
  end
end

local isImage = function(url)
  local extension = url:match("^.+(%..+)$")
  local imageExt = {
    ".bmp",
    ".jpg",
    ".jpeg",
    ".png",
    ".gif",
  }

  return vim.iter(imageExt):any(function(ext)
    return extension == ext
  end)
end

local getEntryAbsolutePath = function()
  local oil = require("oil")
  local entry = oil.get_cursor_entry()
  local dir = oil.get_current_dir()
  if not entry or not dir then
    return
  end
  return dir .. entry.name, entry, dir
end

-- local open_file_with_quicklook = function(path)
--   vim.cmd(("silent !qlmanage -p %s &"):format(path))
-- end
-- local openWithQuickLook = {
--   callback = function()
--     local path = assert((getEntryAbsolutePath()))
--     open_file_with_quicklook(path)
--   end,
--   desc = "Open with QuickLook",
-- }

local getNeovimWeztermPane = function()
  local wezterm_pane_id = vim.env.WEZTERM_PANE
  if not wezterm_pane_id then
    vim.notify("Wezterm pane not found", vim.log.levels.ERROR)
    return
  end
  return tonumber(wezterm_pane_id)
end

local activeWeztermPane = function(wezterm_pane_id)
  vim.system({ "wezterm", "cli", "activate-pane", "--pane-id", wezterm_pane_id })
end

local openNewWeztermPane = function(opt)
  local _opt = opt or {}
  local percent = _opt.percent or 30
  local direction = _opt.direction or "right"

  local cmd = {
    "wezterm",
    "cli",
    "split-pane",
    ("--percent=%d"):format(percent),
    ("--%s"):format(direction),
    "--",
    -- "zsh",
    "sh",
  }
  local obj = vim.system(cmd, { text = true }):wait()
  local wezterm_pane_id = assert(tonumber(obj.stdout))

  return wezterm_pane_id
end

local closeWeztermPane = function(wezterm_pane_id)
  if wezterm_pane_id ~= nil then
    vim.system({
      "wezterm",
      "cli",
      "kill-pane",
      ("--pane-id=%d"):format(wezterm_pane_id),
    })
  end
end

local sendCommandToWeztermPane = function(wezterm_pane_id, command)
  local cmd = {
    "echo",
    ("'%s'"):format(command),
    "|",
    "wezterm",
    "cli",
    "send-text",
    "--no-paste",
    ("--pane-id=%d"):format(wezterm_pane_id),
  }
  vim.fn.system(table.concat(cmd, " "))
end

local _l = function(str)
  local lambda_chunk = [[
	return function(%s)
	  return %s
	end
	]]
  local arg, body = str:match("(.*):(.*)")
  return assert(load(lambda_chunk:format(arg, body)))()
end

local listWeztermPanes = function()
  local cli_result = vim
    .system({
      "wezterm",
      "cli",
      "list",
      ("--format=%s"):format("json"),
    }, { text = true })
    :wait()
  local json = vim.json.decode(cli_result.stdout)
  local panes = vim.iter(json):map(_l("obj: { pane_id = obj.pane_id, tab_id = obj.tab_id }"))

  return panes
end

local getPreviewWeztermPaneId = function()
  local panes = listWeztermPanes()
  local neovim_wezterm_pane_id = getNeovimWeztermPane()
  local current_tab_id = assert(panes:find(function(obj)
    return obj.pane_id == neovim_wezterm_pane_id
  end)).tab_id
  local preview_pane = panes:find(function(obj)
    return --
      obj.tab_id == current_tab_id --
        and tonumber(obj.pane_id) > tonumber(neovim_wezterm_pane_id) -- new pane id should be greater than current pane id
  end)
  return preview_pane ~= nil and preview_pane.pane_id or nil
end

local openWeztermPreviewPane = function()
  local preview_pane_id = getPreviewWeztermPaneId()
  if preview_pane_id == nil then
    preview_pane_id = openNewWeztermPane({ percent = 30, direction = "right" })
  end
  return preview_pane_id
end

local is_wezterm_preview_open = function()
  return getPreviewWeztermPaneId() ~= nil
end

---Debounce a function
---@param func function
---@param wait number
local debounce = function(func, wait)
  local timer_id
  ---@vararg any
  return function(...)
    if timer_id ~= nil then
      vim.uv.timer_stop(timer_id)
    end
    local args = { ... }
    timer_id = assert(vim.uv.new_timer())
    vim.uv.timer_start(timer_id, wait, 0, function()
      if args ~= nil then
        func(unpack(args))
      end
      timer_id = nil
    end)
  end
end

local weztermPreview = {
  callback = function()
    if is_wezterm_preview_open() then
      closeWeztermPane(getPreviewWeztermPaneId())
    end
    local oil = require("oil")
    local preview_entry_id = nil
    local preview_cmd = nil

    local neovim_wezterm_pane_id = getNeovimWeztermPane()
    local bufnr = vim.api.nvim_get_current_buf()

    local updateWeztermPreview = debounce(
      vim.schedule_wrap(function()
        if vim.api.nvim_get_current_buf() ~= bufnr then
          return
        end
        local entry = oil.get_cursor_entry()
        -- Don't update in visual mode. Visual mode implies editing not browsing,
        -- and updating the preview can cause flicker and stutter.
        if entry ~= nil then
          local preview_pane_id = openWeztermPreviewPane()
          activeWeztermPane(neovim_wezterm_pane_id)

          if preview_entry_id == entry.id then
            return
          end

          if preview_cmd == "bat" then
            sendCommandToWeztermPane(preview_pane_id, "q")
            preview_cmd = nil
          end

          local path = assert(getEntryAbsolutePath())
          local command = ""
          if entry.type == "directory" then
            local cmd = "ls -l"
            command = command .. ("%s %s"):format(cmd, path)
            preview_cmd = cmd
          elseif entry.type == "file" and isImage(path) then
            local cmd = "wezterm imgcat"
            command = command .. ('%s "%s"'):format(cmd, path)
            preview_cmd = cmd
          elseif entry.type == "file" then
            local cmd = "bat"
            command = command .. ("%s %s"):format(cmd, path)
            preview_cmd = cmd
          end

          sendCommandToWeztermPane(preview_pane_id, command)
          preview_entry_id = entry.id
        end
      end),
      50
    )

    updateWeztermPreview()

    local config = require("oil.config")
    if config.preview.update_on_cursor_moved then
      vim.api.nvim_create_autocmd("CursorMoved", {
        desc = "Update oil wezterm preview",
        group = "Oil",
        buffer = bufnr,
        callback = function()
          updateWeztermPreview()
        end,
      })
    end

    vim.api.nvim_create_autocmd({ "BufLeave", "BufDelete", "VimLeave" }, {
      desc = "Close oil wezterm preview",
      group = "Oil",
      buffer = bufnr,
      callback = function()
        closeWeztermPane(getPreviewWeztermPaneId())
      end,
    })
  end,
  desc = "Preview with Wezterm",
}

local selectHandler = {
  callback = function()
    local oil = require("oil")
    local entry = oil.get_cursor_entry()
    local path = assert(getEntryAbsolutePath())

    if entry.type == "file" and isImage(path) then
      weztermPreview.callback()
    else
      require("oil.actions").select.callback()
    end
  end,
}

return {
  "stevearc/oil.nvim",
  dependencies = { { "echasnovski/mini.icons", opts = {} } },
  init = function()
    local oilPathPatterns = { "oil://", "oil-ssh://", "oil-trash://" }
    local path = vim.fn.expand("%:p")
    local isDir = tb(vim.fn.isdirectory(path))
    local isOilPath = vim.iter(oilPathPatterns):any(function(opp)
      return (string.find(path, opp, 1, true)) ~= nil
    end)
    if isDir or isOilPath then
      require("oil")
    end
  end,
  opts = function()
    local trash_command = "trash"
    local is_trash = tb(vim.fn.executable(trash_command))
    return {
      keymaps = {
        ["?"] = "actions.show_help",
        ["gx"] = "actions.open_external",
        -- ["<CR>"] = "actions.select",
        ["<CR>"] = selectHandler,
        ["-"] = "actions.parent",
        ["<C-p>"] = "actions.preview",
        ["gp"] = weztermPreview,
        -- ["g<leader>"] = openWithQuickLook,
        ["q"] = "actions.close",
        ["<C-l>"] = "actions.refresh",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["g."] = "actions.toggle_hidden",
        ["<C-s>"] = "actions.select_vsplit",
        ["<C-h>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
      },
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name, _)
          local ignore_list = { ".DS_Store" }
          return vim.tbl_contains(ignore_list, name)
        end,
      },
      use_default_keymaps = false,
      delete_to_trash = is_trash,
      trash_command = trash_command,
      default_file_explorer = true,
      columns = {
        "permissions",
        "size",
        "mtime",
        "icon",
      },
    }
  end,
  event = { "BufReadPre", "BufNewFile" },
  config = function(_, opts)
    require("oil").setup(opts)
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
  end,
}
