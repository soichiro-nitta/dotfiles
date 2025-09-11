#!/bin/bash

# Quick setup script for new machines
# This script quickly clones and sets up the dotfiles

set -e

echo "🚀 Quick Dotfiles Setup"
echo ""

# Clone the repository
if [[ ! -d "$HOME/dotfiles" ]]; then
    echo "📥 Cloning dotfiles repository..."
    git clone https://github.com/soichiro-nitta/dotfiles.git "$HOME/dotfiles"
else
    echo "📂 Dotfiles directory already exists"
fi

# Run the installation
cd "$HOME/dotfiles"
echo "🔧 Running installation..."
./install.sh

echo ""
echo "✅ Setup complete! Please restart your terminal."