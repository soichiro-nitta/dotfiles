# Soichiro の Dotfiles（macOS）

macOS 用の開発環境設定一式です。シェル、Git、各種エディタ/ターミナル、Codex のテンプレまでまとめて導入できます。

## 🚀 特徴

- Git 操作を fzf で対話的に（`g`+スペース、`gco`/`ga`/`gsh` など）
- ディレクトリ/ファイル移動の高速化（`z`、`cd`/`v` の fzf 連携）
- `p`/`ps` で npm/pnpm スクリプトを対話実行
- Cursor/Zed/WezTerm/Ghostty/tig/Neovim の設定同梱
- Codex CLI 用テンプレ（AGENTS.md、config.toml、起動ラッパ）

## 📦 構成

```
dotfiles/
├── shell/               # Zsh/Tmux
├── git/                 # Git 設定
├── cursor/              # Cursor 設定
├── karabiner/           # Karabiner-Elements
├── nvim/                # Neovim
├── wezterm/             # WezTerm
├── ghostty/             # Ghostty
├── tig/                 # tig
├── zed/                 # Zed
├── codex/               # Codex テンプレ (~/.codex)
│   ├── README.md
│   ├── profile.default.json
│   └── config.toml
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

安全対策：`~/.codex` は機密を除外して同期します（`auth.json`/`history.jsonl`/`internal_storage.json`/`log/`/`sessions/`/`version.json`）。

### Codex を使う（任意）

```bash
# テンプレ（~/.codex）と codex-run は install.sh で自動配備済み
# 本体未導入なら導入を試行
./scripts/setup-codex.sh

# 日本語・安全既定で起動
codex-run
```

## 📥 install.sh が配置するファイル

常時
- `shell/zshrc` → `~/.zshrc`
- `shell/tmux.conf` → `~/.tmux.conf`
- `git/gitconfig` → `~/.gitconfig`
- `git/gitignore_global` → `~/.gitignore_global`
- `completion-for-pnpm.zsh` → `~/completion-for-pnpm.zsh`
- `AGENTS.md` → `~/.codex/AGENTS.md`
- `codex/config.toml` → `~/.codex/config.toml`
- `codex/profile.default.json` → `~/.codex/profile.default.json`
- `codex/README.md` → `~/.codex/README.md`
- `scripts/codex-run` → `~/.local/bin/codex-run`（実行権限付与）
- `~/.fzf.zsh`（未存在時に生成）

条件付き
- Cursor: `~/Library/Application Support/Cursor/User/` に settings/keybindings/snippets
- Karabiner: `~/.config/karabiner/` に設定/assets（ディレクトリがある場合）
- Neovim: `~/.config/nvim/` に一式（`nvim` がある場合）
- WezTerm: `~/.config/wezterm/` に `.lua`（WezTerm あり or ディレクトリあり）
- Ghostty: `~/.config/ghostty/` に `config`（Ghostty あり or ディレクトリあり）
- tig: `~/.config/tig/` に `config`（`tig` がある場合）
- Zed: `~/.config/zed/` に `settings.json`/`keymap.json`/`tasks.json`（Zed あり or ディレクトリあり）

作成されるディレクトリ
- `~/.config`, `~/.local/bin`, `~/.npm-global`, `~/.codex`

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
