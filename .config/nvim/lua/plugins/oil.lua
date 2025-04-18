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

---@type LazySpec
local spec = {
  "stevearc/oil.nvim",
  event = { "BufReadPre", "BufNewFile" },
  keys = { { "-", "<CMD>Oil<CR>", desc = "open parent directory with oil" } },
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
    return {
      use_default_keymaps = false,
      keymaps = {
        ["<CR>"] = "actions.select",
        -- ["<C-v>"] = "actions.select_vsplit",
        ["<C-p>"] = "actions.preview",
        -- ["<C-r>"] = "actions.refresh",
        -- ["g."] = "actions.toggle_hidden",
        ["-"] = "actions.parent",
        ["q"] = "actions.close",
        -- ["?"] = "actions.show_help",
      },
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name, _)
          local ignore_list = { ".DS_Store", "oil:", "index.module.css.d.ts", "index.module.css.d.ts.map" }
          return vim.tbl_contains(ignore_list, name)
        end,
      },
      default_file_explorer = true,
      columns = {
        "permissions",
        "size",
        "mtime",
        "icon",
      },
    }
  end,
}

return spec
