#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")" && pwd)"

echo "[dotfiles] ホーム → リポジトリ へ同期します ($repo_dir)"

sync_one() {
  local src=$1
  local dst=$2
  if [ -e "$src" ]; then
    mkdir -p "$(dirname "$dst")"
    cp -a "$src" "$dst"
    echo "  sync: $src -> $dst"
  fi
}

# 基本ファイル
sync_one "$HOME/.zshrc"          "$repo_dir/shell/zshrc"
sync_one "$HOME/.tmux.conf"       "$repo_dir/shell/tmux.conf"
sync_one "$HOME/.gitconfig"       "$repo_dir/git/gitconfig"
sync_one "$HOME/.gitignore_global" "$repo_dir/git/gitignore_global"
sync_one "$HOME/completion-for-pnpm.zsh" "$repo_dir/completion-for-pnpm.zsh"

# Cursor
cursor_user="$HOME/Library/Application Support/Cursor/User"
if [ -d "$cursor_user" ]; then
  mkdir -p "$repo_dir/cursor/User"
  [ -f "$cursor_user/settings.json" ]   && cp -a "$cursor_user/settings.json"   "$repo_dir/cursor/User/"
  [ -f "$cursor_user/keybindings.json" ]&& cp -a "$cursor_user/keybindings.json" "$repo_dir/cursor/User/"
  [ -d "$cursor_user/snippets" ]        && rsync -a --delete "$cursor_user/snippets/" "$repo_dir/cursor/User/snippets/"
  echo "  sync: Cursor User settings"
fi

# Zed
if [ -d "$HOME/.config/zed" ]; then
  mkdir -p "$repo_dir/zed"
  for f in settings.json keymap.json tasks.json; do
    [ -f "$HOME/.config/zed/$f" ] && cp -a "$HOME/.config/zed/$f" "$repo_dir/zed/"
  done
  echo "  sync: Zed settings"
fi

# WezTerm (~/.config/wezterm と ~/.wezterm.lua の両対応)
mkdir -p "$repo_dir/wezterm"
if [ -d "$HOME/.config/wezterm" ]; then
  rsync -a --delete "$HOME/.config/wezterm/" "$repo_dir/wezterm/"
  echo "  sync: WezTerm config dir"
fi
if [ -f "$HOME/.wezterm.lua" ]; then
  cp -a "$HOME/.wezterm.lua" "$repo_dir/wezterm/wezterm.lua"
  echo "  sync: ~/.wezterm.lua"
fi

# Ghostty
if [ -d "$HOME/.config/ghostty" ]; then
  mkdir -p "$repo_dir/ghostty"
  rsync -a --delete "$HOME/.config/ghostty/" "$repo_dir/ghostty/"
  echo "  sync: Ghostty"
fi

# Karabiner
if [ -d "$HOME/.config/karabiner" ]; then
  mkdir -p "$repo_dir/karabiner"
  rsync -a --delete "$HOME/.config/karabiner/" "$repo_dir/karabiner/"
  echo "  sync: Karabiner"
fi

# tig
if [ -d "$HOME/.config/tig" ]; then
  mkdir -p "$repo_dir/tig"
  rsync -a --delete "$HOME/.config/tig/" "$repo_dir/tig/"
  echo "  sync: tig"
fi

# Codex: ~/.codex（機密除外）
if [ -d "$HOME/.codex" ]; then
  mkdir -p "$repo_dir/codex"
  rsync -a \
    --exclude 'auth.json' \
    --exclude 'history.jsonl' \
    --exclude 'internal_storage.json' \
    --exclude 'log/' \
    --exclude 'sessions/' \
    --exclude 'version.json' \
    "$HOME/.codex/" "$repo_dir/codex/"
  echo "  sync: ~/.codex (safe)"
fi

echo "[dotfiles] 同期完了"
