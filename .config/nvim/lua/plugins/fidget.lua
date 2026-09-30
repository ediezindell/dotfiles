-- 右下に通知や進捗情報を表示
---@type LazySpec
local spec = {
  "j-hui/fidget.nvim",
  event = "VeryLazy",
  config = function()
    local fidget = require("fidget")
    fidget.setup({})

    -- マクロ記録中表示
    local ns = vim.api.nvim_create_namespace("extmode")
    local progress = nil
    local extmode = vim.schedule_wrap(function()
      local reg = vim.fn.reg_recording()
      if reg ~= "" then
        if progress == nil then
          progress = fidget.progress.handle.create({
            lsp_client = { name = string.format("[@%s] Recording Macro", reg) },
            message = "Recording...",
          })
        end
      else
        if progress ~= nil then
          progress:finish()
          progress = nil
        end
      end
    end)
    vim.on_key(Debounce(extmode, 100), ns)
  end,
}
return spec
