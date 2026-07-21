# Soichiro の Dotfiles（macOS）

macOS用の開発環境設定一式です。シェル、Git、各種エディタ、ターミナル、Codexの起動補助をまとめて導入できます。

## 🚀 特徴

- Git 操作を fzf で対話的に（`g`+スペース、`gco`/`ga`/`gsh` など）
- ディレクトリ/ファイル移動の高速化（`z`、`cd`/`v` の fzf 連携）
- `p`/`ps` で npm/pnpm スクリプトを対話実行
- Cursor/Zed/WezTerm/Ghostty/tig/Neovim の設定同梱
- Codex CLIの導入補助と起動ラッパ

## 📦 構成

```
dotfiles/
├── shell/               # Zsh/Tmux
├── git/                 # Git 設定
├── cursor/              # Cursor 設定
├── vscode/              # VSCode 設定（UI のみ）
├── karabiner/           # Karabiner-Elements
├── nvim/                # Neovim
├── wezterm/             # WezTerm
├── ghostty/             # Ghostty
├── tig/                 # tig
├── zed/                 # Zed
├── scripts/
│   ├── setup-codex.sh   # Codex 本体の導入試行
│   └── codex-run        # Codex 起動ラッパ (~/.local/bin)
├── sync-dotfiles.sh     # ホーム→リポジトリ同期
├── push-dotfiles.sh     # コミット/プッシュ補助
└── install.sh           # 一括インストーラ
```

## 🔧 セットアップ

### クイックインストール

```bash
git clone https://github.com/soichiro-nitta/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
source ~/.zshrc   # もしくはターミナル再起動
```

### 手動インストール（任意）

1) 依存導入（未導入なら）
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install fzf z ripgrep bat tmux neovim gh jq tree htop tldr
$(brew --prefix)/opt/fzf/install --all --no-update-rc
```

2) 設定ファイルの配置
```bash
cp shell/zshrc ~/.zshrc
cp git/gitconfig ~/.gitconfig
cp git/gitignore_global ~/.gitignore_global
```

3) Cursor を使う場合
```bash
mkdir -p ~/Library/Application\ Support/Cursor/User
cp cursor/User/*.json ~/Library/Application\ Support/Cursor/User/
```

4) VSCode（UI 設定のみを配備）

```bash
mkdir -p ~/Library/Application\ Support/Code/User
cp vscode/User/settings.json "~/Library/Application Support/Code/User/settings.json"
```

### 推奨拡張（extensions.txt）

- 一覧: `vscode/extensions.txt`
- `./install.sh` 実行時に `code` コマンドがあれば自動で導入されます。
- 手動で入れる場合:

```bash
while read -r ext; do [[ -z "$ext" || "$ext" =~ ^# ]] || code --install-extension "$ext"; done < vscode/extensions.txt
```

## 同期ポリシー（マシンが正）

- このリポジトリは「マシン上の設定を集約したバックアップ」が正です。
- `dotsync` で HOME から本リポジトリへ同期（コピー）します。
- `dotpush` でコミット/プッシュします。
- 一括実行は `dotupdate`（`dotsync` → `dotpush`）を使用します。

エイリアス（`~/.zshrc`）

```
alias dotsync="~/Work/dotfiles/sync-dotfiles.sh"
alias dotpush="~/Work/dotfiles/push-dotfiles.sh"
alias dotupdate="~/Work/dotfiles/update-dotfiles.sh"
```

`~/.codex`はこのrepositoryで同期しません。個人ルール、個人スキル、復旧用設定はprivateな`soichiro-nitta/codex-env-backup`を正本にします。

### Codex を使う（任意）

```bash
# codex-run は install.sh で自動配備済み
# 本体未導入なら導入を試行
./scripts/setup-codex.sh

# 個人ルール・スキル・安全な設定を復旧
git clone https://github.com/soichiro-nitta/codex-env-backup.git ~/Work/codex-env-backup
~/Work/codex-env-backup/scripts/restore-codex-env.sh --apply

# 日本語・安全既定で起動
codex-run
```

## 運用ガイド（今回の改善点を反映）

- 役割の統一: 「マシンが正」。dotfiles は収集物（バックアップ）として管理します。
- 日常運用: 変更後は `dotupdate` ひとつで同期→コミット→プッシュまで完了。
- 局所運用: `dotsync` だけでリポジトリへ取り込み、内容確認後に `dotpush`。
- 同期対象（抜粋）: `~/.zshrc`、`~/.tmux.conf`、`~/.gitconfig`、`~/.gitignore_global`、Cursor/Zed/VSCode/WezTerm/Ghostty/Karabiner/tigのユーザー設定。
- Codex環境は`codex-env-backup`、Cursorなどのキャッシュ類は各除外設定を正本にする。

### `c` エイリアス方針

- `c` は Codex CLI を起動します（Cursor Agent ではありません）。
- 定義: `alias c='codex --yolo -s workspace-write'`
- 確認: `type -a c` / `alias c` で Codex を指していることを確認。
- 変更したい場合は `shell/zshrc` を編集し、`dotupdate` で反映。

### 新規マシンの初期化手順（ブートストラップ）

1) dotfiles を取得してインストール

```
git clone https://github.com/soichiro-nitta/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh && source ~/.zshrc
```

2) Codex を使う場合（未導入時）

```
./scripts/setup-codex.sh
git clone https://github.com/soichiro-nitta/codex-env-backup.git ~/Work/codex-env-backup
~/Work/codex-env-backup/scripts/restore-codex-env.sh --apply
```

3) エイリアス確認

```
type -a c
```

### 機密を誤ってコミットした場合の対処

- 速やかに該当ファイルを削除・`.gitignore` へ追記し、履歴を書き換えます。
- 例）BFG Repo-Cleaner を使う（参考）:

```
# 例: 大域で機密パターンを除去
java -jar bfg.jar --delete-files auth.json --delete-files history.jsonl .
git reflog expire --expire=now --all && git gc --prune=now --aggressive
git push --force
```

（必要ならトークンのローテートも実施してください。）

## 📥 install.sh が配置するファイル

常時
- `shell/zshrc` → `~/.zshrc`
- `shell/tmux.conf` → `~/.tmux.conf`
- `git/gitconfig` → `~/.gitconfig`
- `git/gitignore_global` → `~/.gitignore_global`
- `completion-for-pnpm.zsh` → `~/completion-for-pnpm.zsh`
- `scripts/codex-run` → `~/.local/bin/codex-run`（実行権限付与）
- `~/.fzf.zsh`（未存在時に生成）

条件付き
- Cursor: `~/Library/Application Support/Cursor/User/` に settings/keybindings/snippets
- VSCode: `~/Library/Application Support/Code/User/` に `settings.json`（グローバルは UI のみ。フォーマッタ/リンタは各プロジェクトで管理）
- Karabiner: `~/.config/karabiner/` に設定/assets（ディレクトリがある場合）
- Neovim: `~/.config/nvim/` に一式（`nvim` がある場合）
- WezTerm: `~/.config/wezterm/` に `.lua`（WezTerm あり or ディレクトリあり）
- Ghostty: `~/.config/ghostty/` に `config`（Ghostty あり or ディレクトリあり）
- tig: `~/.config/tig/` に `config`（`tig` がある場合）
- Zed: `~/.config/zed/` に `settings.json`/`keymap.json`/`tasks.json`（Zed あり or ディレクトリあり）

作成されるディレクトリ
- `~/.config`, `~/.local/bin`, `~/.npm-global`

## ⌨️ 主なエイリアス/ショートカット

- Git: `g`+スペース（コマンド選択）、`gco`/`ga`/`gsh`、`gpsf`（安全な強制 push）
- 移動: `z`（頻出ディレクトリ）、`cd`/`v`（fzf 選択）、`Ctrl+Z`（z 起動）
- スクリプト: `p`（pnpm 対話実行）、`ps`（pnpm 専用）
- Codex: `codex-run`
- 同期/Push: `dotsync`、`dotpush`

## 🔄 更新・同期

```bash
cd ~/dotfiles
git pull
./install.sh

# ホーム側の変更を取り込んでから push
~/Work/dotfiles/sync-dotfiles.sh
~/Work/dotfiles/push-dotfiles.sh "chore(dotfiles): 設定を同期"
```

## 🆘 トラブルシューティング

- fzf が効かない: `$(brew --prefix)/opt/fzf/install --all --no-update-rc`
- z が効かない: `brew reinstall z && source ~/.zshrc`
- エイリアス反映: `source ~/.zshrc`
- 権限エラー: `chmod +x ~/dotfiles/install.sh`

## ライセンス/貢献

個人利用の範囲で自由にどうぞ。改善案は Issue / PR 歓迎です。

注: 本設定は macOS 最適化です。他 OS では一部機能が動かない場合があります。
