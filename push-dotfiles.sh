#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")" && pwd)"
cd "$repo_dir"

branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)"

git add -A
if git diff --cached --quiet; then
  echo "[dotfiles] 変更はありません"
  exit 0
fi

msg=${1:-"chore(dotfiles): 設定を更新"}
git commit -m "$msg"
git pull --rebase --autostash || true
git push -u origin "$branch"
echo "[dotfiles] プッシュ完了 ($branch)"

