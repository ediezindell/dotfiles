---@type LazySpec
local spec = {
  "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
  event = "LspAttach",
  init = function()
    vim.diagnostic.config({
      virtual_text = {
        format = function() return "" end
      }
    })
  end,
  keys = {
    { "<space>l", [[lua require("lsp_lines").toggle]], desc = "Toggle lsp_lines" }
  },
  opts = {
    format = function(diagnostic)
      return string.format("%s (%s: %s)", diagnostic.message, diagnostic.source, diagnostic.code)
    end,
  }
}

return spec
