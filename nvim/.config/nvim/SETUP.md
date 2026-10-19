# Neovim config

[LazyVim](https://lazyvim.org) on lazy.nvim. LazyVim supplies the plugins, options and
keymaps; this directory only picks extras and overrides a few things.

| File | What it does |
| --- | --- |
| `lazyvim.json` | the enabled extras (language support, debugger, tests, AI). Toggle them with `:LazyExtras` and the file is rewritten |
| `lua/config/options.lua` | options on top of [LazyVim's](https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua), the Python LSP choice, filetype rules |
| `lua/config/keymaps.lua` | the few habits kept from the old config (`<leader>rn`, `<leader>lf`, centred scrolling) |
| `lua/plugins/lsp.lua` | per-server settings (gopls, basedpyright, rust-analyzer via rustaceanvim), extra servers and parsers |
| `lua/plugins/ai.lua` | avante.nvim on `<leader>A` (Claude Code itself is the `ai.claudecode` extra on `<leader>a`) |
| `lua/plugins/editor.lua` | colorscheme, nvim-surround, better-escape, diffview, small filetype plugins |
| `lazy-lock.json` | exact plugin versions. It's committed: `:Lazy update` changes it, `:Lazy restore` goes back to it |

Keys are in the [cheatsheet](../../../CHEATSHEET.md#neovim).

## Requirements

- Neovim 0.11 or newer
- A Nerd Font in the terminal (Ghostty uses ComicShanns Nerd Font)
- `git`, `rg`, `fd`, `lazygit`, `tree-sitter-cli`, a C compiler (`xcode-select --install`)
- Language toolchains, which the servers call into. `scripts/setup/mac_config.sh` installs all of them:
  - **TypeScript/JavaScript:** node (mise)
  - **Python:** python (mise), uv
  - **Go:** go (mise)
  - **Rust:** rustup, plus `rustup component add rust-analyzer clippy rustfmt`. rustaceanvim
    uses the toolchain's rust-analyzer rather than Mason's, so it always matches the compiler.
  - **C/C++:** clangd from Xcode's command line tools (or Mason). clangd needs a
    `compile_commands.json` at the project root to know the include paths and flags:
    - CMake: `cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && ln -s build/compile_commands.json .`
    - Make or other builds: `bear -- make` (`brew install bear`)
  - **C#:** the .NET SDK (`brew install dotnet`) for the dotnet extra's servers and formatters
  - **avante.nvim:** `ANTHROPIC_API_KEY` in the environment (`~/.zshrc_local.zsh`)

## First launch

1. `nvim`. lazy.nvim installs every plugin; wait for it, then restart.
2. Mason installs language servers, formatters, linters and debug adapters in the background
   the first time a file of that language opens. `:Mason` shows progress.
3. `:checkhealth lazyvim` and `:checkhealth vim.lsp` should show no errors.

## Language support

| Language | Server | Format | Lint | Debug | Tests |
| --- | --- | --- | --- | --- | --- |
| TypeScript / JS | vtsls | prettier | eslint | js-debug-adapter | neotest (via extra) |
| Python | basedpyright + ruff | ruff | ruff | debugpy | neotest-python |
| Rust | rust-analyzer (rustaceanvim) | rustfmt | clippy | codelldb | rustaceanvim / neotest |
| C / C++ | clangd (+ clang-tidy) | clang-format | clang-tidy | codelldb | — |
| Go | gopls | gofumpt + goimports | golangci-lint | delve | neotest-golang |

Also enabled: C#, Ruby, JSON/YAML (with SchemaStore), TOML, Markdown, Docker, SQL, CMake, Bash, HTML/CSS, XML.

## Trying a change without touching your real config

```sh
ln -sfn ~/some/checkout/nvim/.config/nvim ~/.config/nvim-test
NVIM_APPNAME=nvim-test nvim
```

That instance keeps its plugins and Mason tools under `~/.local/share/nvim-test`, separate from the real one.
