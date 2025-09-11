#!/bin/bash

# Dotfiles Installation Script
# Author: Soichiro Nitta
# Description: Complete environment setup for macOS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_status() { echo -e "${BLUE}==>${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}!${NC} $1"; }

echo "🚀 Starting dotfiles installation..."
echo ""

# 1. Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS only"
    exit 1
fi

# 2. Install Homebrew if not installed
if ! command -v brew &> /dev/null; then
    print_status "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    print_success "Homebrew already installed"
fi

# 3. Install required packages
print_status "Installing required packages..."

packages=(
    "fzf"        # Fuzzy finder
    "z"          # Directory jumper
    "ripgrep"    # Fast grep
    "bat"        # Better cat
    "tmux"       # Terminal multiplexer
    "neovim"     # Modern vim
    "gh"         # GitHub CLI
    "jq"         # JSON processor
    "tree"       # Directory tree
    "htop"       # Better top
    "tldr"       # Simplified man pages
)

for package in "${packages[@]}"; do
    if brew list "$package" &> /dev/null; then
        print_success "$package already installed"
    else
        print_status "Installing $package..."
        brew install "$package"
    fi
done

# 4. Install fzf key bindings
if [[ -d "$(brew --prefix)/opt/fzf" ]]; then
    print_status "Installing fzf key bindings..."
    $(brew --prefix)/opt/fzf/install --all --no-update-rc
    print_success "fzf key bindings installed"
fi

# 5. Install Node.js tools
if ! command -v pnpm &> /dev/null; then
    print_status "Installing pnpm..."
    curl -fsSL https://get.pnpm.io/install.sh | sh -
    print_success "pnpm installed"
fi

# 6. Backup existing configs
print_status "Backing up existing configurations..."
backup_dir="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"

configs_to_backup=(
    ".zshrc"
    ".gitconfig"
    ".gitignore_global"
    ".tmux.conf"
    ".vimrc"
)

for config in "${configs_to_backup[@]}"; do
    if [[ -f "$HOME/$config" ]]; then
        cp "$HOME/$config" "$backup_dir/"
        print_success "Backed up $config"
    fi
done

# 7. Create necessary directories
print_status "Creating necessary directories..."
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.npm-global"

# 8. Install dotfiles
print_status "Installing dotfiles..."

# Shell configurations
if [[ -f "shell/zshrc" ]]; then
    cp shell/zshrc "$HOME/.zshrc"
    print_success "Installed .zshrc"
fi

if [[ -f "shell/tmux.conf" ]]; then
    cp shell/tmux.conf "$HOME/.tmux.conf"
    print_success "Installed .tmux.conf"
fi

# Git configurations
if [[ -f "git/gitconfig" ]]; then
    cp git/gitconfig "$HOME/.gitconfig"
    print_success "Installed .gitconfig"
fi

if [[ -f "git/gitignore_global" ]]; then
    cp git/gitignore_global "$HOME/.gitignore_global"
    print_success "Installed .gitignore_global"
fi

# Support files
if [[ -f "completion-for-pnpm.zsh" ]]; then
    cp completion-for-pnpm.zsh "$HOME/completion-for-pnpm.zsh"
    print_success "Installed pnpm completion"
fi

# 9. Install Cursor settings
if command -v cursor &> /dev/null || [[ -d "$HOME/Library/Application Support/Cursor" ]]; then
    print_status "Installing Cursor settings..."
    cursor_dir="$HOME/Library/Application Support/Cursor"
    
    if [[ ! -d "$cursor_dir" ]]; then
        mkdir -p "$cursor_dir/User"
    fi
    
    if [[ -f "cursor/User/settings.json" ]]; then
        cp cursor/User/settings.json "$cursor_dir/User/"
        print_success "Installed Cursor settings.json"
    fi
    
    if [[ -f "cursor/User/keybindings.json" ]]; then
        cp cursor/User/keybindings.json "$cursor_dir/User/"
        print_success "Installed Cursor keybindings.json"
    fi
    
    if [[ -d "cursor/User/snippets" ]]; then
        cp -r cursor/User/snippets "$cursor_dir/User/"
        print_success "Installed Cursor snippets"
    fi
else
    print_warning "Cursor not installed, skipping Cursor settings"
fi

# 10. Install other application settings
print_status "Installing other application settings..."

# Karabiner
if [[ -d "$HOME/.config/karabiner" ]]; then
    if [[ -f "karabiner/karabiner.json" ]]; then
        cp karabiner/karabiner.json "$HOME/.config/karabiner/"
        print_success "Installed Karabiner configuration"
    fi
    if [[ -d "karabiner/assets" ]]; then
        cp -r karabiner/assets "$HOME/.config/karabiner/"
        print_success "Installed Karabiner assets"
    fi
fi

# Neovim
if command -v nvim &> /dev/null; then
    mkdir -p "$HOME/.config/nvim"
    if [[ -d "nvim" ]]; then
        cp -r nvim/* "$HOME/.config/nvim/"
        print_success "Installed Neovim configuration"
    fi
fi

# WezTerm
if command -v wezterm &> /dev/null || [[ -d "$HOME/.config/wezterm" ]]; then
    mkdir -p "$HOME/.config/wezterm"
    if [[ -d "wezterm" ]]; then
        cp wezterm/*.lua "$HOME/.config/wezterm/"
        print_success "Installed WezTerm configuration"
    fi
fi

# Ghostty
if [[ -d "$HOME/.config/ghostty" ]] || command -v ghostty &> /dev/null; then
    mkdir -p "$HOME/.config/ghostty"
    if [[ -f "ghostty/config" ]]; then
        cp ghostty/config "$HOME/.config/ghostty/"
        print_success "Installed Ghostty configuration"
    fi
fi

# tig
if command -v tig &> /dev/null; then
    mkdir -p "$HOME/.config/tig"
    if [[ -f "tig/config" ]]; then
        cp tig/config "$HOME/.config/tig/"
        print_success "Installed tig configuration"
    fi
fi

# Zed
if command -v zed &> /dev/null || [[ -d "$HOME/.config/zed" ]]; then
    mkdir -p "$HOME/.config/zed"
    if [[ -f "zed/settings.json" ]]; then
        cp zed/settings.json "$HOME/.config/zed/"
        print_success "Installed Zed settings"
    fi
    if [[ -f "zed/keymap.json" ]]; then
        cp zed/keymap.json "$HOME/.config/zed/"
        print_success "Installed Zed keymap"
    fi
    if [[ -f "zed/tasks.json" ]]; then
        cp zed/tasks.json "$HOME/.config/zed/"
        print_success "Installed Zed tasks"
    fi
fi

# 11. Setup npm global directory
print_status "Configuring npm..."
npm config set prefix "$HOME/.npm-global"
export PATH="$HOME/.npm-global/bin:$PATH"

# 12. Create .fzf.zsh if it doesn't exist
if [[ ! -f "$HOME/.fzf.zsh" ]]; then
    cat > "$HOME/.fzf.zsh" << 'EOF'
# Setup fzf
# ---------
if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/opt/homebrew/opt/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
EOF
    print_success "Created .fzf.zsh"
fi

# 13. Final setup
print_status "Running final setup..."

# Source the new configuration
if [[ -f "$HOME/.zshrc" ]]; then
    print_success "Configuration installed successfully!"
else
    print_error "Failed to install .zshrc"
fi

echo ""
print_success "🎉 Installation complete!"
echo ""
echo "📋 Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. If using iTerm2, install Shell Integration:"
echo "     iTerm2 → Install Shell Integration"
echo ""
echo "🔧 Useful commands:"
echo "  - g [space]  : Interactive Git command selection"
echo "  - gpsf       : Safe force push"
echo "  - z          : Jump to frequently used directories"
echo "  - v          : Open files with fzf selection"
echo ""
echo "📁 Your old configs are backed up in: $backup_dir"