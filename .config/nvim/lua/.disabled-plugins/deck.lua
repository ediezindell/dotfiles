--- fuzzy finder
---@type LazySpec
local spec = {
  "hrsh7th/nvim-deck",
  event = "BufEnter",
  config = function()
    local deck = require("deck")

    -- Apply pre-defined easy settings.
    -- For manual configuration, refer to the code in `deck/easy.lua`.
    require("deck.easy").setup()

    -- Set up buffer-specific key mappings for nvim-deck.
    vim.api.nvim_create_autocmd("User", {
      pattern = "DeckStart",
      callback = function(e)
        local ctx = e.data.ctx --[[@as deck.Context]]
        ctx.keymap("n", "<Esc>", function()
          ctx.set_preview_mode(false)
        end)
        ctx.keymap("n", "<Tab>", deck.action_mapping("choose_action"))
        ctx.keymap("n", "<C-l>", deck.action_mapping("refresh"))
        ctx.keymap("n", "i", deck.action_mapping("prompt"))
        ctx.keymap("n", "a", deck.action_mapping("prompt"))
        ctx.keymap("n", "@", deck.action_mapping("toggle_select"))
        ctx.keymap("n", "*", deck.action_mapping("toggle_select_all"))
        ctx.keymap("n", "p", deck.action_mapping("toggle_preview_mode"))
        ctx.keymap("n", "d", deck.action_mapping("delete"))
        ctx.keymap("n", "<CR>", deck.action_mapping("default"))
        ctx.keymap("n", "o", deck.action_mapping("open"))
        ctx.keymap("n", "O", deck.action_mapping("open_keep"))
        ctx.keymap("n", "s", deck.action_mapping("open_split"))
        ctx.keymap("n", "v", deck.action_mapping("open_vsplit"))
        ctx.keymap("n", "N", deck.action_mapping("create"))
        ctx.keymap("n", "<C-u>", deck.action_mapping("scroll_preview_up"))
        ctx.keymap("n", "<C-d>", deck.action_mapping("scroll_preview_down"))

        -- If you want to start the filter by default, call ctx.prompt() here
        ctx.prompt()
      end,
    })

    -- Example key bindings for launching nvim-deck sources. (These mapping required `deck.easy` calls.)
    vim.keymap.set(
      "n",
      "<space>FF",
      "<Cmd>Deck files<CR>",
      { desc = "nvim-deck: Show recent files, buffers, and more" }
    )
    vim.keymap.set("n", "<space>FR", "<Cmd>Deck grep<CR>", { desc = "nvim-deck: Start grep search" })
    vim.keymap.set("n", "<space>FG", "<Cmd>Deck git<CR>", { desc = "nvim-deck: Open git launcher" })
    vim.keymap.set("n", "<space>FH", "<Cmd>Deck helpgrep<CR>", { desc = "nvim-deck: Live grep all help tags" })

    -- Show the latest deck context.
    vim.keymap.set("n", "<space>;", function()
      local ctx = require("deck").get_history()[1]
      if ctx then
        ctx.show()
      end
    end)

    -- Do default action on next item.
    vim.keymap.set("n", "<Leader>n", function()
      local ctx = require("deck").get_history()[1]
      if ctx then
        ctx.set_cursor(ctx.get_cursor() + 1)
        ctx.do_action("default")
      end
    end)
  end,
}

return spec
