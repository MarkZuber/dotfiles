-- neotest adapters for the languages whose lang.* extra doesn't bring one
-- (python, go and rust extras already register theirs).
return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "marilari88/neotest-vitest",
      "nvim-neotest/neotest-jest",
      "alfaix/neotest-gtest",
    },
    opts = {
      adapters = {
        ["neotest-vitest"] = {},
        ["neotest-jest"] = {},
        -- GoogleTest. Run :ConfigureGtest once per project to point it at the test executables.
        ["neotest-gtest"] = {},
      },
    },
  },
}
