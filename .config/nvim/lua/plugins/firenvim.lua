---@type LazySpec
local spec = {
  "glacambre/firenvim",
  build = ":call firenvim#install(0)",
  lazy = false,
  init = function()
    vim.g.firenvim_config = {
      localSettings = {
        [".*"] = {
          selector = 'textarea, div[role="textbox"]',
          priority = 0,
        },
        ["https://www\\.google\\.com.*"] = {
          takeover = "never",
          priority = 1,
        },
      },
    }

    vim.api.nvim_create_autocmd({ "UIEnter" }, {
      callback = function()
        local client = vim.api.nvim_get_chan_info(vim.v.event.chan).client
        if client ~= nil and client.name == "Firenvim" then
          vim.o.cmdheight = 0
          vim.o.laststatus = 0
          vim.o.signcolumn = "no"
          vim.o.guifont = "Moralerspace Argon HWNF"
        end
      end,
    })

    vim.api.nvim_create_autocmd({ "BufEnter" }, {
      pattern = "github.com_*.txt",
      callback = function()
        vim.bo.filetype = "markdown"
      end,
    })
  end,
}

return spec
