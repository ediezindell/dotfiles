--- diagnostics を小さくインライン表示
---@type LazySpec
local spec = {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "LspAttach",
  priority = 1000,
  init = function()
    vim.diagnostic.config({ underline = true, virtual_text = false })
  end,
  opts = {
    preset = "ghost",
    options = {
      multilines = {
        enabled = true,
        always_show = true,
      },
    },
    signs = {
      left = "",
      right = "",
      diag = "●",
      arrow = "    ",
      up_arrow = "    ",
      vertical = " │",
      vertical_end = " └",
    },
    blend = {
      factor = 0.22,
    },
  },
}

return spec
