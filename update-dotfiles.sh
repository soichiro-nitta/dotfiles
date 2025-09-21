#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")" && pwd)"
cd "$repo_dir"

echo "[dotfiles] マシン設定 → リポジトリへ同期し、コミット/プッシュします"

"$repo_dir/sync-dotfiles.sh"

branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)"
msg="chore(dotfiles): マシン設定から同期 $(date +%Y-%m-%d_%H:%M)"

git add -A
if git diff --cached --quiet; then
  echo "[dotfiles] 変更なし。プッシュはスキップ"
  exit 0
fi

git commit -m "$msg"
git pull --rebase --autostash || true
git push -u origin "$branch"

echo "[dotfiles] 同期してプッシュ完了 ($branch)"

