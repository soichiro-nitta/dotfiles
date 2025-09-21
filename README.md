# Soichiro's Dotfiles

My personal development environment configuration for macOS.

## 🚀 Features

### Git Enhancements
- **Interactive Git commands** (`g` + space): Browse and select Git commands with fzf
- **Safe force push** (`gpsf`): Force push with lease protection
- **Interactive operations**: Branch selection, file staging, stash management, and more
- **Beautiful Git aliases**: Enhanced log visualization and shortcuts

### Shell Productivity
- **Directory jumping** (`z`): Quick navigation to frequently used directories
- **Fuzzy file/directory selection**: Enhanced `cd`, `v` (vim), and file operations
- **Package.json script runner** (`p`): Interactive npm/pnpm script execution
- **Smart completions**: Context-aware completions for various commands

### Development Tools
- **Cursor IDE settings**: Keybindings, settings, and snippets
- **Terminal multiplexer**: tmux configuration
- **Modern CLI tools**: ripgrep, bat, fzf, and more
- **Codex CLI templates**: AGENTS.md とラッパー（日本語・安全既定）

## 📦 What's Included

```
dotfiles/
├── shell/
│   ├── zshrc              # Zsh configuration
│   └── tmux.conf          # Tmux configuration
├── git/
│   ├── gitconfig          # Git configuration
│   └── gitignore_global   # Global gitignore
├── cursor/
│   └── User/
│       ├── settings.json   # Cursor settings
│       ├── keybindings.json # Cursor keybindings
│       └── snippets/       # Code snippets
├── karabiner/
│   ├── karabiner.json     # Karabiner-Elements configuration
│   └── assets/            # Complex modifications
├── nvim/                  # Neovim configuration
├── wezterm/              # WezTerm terminal configuration
├── ghostty/              # Ghostty terminal configuration
├── tig/                  # Tig (git TUI) configuration
├── zed/                  # Zed editor configuration
│   ├── settings.json     # Editor settings
│   ├── keymap.json       # Custom keybindings
│   └── tasks.json        # Task definitions
├── scripts/
│   └── various utility scripts
├── codex/                # Codex CLI 用テンプレ（~/.codex に配備）
│   ├── README.md
│   ├── profile.default.json
│   └── config.toml       # Codex 本体設定（テンプレ）
├── scripts/
│   ├── setup-codex.sh    # Codex CLI セットアップ（必要時）
│   └── codex-run         # Codex 起動ラッパ（~/.local/bin に配備）
├── sync-dotfiles.sh      # Home → Repo へ同期
├── push-dotfiles.sh      # コミット & プッシュ補助
├── install.sh            # Automated installation script
└── README.md             # This file
```

## 🔧 Installation

### Quick Install

```bash
# Clone the repository
git clone https://github.com/[your-username]/dotfiles.git ~/dotfiles

# Run the installation script
cd ~/dotfiles
./install.sh

# Reload your shell
source ~/.zshrc
```

### Manual Installation

If you prefer to install manually or selectively:

1. **Install dependencies**:
   ```bash
   # Install Homebrew (if not installed)
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   
   # Install packages
   brew install fzf z ripgrep bat tmux neovim gh jq tree htop tldr
   
   # Install fzf key bindings
   $(brew --prefix)/opt/fzf/install
   ```

2. **Copy configuration files**:
   ```bash
   cp shell/zshrc ~/.zshrc
   cp git/gitconfig ~/.gitconfig
   cp git/gitignore_global ~/.gitignore_global
   ```

3. **Install Cursor settings** (if using Cursor):
   ```bash
   cp cursor/User/*.json ~/Library/Application\ Support/Cursor/User/
   ```

### (任意) Codex CLI のセットアップ

```bash
# テンプレ（~/.codex）と codex-run を配備
./install.sh

# Codex CLI 本体が未導入なら（可能なら）自動導入を試す
./scripts/setup-codex.sh

# ラッパーで起動（日本語・安全既定）
codex-run
```

## 📝 Key Bindings & Aliases

### Git Operations
| Command | Description |
|---------|-------------|
| `g` + space | Interactive Git command selection with fzf |
| `gpsf` | Safe force push (--force-with-lease) |
| `gco` | Interactive branch checkout |
| `ga` | Interactive file staging |
| `gsh` | Interactive stash management |
| `gg` | Beautiful git log with graph |
| `g st` | Git status (short) |
| `g cm` | Git commit with message |
| `g ps` | Git push |
| `g pl` | Git pull |

### Directory Navigation
| Command | Description |
|---------|-------------|
| `z` | Jump to frequently used directories |
| `cd` (no args) | Interactive directory selection |
| `..`, `...`, `....` | Navigate up directories |
| `l`, `ll`, `la` | Various ls formats |

### Development
| Command | Description |
|---------|-------------|
| `v` | Open files with fzf selection |
| `p` | Run npm/pnpm scripts interactively |
| `c` | Run Cursor Agent with notification |
| `cs` | Run Claude with notification |

### Utilities
| Command | Description |
|---------|-------------|
| Ctrl+R | Search command history with fzf |
| Ctrl+Z | Quick directory jump with z |

## 🔄 Updating

To update your dotfiles:

```bash
cd ~/dotfiles
git pull
./install.sh

# ホーム側で変更した設定を取り込んでから push
~/Work/dotfiles/sync-dotfiles.sh
~/Work/dotfiles/push-dotfiles.sh "chore(dotfiles): 設定を同期"
```

## 🛠 Customization

### Adding new aliases
Edit `shell/zshrc` and add your aliases in the appropriate section.

### Modifying Git aliases
Edit `git/gitconfig` to add or modify Git aliases.

### Cursor settings
Modify files in `cursor/User/` to customize Cursor IDE.

## 🆘 Troubleshooting

### fzf not working
```bash
$(brew --prefix)/opt/fzf/install
```

### z command not working
```bash
brew reinstall z
source ~/.zshrc
```

### Aliases not loading
```bash
source ~/.zshrc
```

### Permission issues
```bash
chmod +x ~/dotfiles/install.sh
```

## 📄 License

Feel free to use and modify these dotfiles for your own use.

## 🤝 Contributing

If you have suggestions or improvements, feel free to open an issue or submit a pull request!

---

**Note**: These dotfiles are optimized for macOS. Some features may not work on other operating systems.
