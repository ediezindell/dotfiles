---@type LazySpec
local spec = {
  {
    "jdrupal-dev/drupal.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    opts = {
      services_cmp_trigger_character = "@",
      get_drush_executable = function(current_dir)
        -- You can use current_dir if you have different ways of
        -- executing drush across your Drupal projects.
        return "ddev drush"
      end,
    },
  },
}

return spec
