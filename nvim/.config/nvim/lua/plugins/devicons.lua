return {
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
    opts = {
      override = {},
      default = true,
      strict = true,
      override_by_filename = {
        [".gitignore"] = { icon = "", color = "#f1502f", name = "Gitignore" },
        [".gitconfig"] = { icon = "", color = "#f1502f", name = "Gitconfig" },
        ["Dockerfile"] = { icon = "󰡨", color = "#0db7ed", name = "Dockerfile" },
        ["docker-compose.yml"] = { icon = "󰡨", color = "#0db7ed", name = "DockerCompose" },
        ["docker-compose.yaml"] = { icon = "󰡨", color = "#0db7ed", name = "DockerComposeYaml" },
        [".editorconfig"] = { icon = "", color = "#fff2a7", name = "EditorConfig" },
        ["go.mod"] = { icon = "", color = "#00acd7", name = "GoMod" },
        ["go.sum"] = { icon = "", color = "#00acd7", name = "GoSum" },
        ["Cargo.toml"] = { icon = "", color = "#dea584", name = "CargoToml" },
        ["Cargo.lock"] = { icon = "", color = "#dea584", name = "CargoLock" },
      },
      override_by_extension = {
        ["log"] = { icon = "", color = "#81e043", name = "Log" },
        ["toml"] = { icon = "", color = "#9c4221", name = "Toml" },
        ["lock"] = { icon = "", color = "#bbbbbb", name = "Lock" },
      },
    },
  },
}
