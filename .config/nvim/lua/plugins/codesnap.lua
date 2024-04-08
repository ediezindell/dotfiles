return {
  "mistricky/codesnap.nvim",
  build = "make",
  config = function()
    require("codesnap").setup({
      mac_window_bar = false,
      title = "codesnap",
      code_font_family = "Moralerspace Argon HWNF",
      -- watermark_font_family = "Moralerspace Neon HWNF",
      breadcrumbs_separator = "/",
      has_breadcrumbs = true,
      bg_theme = "default",
      watermark = "yoshiaki.inoue",
      save_path = "~/Pictures",
    })
  end,
  cmd = { "CodeSnap", "CodeSnapSave" },
}
