# Codex 設定のリリース手順

Codex CLI 向けの設定ファイル（`AGENTS.md` や `config.toml` など）を GitHub 上の dotfiles リポジトリに安全に保管するための手順です。`sync-dotfiles.sh` を前提にしています。

## 1. 管理対象ファイル

|区分|ファイル|理由|
|---|---|---|
|保持|`AGENTS.md`（リポジトリ直下）/ `codex/AGENTS.md`|グローバル方針。前者は dotfiles 用、後者は Codex 配布用として同期|
|保持|`config.toml`|モデル/ツール設定。Codex CLI の挙動に直結|
|保持|`profile.default.json`, `README.md`|ドキュメントおよびひな型|
|除外|`auth.json`, `history.jsonl`, `internal_storage.json`, `log/`, `sessions/`, `version.json`|機密・端末固有データ。`sync-dotfiles.sh` でも除外済み|

> 追加の設定ファイルを管理したい場合は、機密情報を含まないことを確認したうえで上表を更新してください。

## 2. 重複チェック

1. `rg --files -g 'AGENTS.md'` を実行し、ルートの `AGENTS.md` と `codex/AGENTS.md` 以外に複製が無いことを確認
2. `git status --short codex` で意図しないファイルがトラッキングされていないか確認
3. もし `codex/` 配下に除外対象が存在したら `git rm` で削除し、`.gitignore` に追記する

## 3. リリース手順

1. `~/.codex` 側で AGENT/設定を更新
2. `~/Work/dotfiles` で `./sync-dotfiles.sh` を実行（`codex/` も同期される）
3. `git status` → `git diff codex/` で変更内容を確認
4. 問題なければ `git commit -am "chore: update codex config"` などでコミット
5. `git push origin main`

## 4. 運用メモ

- `config.toml` を手作業で編集した場合も、最終的には `sync-dotfiles.sh` で整合を取る
- `AGENTS.md` の構成を変更したときは、各プロジェクトの `AGENTS.md` と内容が乖離していないか（`rg --files -g 'AGENTS.md' ~/Work`）で確認
- 初回リリース時にリポジトリへ残ってしまった `auth.json` などは即削除し、GitHub 上でも履歴の秘匿化を検討する
