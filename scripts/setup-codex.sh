#!/usr/bin/env bash
set -euo pipefail

echo "[Codex] セットアップを開始します"

# 可能なインストール経路を順に試行し、失敗しても続行（最後にガイダンス）
installed=false

if command -v codex >/dev/null 2>&1; then
  echo "[Codex] 既にインストール済み: $(command -v codex)"
  installed=true
fi

if [ "$installed" = false ]; then
  if command -v brew >/dev/null 2>&1; then
    echo "[Codex] Homebrew 経由のパッケージを探索します…"
    set +e
    brew install codex 2>/dev/null
    status=$?
    set -e
    if [ $status -eq 0 ] && command -v codex >/dev/null 2>&1; then
      echo "[Codex] Homebrew でインストールしました"
      installed=true
    fi
  fi
fi

if [ "$installed" = false ]; then
  if command -v pipx >/dev/null 2>&1; then
    echo "[Codex] pipx 経由のインストールを試みます…"
    set +e
    pipx install codex-cli 2>/dev/null
    status=$?
    set -e
    if [ $status -eq 0 ] && command -v codex >/dev/null 2>&1; then
      echo "[Codex] pipx でインストールしました"
      installed=true
    fi
  fi
fi

if [ "$installed" = false ]; then
  cat <<'EOS'
[Codex] 自動インストールに失敗/未対応でした。以下のいずれかを実施してください:
  1) Homebrew に tap/Formula がある場合:  brew install codex
  2) pipx 提供パッケージがある場合:    pipx install codex-cli
  3) 公式 README に従い手動インストール
EOS
else
  echo "[Codex] セットアップ完了"
fi

