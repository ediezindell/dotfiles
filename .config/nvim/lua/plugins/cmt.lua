---@type LazySpec
local spec = {
  {
    "yuki-yano/cmt.nvim",
    event = "LspAttach",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    keys = {
      { "gc",  "<Plug>(cmt:line:toggle)",                     mode = { "n", "x" } },
      { "gw",  "<Plug>(cmt:block:toggle)",                    mode = { "n", "x" } },
      { "gC",  "<Plug>(cmt:line:toggle:with-blank)",          mode = { "n", "x" } },
      { "gW",  "<Plug>(cmt:block:toggle:with-blank)",         mode = { "n", "x" } },
      { "gcc", "<Plug>(cmt:line:toggle:current)",             mode = "n" },
      { "gCC", "<Plug>(cmt:line:toggle:with-blank:current)",  mode = "n" },
      { "gww", "<Plug>(cmt:block:toggle:current)",            mode = "n" },
      { "gWW", "<Plug>(cmt:block:toggle:with-blank:current)", mode = "n" },
      { "gco", "<Plug>(cmt:open-below-comment)",              mode = "n" },
      { "gcO", "<Plug>(cmt:open-above-comment)",              mode = "n" },
    },
  },
}

return spec
