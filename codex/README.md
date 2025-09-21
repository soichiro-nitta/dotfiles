# Codex CLI 設定（テンプレート）

このフォルダは Codex CLI（オープンソースのエージェント型コーディング CLI）向けのテンプレートです。環境に `~/.codex` を作成し、基本ポリシー（日本語応答・安全設定）を配備します。

## 置き場所

- 実体: `~/.codex/`
- 本リポジトリの内容は `install.sh` 実行時に同期されます。

## 含まれるもの

- `AGENTS.md`: グローバル方針（このリポジトリの AGENTS.md と同一）
- `profile.default.json`: CLI ランチ用の推奨プロファイル（参考用）

## 使い方

- `./scripts/setup-codex.sh` で Codex CLI をインストール（未導入時）
- `codex-run` コマンド（`~/.local/bin`）で日本語・安全既定の起動ラッパを利用

> 注: Codex CLI の仕様変更に備え、`profile.default.json` はドキュメント的なテンプレートです。CLI 側のオプションがある場合は `codex-run` の引数に反映してください。

