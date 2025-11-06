--- バッファ右上にファイル名を表示
---@type LazySpec
local spec = {
  "b0o/incline.nvim",
  dependencies = {
    "SmiteshP/nvim-navic",
  },
  event = "LspAttach",
  opts = function()
    local navic = require("nvim-navic")
    local miniIcons = require("mini.icons")
    return {
      hide = {
        only_win = true,
      },
      window = {
        padding = 0,
        margin = { horizontal = 0, vertical = 0 },
      },
      render = function(props)
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
        if filename == "" then
          filename = "[No Name]"
        end
        local function getIconPart(fname)
          local ft_icon, ft_hlgroup = miniIcons.get("file", fname)

          if ft_icon == "" then
            return ""
          end

          local colors = GetHighlightColor(ft_hlgroup)
          return colors.fg == "" and { " ", ft_icon, "  " } or { " ", ft_icon, "  ", guifg = colors.fg }
        end
        local iconPart = getIconPart(filename)
        local modified = vim.bo[props.buf].modified
        local res = {
          iconPart,
          { filename, gui = modified and "bold,italic" or "bold" },
          guibg = "",
        }
        if props.focused then
          for _, item in ipairs(navic.get_data(props.buf) or {}) do
            table.insert(res, {
              { "  ", group = "NavicSeparator" },
              { item.icon, group = "NavicIcons" .. item.type },
              { item.name, group = "NavicText" },
            })
          end
        end
        table.insert(res, " ")
        return res
      end,
    }
  end,
}

return spec
