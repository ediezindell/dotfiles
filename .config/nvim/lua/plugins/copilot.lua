---@type LazySpec
local spec = {
  enabled = true,
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    {
      "github/copilot.vim",
      init = function()
        vim.g.copilot_no_tab_map = true
        vim.g.copilot_filetypes = {
          gitcommit = true,
        }
      end,
      keys = {
        {
          "<C-e>",
          'copilot#Accept("")',
          mode = "i",
          expr = true,
          replace_keycodes = false,
          desc = "Accept Copilot suggestion",
        },
      },
    },
    { "nvim-lua/plenary.nvim", branch = "master" },
  },
  build = "make tiktoken",
  opts = {
    prompts = require("ojo"),
    system_prompt = require("ojo").OjoInstructions.system_prompt,
  },
  lazy = false,
  init = function()
    -- お転婆お嬢様 CopilotChat キーマッピング
    NormalKeymap("<space>cc", function()
      require("CopilotChat").open()
    end, "お転婆お嬢様とチャット開始")

    NormalKeymap("<space>cq", function()
      local input = vim.fn.input("お嬢様への質問: ")
      if input ~= "" then
        require("CopilotChat").ask(input)
      end
    end, "お転婆お嬢様に質問")

    NormalKeymap("<space>ce", function()
      require("CopilotChat").ask("このコードを説明して", { selection = require("CopilotChat.select").buffer })
    end, "お転婆お嬢様にコード説明を依頼")

    NormalKeymap("<space>cr", function()
      require("CopilotChat").ask(
        "このコードをレビューして",
        { selection = require("CopilotChat.select").buffer }
      )
    end, "お転婆お嬢様にコードレビューを依頼")

    NormalKeymap("<space>cf", function()
      require("CopilotChat").ask(
        "このコードのバグを修正して",
        { selection = require("CopilotChat.select").buffer }
      )
    end, "お転婆お嬢様にバグ修正を依頼")

    NormalKeymap("<space>co", function()
      require("CopilotChat").ask(
        "このコードを最適化して",
        { selection = require("CopilotChat.select").buffer }
      )
    end, "お転婆お嬢様にコード最適化を依頼")

    NormalKeymap("<space>ct", function()
      require("CopilotChat").ask(
        "このコードのテストを書いて",
        { selection = require("CopilotChat.select").buffer }
      )
    end, "お転婆お嬢様にテスト作成を依頼")

    NormalKeymap("<space>cd", function()
      require("CopilotChat").ask(
        "このコードのドキュメントを書いて",
        { selection = require("CopilotChat.select").buffer }
      )
    end, "お転婆お嬢様にドキュメント作成を依頼")

    -- 選択範囲用のキーマッピング
    VisualKeymap("<space>ce", function()
      require("CopilotChat").ask(
        "選択されたコードを説明して",
        { selection = require("CopilotChat.select").visual }
      )
    end, "選択範囲をお転婆お嬢様に説明依頼")

    VisualKeymap("<space>cr", function()
      require("CopilotChat").ask(
        "選択されたコードをレビューして",
        { selection = require("CopilotChat.select").visual }
      )
    end, "選択範囲をお転婆お嬢様にレビュー依頼")

    VisualKeymap("<space>cf", function()
      require("CopilotChat").ask(
        "選択されたコードのバグを修正して",
        { selection = require("CopilotChat.select").visual }
      )
    end, "選択範囲をお転婆お嬢様にバグ修正依頼")

    VisualKeymap("<space>co", function()
      require("CopilotChat").ask(
        "選択されたコードを最適化して",
        { selection = require("CopilotChat.select").visual }
      )
    end, "選択範囲をお転婆お嬢様に最適化依頼")

    -- チャット履歴管理
    NormalKeymap("<space>ch", function()
      require("CopilotChat").open({ window = { layout = "horizontal" } })
    end, "お転婆お嬢様チャット履歴を水平分割で開く")

    NormalKeymap("<space>cv", function()
      require("CopilotChat").open({ window = { layout = "vertical" } })
    end, "お転婆お嬢様チャット履歴を垂直分割で開く")

    NormalKeymap("<space>cx", function()
      require("CopilotChat").close()
    end, "お転婆お嬢様チャットを閉じる")

    NormalKeymap("<space>cs", function()
      require("CopilotChat").stop()
    end, "お転婆お嬢様の応答を停止")

    NormalKeymap("<space>cn", function()
      require("CopilotChat").reset()
    end, "お転婆お嬢様との会話をリセット")
  end,
}

return spec
