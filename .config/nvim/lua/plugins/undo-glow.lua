---@type LazySpec
local spec = {
  "y3owk1n/undo-glow.nvim",
  event = "BufEnter",
  opts = {
    duration = 1000,
  },
  config = function()
    -- Also add `BufReadPost` so that it will also highlight for first changes
    vim.api.nvim_create_autocmd({ "BufReadPost", "TextChanged" }, {
      pattern = "*",
      callback = function()
        -- Either provide a list of ignored filetypes
        local ignored_filetypes = { "mason", "snacks_picker_list", "lazy", "oil" }
        if vim.tbl_contains(ignored_filetypes, vim.bo.filetype) then
          return
        end

        -- or just use buftype to ignore all other type
        if vim.bo.buftype ~= "" then
          return
        end

        -- then run undo-glow with your desired hlgroup
        vim.schedule(function()
          require("undo-glow").attach_and_run({
            hlgroup = "UgUndo",
          })
        end)
      end,
    })
  end,
}

return spec
