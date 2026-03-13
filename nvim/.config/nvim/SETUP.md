# Neovim Configuration — Setup & Reference

## Prerequisites

### Required
- **Neovim** >= 0.9.0 (`brew install neovim`)
- **Git** >= 2.19
- **Node.js** >= 18 + npm (for many LSP servers)
- **A Nerd Font** — required for icons (e.g. JetBrainsMono Nerd Font, FiraCode Nerd Font)
  - `brew tap homebrew/cask-fonts && brew install --cask font-jetbrains-mono-nerd-font`
- **ripgrep** — for Telescope live grep (`brew install ripgrep`)
- **fd** — for Telescope file finding (`brew install fd`)
- **make** — to build fzf native (`xcode-select --install` on macOS)

### Recommended
- **lazygit** — for the LazyGit integration (`brew install lazygit`)
- **fzf** — fuzzy finder (`brew install fzf`)
- **tree-sitter CLI** (`npm install -g tree-sitter-cli`)

---

## First Launch

1. Open Neovim: `nvim`
2. **lazy.nvim** will auto-bootstrap and install all plugins — wait for it to complete
3. Restart Neovim
4. Run `:Mason` — wait for all LSP servers to install (may take a few minutes)
5. Run `:TSUpdate` to ensure all Treesitter parsers are up-to-date

### Verify setup
```
:checkhealth
:checkhealth nvim-treesitter
:checkhealth mason
:LspInfo          (open any relevant file first)
```

---

## Claude / AI Integration

### avante.nvim (in-editor AI)
Set your Anthropic API key before launching Neovim:
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
# Add to ~/.zshrc or ~/.zprofile to persist
```

### Claude Code CLI terminal
Requires the `claude` CLI:
```bash
npm install -g @anthropic-ai/claude-code
claude auth login
```

---

## Language-Specific Notes

### C# / OmniSharp
Requires **.NET SDK**: `brew install dotnet`

### Swift / sourcekit-lsp
Requires **Xcode** to be installed (available via App Store).
The LSP is bundled with Xcode toolchain.

### Ruby
```bash
gem install ruby-lsp
```

### Python
```bash
pip install black pyright
# Or: brew install pyright
```

### Go
```bash
brew install go
go install golang.org/x/tools/gopls@latest
go install mvdan.cc/gofumpt@latest
```

### Rust
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# rust-analyzer is installed via Mason automatically
```

---

## Key Bindings Reference

**Leader key: `Space`**

### Navigation
| Key | Action |
|-----|--------|
| `<C-h/j/k/l>` | Navigate between splits |
| `<S-h>` / `<S-l>` | Previous / next buffer |
| `<C-d>` / `<C-u>` | Scroll down/up (centered) |
| `]]` / `[[` | Next / prev illuminated reference |
| `s` | Flash jump (n/x/o mode) |
| `S` | Flash treesitter jump |

### File Tree (nvim-tree)
| Key | Action |
|-----|--------|
| `<leader>e` | Toggle file tree |
| `<leader>ef` | Focus file tree |
| `<leader>er` | Refresh file tree |
| `l` (in tree) | Open file/directory |
| `h` (in tree) | Close directory |
| `v` (in tree) | Open in vertical split |

### Telescope / Fuzzy Find
| Key | Action |
|-----|--------|
| `<leader><leader>` or `<leader>ff` | Find files |
| `<leader>/` or `<leader>fg` | Live grep (search text) |
| `<leader>fb` | Find open buffers |
| `<leader>fr` | Recent files |
| `<leader>fs` | Grep string under cursor |
| `<leader>fd` | Diagnostics |
| `<leader>fo` | Document symbols |
| `<leader>fw` | Workspace symbols |
| `<leader>gc` | Git commits |
| `<leader>gb` | Git branches |
| `<leader>gs` | Git status |

### LSP
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Go to references |
| `gi` | Go to implementation |
| `gt` | Go to type definition |
| `K` | Hover documentation |
| `<leader>ls` | Signature help |
| `<leader>ca` | Code action |
| `<leader>rn` | Rename symbol |
| `<leader>lf` | Format buffer |
| `<leader>li` | LSP info |
| `<leader>lR` | Restart LSP |
| `[d` / `]d` | Prev / next diagnostic |
| `<leader>e` | Open diagnostic float |

### Git (gitsigns)
| Key | Action |
|-----|--------|
| `]h` / `[h` | Next / prev hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hS` | Stage buffer |
| `<leader>hu` | Undo stage hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line |
| `<leader>hB` | Toggle line blame |
| `<leader>hd` | Diff this |
| `<leader>gg` | Open LazyGit |
| `<leader>gd` | Open DiffView |

### Diagnostics / Code
| Key | Action |
|-----|--------|
| `<leader>xx` | Toggle Trouble diagnostics |
| `<leader>xX` | Buffer diagnostics |
| `<leader>xL` | Location list |
| `<leader>xQ` | Quickfix list |
| `<leader>cs` | Symbols (Trouble) |
| `<leader>co` | Outline toggle |
| `]t` / `[t` | Next / prev TODO |
| `<leader>fT` | TODOs in Telescope |

### Claude / AI
| Key | Action |
|-----|--------|
| `<leader>aa` | Avante: Ask AI |
| `<leader>ae` | Avante: Edit selection |
| `<leader>ar` | Avante: Refresh |
| `<leader>at` | Avante: Toggle panel |
| `<leader>ac` | Open Claude Code CLI terminal |
| `<leader>af` | Claude with current file |

### Terminal
| Key | Action |
|-----|--------|
| `<C-\>` | Toggle floating terminal |

### Windows / Splits
| Key | Action |
|-----|--------|
| `<leader>sv` | Split vertical |
| `<leader>sh` | Split horizontal |
| `<leader>se` | Equalize splits |
| `<leader>sx` | Close split |

### Buffers
| Key | Action |
|-----|--------|
| `<leader>bd` | Delete buffer (smart) |
| `<leader>bp` | Pin buffer |

### Misc
| Key | Action |
|-----|--------|
| `<leader>nh` | Clear search highlight |
| `<leader>w` | Save file |
| `<leader>z` | Zen Mode |
| `<leader>sr` | Spectre: find & replace |
| `<leader>mp` | Markdown preview |
| `<leader>cm` | Open Mason |
| `<C-space>` | Expand treesitter selection |
| `<BS>` | Shrink treesitter selection |

### Text Objects (treesitter)
| Key | Action |
|-----|--------|
| `af` / `if` | Around / inner function |
| `ac` / `ic` | Around / inner class |
| `aa` / `ia` | Around / inner argument |
| `ab` / `ib` | Around / inner block |
| `]f` / `[f` | Next / prev function start |
| `]c` / `[c` | Next / prev class start |

### Snippets (LuaSnip)
| Key | Action |
|-----|--------|
| `<Tab>` | Expand snippet / jump to next node |
| `<S-Tab>` | Jump to prev node |

### Completion (nvim-cmp)
| Key | Action |
|-----|--------|
| `<C-Space>` | Trigger completion |
| `<C-j>` / `<C-k>` | Next / prev item |
| `<CR>` | Confirm selection |
| `<C-e>` | Abort completion |
| `<C-b>` / `<C-f>` | Scroll docs |

### Autopairs
| Key | Action |
|-----|--------|
| `<M-e>` | Fast wrap — wrap next expression |

### Session
| Key | Action |
|-----|--------|
| `<leader>qs` | Restore session |
| `<leader>ql` | Restore last session |
| `<leader>qd` | Don't save session |

---

## Plugin Manager (lazy.nvim)
Run `:Lazy` to open the plugin manager UI.

| Key (in Lazy UI) | Action |
|------------------|--------|
| `U` | Update all plugins |
| `I` | Install missing plugins |
| `X` | Clean unused plugins |
| `S` | Sync (update + clean) |
| `?` | Help |

---

## LSP Servers Installed via Mason

| Language | Server |
|----------|--------|
| TypeScript/JavaScript | typescript-language-server |
| Rust | rust-analyzer |
| C# | OmniSharp |
| Python | Pyright |
| Lua | lua-language-server |
| TOML | taplo |
| Markdown | marksman |
| Bash/Zsh | bash-language-server |
| Dockerfile | dockerfile-language-server |
| Go | gopls |
| JSON | json-lsp |
| Ruby | ruby-lsp |
| XML | lemminx |
| YAML | yaml-language-server |
| HTML | html-lsp |
| CSS | css-lsp |

---

## File Structure
```
~/.config/nvim/          (symlink → ~/dotfiles/nvim/.config/nvim)
├── init.lua             # Entry point, lazy.nvim bootstrap
├── SETUP.md             # This file
└── lua/
    ├── core/
    │   ├── options.lua  # vim.opt settings
    │   ├── keymaps.lua  # global keymaps
    │   └── autocmds.lua # autocommands
    └── plugins/
        ├── claude.lua       # Claude/AI integration
        ├── colorscheme.lua  # Catppuccin theme
        ├── completion.lua   # nvim-cmp + LuaSnip
        ├── devicons.lua     # nvim-web-devicons
        ├── editor.lua       # autopairs, illuminate, indent-blankline, etc.
        ├── extras.lua       # language extras, markdown, terminal, etc.
        ├── filetree.lua     # nvim-tree
        ├── git.lua          # gitsigns, lazygit, diffview
        ├── lsp.lua          # Mason + nvim-lspconfig + conform
        ├── statusline.lua   # lualine + bufferline
        └── treesitter.lua   # syntax highlighting & text objects
```
