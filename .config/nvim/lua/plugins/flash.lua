-- Mでジャンプ
return {
  "folke/flash.nvim",
  -- event = "VeryLazy",
  opts = {},
  keys = {
    {
      "M",
      mode = { "n", "x", "o" },
      function()
        require("flash").jump()
      end,
      desc = "Flash",
    },
    {
      "<c-c>",
      mode = { "c" },
      function()
        require("flash").toggle()
      end,
      desc = "Toggle Flash Search",
    },
  },
}
