# gをエイリアスとして定義
alias g='git'

# g単体で実行されたときのためのZLEウィジェット
g-fzf-select() {
  local commands=(
    "add: ファイルの変更をステージング（コミット準備）する"
    "add .: 現在のディレクトリ以下の全ての変更をステージング"
    "branch: ブランチの一覧表示・作成・削除"
    "branch -d: マージ済みのブランチを安全に削除"
    "branch -D: ブランチを強制削除（マージ状態に関わらず）"
    "checkout: ブランチの切り替えやファイルの復元"
    "checkout -b: 新しいブランチを作成して同時に切り替える"
    "cherry-pick: 他のブランチから特定のコミットだけを取り込む"
    "clone: リモートリポジトリをローカルにコピー"
    "commit: ステージングした変更を記録（保存）"
    "commit -m: メッセージを直接指定してコミット"
    "commit --amend: 直前のコミットを修正（メッセージや内容を変更）"
    "diff: 変更内容の差分を表示"
    "diff --staged: ステージングされた変更の差分を表示"
    "fetch: リモートの最新情報を取得（マージはしない）"
    "fetch --all: 全てのリモートから最新情報を取得"
    "log: コミット履歴を表示"
    "log --oneline: コミット履歴を1行ずつコンパクトに表示"
    "log --graph: コミット履歴をグラフ形式で視覚的に表示"
    "merge: 別のブランチの変更を現在のブランチに統合"
    "pull: リモートの変更を取得して現在のブランチにマージ"
    "pull --rebase: リモートの変更を取得してリベース（履歴をきれいに保つ）"
    "push: ローカルの変更をリモートに送信"
    "push -u origin: 初回プッシュ時に上流ブランチを設定"
    "psf: 安全な強制プッシュ（他者の変更を上書きしない）"
    "push --force-with-lease: 安全な強制プッシュ（psfと同じ）"
    "rebase: コミット履歴を整理・再編成"
    "rebase -i: 対話的にコミット履歴を編集（結合・削除・並び替え）"
    "rebase --abort: 進行中のリベースを中止して元の状態に戻す"
    "rebase --continue: 競合解決後にリベースを続行"
    "remote -v: 登録されているリモートリポジトリの一覧とURLを表示"
    "reset: コミットを取り消す（履歴を巻き戻す）"
    "reset --soft: コミットのみ取り消し（変更はステージングに残る）"
    "reset --hard: コミットも変更も全て取り消し（危険：作業内容が消える）"
    "restore: ファイルを以前の状態に戻す"
    "restore --staged: ステージングを取り消す（addの取り消し）"
    "revert: 指定したコミットを打ち消す新しいコミットを作成"
    "show: コミットやタグの詳細情報を表示"
    "stash: 作業中の変更を一時的に退避"
    "stash pop: 退避した変更を復元して、スタッシュから削除"
    "stash list: 退避した変更の一覧を表示"
    "stash apply: 退避した変更を復元（スタッシュには残す）"
    "status: 現在の作業ツリーの状態を表示"
    "status -s: 変更状態をシンプルに表示（短縮形式）"
    "switch: ブランチを切り替える（checkoutの新しい形）"
    "tag: 特定のコミットに名前を付ける（リリースバージョンなど）"
  )
  
  local selected=$(printf '%s\n' "${commands[@]}" | \
    fzf --delimiter=': ' \
        --preview='echo "📋 git {1}" && echo "" && echo "💡 {2}"' \
        --preview-window=up:4:wrap \
        --header='🔍 Gitコマンドを選択' \
        --height=70% \
        --ansi | cut -d':' -f1)
  
  if [[ -n "$selected" ]]; then
    LBUFFER="g $selected "
    zle reset-prompt
  else
    LBUFFER="g "
    zle reset-prompt
  fi
}

# ZLEウィジェットとして登録
zle -N g-fzf-select

# gだけを入力してスペースキーを押したときに発動
bindkey -M emacs ' ' self-insert
bindkey -M viins ' ' self-insert
bindkey -M vicmd ' ' self-insert

# gの後にスペースが押されたときの処理
expand-or-complete-with-g() {
  if [[ "$LBUFFER" == "g" ]]; then
    g-fzf-select
  else
    zle self-insert
  fi
}
zle -N expand-or-complete-with-g
bindkey ' ' expand-or-complete-with-g
alias "g c"='git commit'
alias "g cm"='git commit -m'
alias "g ca"='git commit --amend'
alias "g ps"='git push'
alias "g psf"='git push --force-with-lease'
alias "g pl"='git pull'
alias "g plr"='git pull --rebase'
alias "g a"='git add'
alias "g aa"='git add .'
alias "g d"='git diff'
alias "g ds"='git diff --staged'
alias "g co"='git checkout'
alias "g cob"='git checkout -b'
alias "g br"='git branch'
alias "g st"='git status -sb'
alias "g l"='git log --oneline --graph --decorate -20'
alias "g rs"='git reset'
alias "g rsh"='git reset --hard'
alias "g rb"='git rebase'
alias "g rbi"='git rebase -i'
alias "g cp"='git cherry-pick'
alias "g sh"='git stash'
alias "g shp"='git stash pop'

# fzfを使ったインタラクティブなgit操作

# gcoでfzfを使ってブランチを選択
gco() {
  if [[ $# -eq 0 ]]; then
    # 引数なしの場合はfzfでブランチを選択
    local branch
    branch=$(git branch -a | grep -v HEAD | sed 's/.* //' | sed 's#remotes/[^/]*/##' | sort -u | \
      fzf --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" {} | head -20' \
          --preview-window right:60%:wrap \
          --header 'Select branch to checkout' \
          --height 70% \
          --ansi)
    if [[ -n "$branch" ]]; then
      git checkout "$branch"
    fi
  else
    # 引数がある場合は通常のcheckout
    git checkout "$@"
  fi
}

# gaでfzfを使ってファイルを選択してadd
ga() {
  if [[ $# -eq 0 ]]; then
    # 引数なしの場合はfzfで変更ファイルを選択
    local files
    files=$(git status -s | grep -E '^\s*[AMRD?]' | \
      fzf --multi --preview 'git diff --color=always {2} | head -200' \
          --preview-window right:60%:wrap \
          --header 'Select files to add (TAB for multi-select)' \
          --height 70% \
          --ansi | awk '{print $2}')
    if [[ -n "$files" ]]; then
      echo "$files" | xargs git add
      git status -s
    fi
  else
    # 引数がある場合は通常のadd
    git add "$@"
  fi
}

# gshでfzfを使ってstashを管理
gsh() {
  if [[ $# -eq 0 ]] && [[ $(git stash list | wc -l) -gt 0 ]]; then
    # stashがある場合は選択してapply/pop/drop
    local stash
    local action
    stash=$(git stash list | \
      fzf --preview 'git stash show -p $(echo {} | cut -d: -f1) | head -200' \
          --preview-window right:60%:wrap \
          --header 'Select stash' \
          --height 70% \
          --ansi)
    if [[ -n "$stash" ]]; then
      stash_ref=$(echo "$stash" | cut -d: -f1)
      echo "Selected: $stash"
      echo "What would you like to do?"
      echo "1) pop   - Apply and remove from stash list"
      echo "2) apply - Apply but keep in stash list" 
      echo "3) drop  - Remove without applying"
      echo "4) show  - Show details"
      read -r "action?Enter choice (1-4): "
      case "$action" in
        1) git stash pop "$stash_ref" ;;
        2) git stash apply "$stash_ref" ;;
        3) git stash drop "$stash_ref" ;;
        4) git stash show -p "$stash_ref" ;;
        *) echo "Cancelled" ;;
      esac
    fi
  else
    # 通常のstashコマンド
    git stash "$@"
  fi
}

# gcpでfzfを使ってコミットを選択してcherry-pick
gcp() {
  if [[ $# -eq 0 ]]; then
    # 引数なしの場合はfzfでコミットを選択
    local commit
    commit=$(git log --all --oneline --graph --color=always --decorate | \
      fzf --ansi --preview 'git show --color=always $(echo {} | grep -o "[a-f0-9]\{7,\}" | head -1) | head -200' \
          --preview-window right:60%:wrap \
          --header 'Select commit to cherry-pick' \
          --height 70%)
    if [[ -n "$commit" ]]; then
      local hash=$(echo "$commit" | grep -o "[a-f0-9]\{7,\}" | head -1)
      git cherry-pick "$hash"
    fi
  else
    # 引数がある場合は通常のcherry-pick
    git cherry-pick "$@"
  fi
}

# gbrでfzfを使ってブランチを管理
gbr() {
  if [[ $# -eq 0 ]]; then
    # 引数なしの場合はfzfでブランチを選択して削除
    local branch
    branch=$(git branch | grep -v '^\*' | \
      fzf --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" {} | head -20' \
          --preview-window right:60%:wrap \
          --header 'Select branch to delete (ESC to cancel)' \
          --height 70% \
          --ansi)
    if [[ -n "$branch" ]]; then
      echo "Delete branch '$branch'? (y/N): "
      read -r confirm
      if [[ "$confirm" =~ ^[Yy]$ ]]; then
        git branch -D "$branch"
      fi
    else
      # 何も選択されなかった場合は通常のbranch表示
      git branch
    fi
  else
    # 引数がある場合は通常のbranch
    git branch "$@"
  fi
}

# grsでfzfを使ってコミットを選択してreset
grs() {
  if [[ $# -eq 0 ]]; then
    # 引数なしの場合はfzfでコミットを選択
    local commit
    commit=$(git log --oneline --graph --color=always --decorate -50 | \
      fzf --ansi --preview 'git show --color=always $(echo {} | grep -o "[a-f0-9]\{7,\}" | head -1) | head -200' \
          --preview-window right:60%:wrap \
          --header 'Select commit to reset to' \
          --height 70%)
    if [[ -n "$commit" ]]; then
      local hash=$(echo "$commit" | grep -o "[a-f0-9]\{7,\}" | head -1)
      echo "Reset to $hash"
      echo "1) --soft  (keep changes staged)"
      echo "2) --mixed (keep changes unstaged) [default]"
      echo "3) --hard  (discard all changes)"
      read -r "mode?Enter choice (1-3): "
      case "$mode" in
        1) git reset --soft "$hash" ;;
        3) git reset --hard "$hash" ;;
        *) git reset --mixed "$hash" ;;
      esac
    fi
  else
    # 引数がある場合は通常のreset
    git reset "$@"
  fi
}

# gmergeでfzfを使ってブランチを選択してマージ
gmerge() {
  if [[ $# -eq 0 ]]; then
    # 引数なしの場合はfzfでブランチを選択
    local branch
    branch=$(git branch -a | grep -v HEAD | grep -v '^\*' | sed 's/.* //' | sed 's#remotes/[^/]*/##' | sort -u | \
      fzf --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" {} | head -20' \
          --preview-window right:60%:wrap \
          --header 'Select branch to merge' \
          --height 70% \
          --ansi)
    if [[ -n "$branch" ]]; then
      git merge "$branch"
    fi
  else
    # 引数がある場合は通常のmerge
    git merge "$@"
  fi
}

# gtagでfzfを使ってタグを管理
gtag() {
  if [[ $# -eq 0 ]] && [[ $(git tag | wc -l) -gt 0 ]]; then
    # タグがある場合は選択して表示/削除
    local tag
    tag=$(git tag | \
      fzf --preview 'git show --color=always {} | head -200' \
          --preview-window right:60%:wrap \
          --header 'Select tag (Enter to show, Ctrl-D to delete)' \
          --bind 'ctrl-d:execute(echo "Delete tag {}? (y/N): " && read confirm && [[ "$confirm" =~ ^[Yy]$ ]] && git tag -d {})' \
          --height 70% \
          --ansi)
    if [[ -n "$tag" ]]; then
      git show "$tag"
    fi
  else
    # 通常のtagコマンド
    git tag "$@"
  fi
}

# alias p='pnpm'  # 関数で置き換えるためコメントアウト
alias pi='pnpm install'
alias pid='pnpm install -D'
alias pd='pnpm run dev'
alias pb='pnpm run build'
alias t='tmux'
alias ta='tmux attach-session -s'
alias tn='tmux new-session -s'
alias tk='tmux kill-session -t'
# Claude with notification (using osascript)
cs() {
  claude --dangerously-skip-permissions "$@"
  local exit_code=$?
  if [ $exit_code -eq 0 ]; then
    osascript -e 'display notification "Claude Code完了" with title "WezTerm" sound name "Glass"'
  else
    osascript -e 'display notification "Claude Codeエラー終了" with title "WezTerm" sound name "Basso"'
  fi
  return $exit_code
}
# Alias c to use the same function as cs
# alias c=cs
# alias v='nvim'  # Replaced with function below

# Enable AUTO_CD - allows cd'ing into directories by typing their name
setopt AUTO_CD

# Better folder creation with auto cd
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Create multiple directories at once
mkdirs() {
  mkdir -p "$@"
}

# Safe remove (move to trash instead of delete)
trash() {
  if command -v trash > /dev/null 2>&1; then
    command trash "$@" && afplay "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/dock/drag to trash.aif" &
  else
    echo "Moving to ~/.Trash/"
    mv "$@" ~/.Trash/ && afplay "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/dock/drag to trash.aif" &
  fi
}

# Interactive rename with preview
rename() {
  if [ $# -ne 2 ]; then
    echo "Usage: rename <old_name> <new_name>"
    return 1
  fi
  mv -i "$1" "$2"
}

# Bulk rename with pattern
bulk_rename() {
  if [ $# -ne 2 ]; then
    echo "Usage: bulk_rename <pattern> <replacement>"
    echo "Example: bulk_rename '*.txt' '*.md'"
    return 1
  fi
  for f in $~1; do
    mv "$f" "${f/$1/$2}"
  done
}

# Smart directory listing
alias l='ls -lah'
alias ll='ls -lh'
alias la='ls -lAh'
alias lt='ls -lhtr'  # Sort by time, newest last
alias lS='ls -lhSr'  # Sort by size, largest last

# Quick navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Directory stack navigation
setopt AUTO_PUSHD           # Push directories onto stack automatically
setopt PUSHD_IGNORE_DUPS    # Don't push duplicate directories
setopt PUSHD_MINUS          # Use - for directory stack

alias d='dirs -v'           # Show directory stack
for index ({1..9}) alias "$index"="cd +${index}"  # Quick jump to stack position

# Git aliases
alias gr='git reset --hard HEAD'

# fzf設定
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# カスタムfzf-history-widgetを定義して即座に実行する
fzf-history-widget-execute() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
  selected=( $(fc -rl 1 | awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\*?[ \t]+/, "", cmd); if (!seen[cmd]++) print $0 }' |
    FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS $FZF_CTRL_R_OPTS --query=${(qqq)LBUFFER} +m" fzf) )
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
      zle accept-line
    fi
  fi
  zle reset-prompt
  return $ret
}
zle -N fzf-history-widget-execute

# Ctrl+Rでコマンド履歴を曖昧検索して即座に実行
bindkey '^r' fzf-history-widget-execute

# fzfのデフォルトオプション
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# 履歴検索の設定
export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window down:3:hidden:wrap
  --bind '?:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --bind 'enter:accept'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"

# zがエイリアスとして定義されている場合は解除（z.sh読み込み前に実行）
unalias z 2>/dev/null || true

# z - jump around
. /opt/homebrew/etc/profile.d/z.sh

# zエイリアスを解除して関数として再定義
unalias z 2>/dev/null || true

# zコマンドをラップして引数なしの場合はfzfを使用
z() {
  if [[ $# -eq 0 ]]; then
    # 引数なしの場合はzのデータファイルから頻度順にディレクトリを取得してfzfで選択
    local selected_dir
    selected_dir=$(
      awk -F"|" '{print $2 "|" $1}' ~/.z 2>/dev/null | \
      sort -rn | \
      awk -F"|" '{print $2}' | \
      fzf --preview 'echo "📁 $(basename {})" && echo "━━━━━━━━━━━━━━━━━━━━" && ls -1 {} 2>/dev/null | head -30 || echo "アクセスできません"' \
          --preview-window right:50%:wrap \
          --header 'Select directory to jump to' \
          --bind 'ctrl-/:toggle-preview' \
          --height 70% \
          --ansi
    )
    
    if [[ -n "$selected_dir" ]]; then
      cd "$selected_dir"
    fi
  else
    # 引数がある場合は元のzコマンド（_z）を実行
    _z "$@"
  fi
}

# カスタムプロンプト設定
# Git情報を表示する関数
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst

# Git情報の設定（モノトーン）
zstyle ':vcs_info:git:*' formats '%F{white}⎇ %F{white}%b%f '
zstyle ':vcs_info:git:*' actionformats '%F{white}⎇ %F{white}%b%f%F{8}|%a%f '
zstyle ':vcs_info:*' enable git

# Node.jsバージョンを取得する関数
node_version_info() {
  if command -v node > /dev/null 2>&1; then
    local node_version=$(node --version 2>/dev/null)
    if [[ -n $node_version ]]; then
      echo " %F{8}⬢ ${node_version}%f"
    fi
  fi
}

# 美しいプロンプト設定（モノトーン）
PROMPT='%F{white}╭─%f %F{white}%~%f ${vcs_info_msg_0_}$(node_version_info)
%F{white}╰─%f %F{8}❯%f '

# 右側プロンプト（時刻表示）
RPROMPT='%F{8}%T%f'

# package.jsonスクリプトを手軽に実行する関数
function ns() {
  if [[ -f package.json ]]; then
    local scripts=$(node -pe "
      try {
        const pkg = JSON.parse(require('fs').readFileSync('package.json', 'utf8'));
        Object.keys(pkg.scripts || {}).join('\n');
      } catch(e) {
        '';
      }
    ")
    if [[ -n $scripts ]]; then
      echo "Available scripts:"
      echo $scripts | nl
      echo -n "Select script number (or name): "
      read selection
      
      if [[ $selection =~ ^[0-9]+$ ]]; then
        local script_name=$(echo $scripts | sed -n "${selection}p")
      else
        local script_name=$selection
      fi
      
      if [[ -n $script_name ]]; then
        echo "Running: npm run $script_name"
        npm run $script_name
      fi
    else
      echo "No scripts found in package.json"
    fi
  else
    echo "package.json not found in current directory"
  fi
}

# pnpmユーザー向け（fzf版）
function ps() {
  if [[ -f package.json ]]; then
    local script
    script=$(node -pe "
      try {
        const pkg = JSON.parse(require('fs').readFileSync('package.json', 'utf8'));
        const scripts = pkg.scripts || {};
        const maxLen = Math.max(...Object.keys(scripts).map(k => k.length));
        Object.entries(scripts)
          .map(([name, cmd]) => name.padEnd(maxLen + 2) + '│ ' + cmd)
          .join('\n');
      } catch(e) {
        '';
      }
    " | fzf --delimiter='│' \
            --preview='echo "📦 Script: {1}" && echo "━━━━━━━━━━━━━━━━━━━━" && echo "{2}"' \
            --preview-window=up:3:wrap \
            --header='Select pnpm script to run' \
            --height=70% \
            --ansi | awk -F'│' '{print $1}' | xargs)
    
    if [[ -n $script ]]; then
      echo "Running: pnpm run $script"
      pnpm run $script
    fi
  else
    echo "package.json not found in current directory"
  fi
}

# iTerm2のペインタイトルに現在のディレクトリを表示
function iterm2_print_user_vars() {
  iterm2_set_user_var currentDir $(basename "$PWD")
}

# ディレクトリ変更時にiTerm2のタブ/ウィンドウタイトルを更新
function precmd() {
  # 既存のprecmd処理
  precmd_vcs_info
  
  # Claude Codeのセッション情報を取得
  local claude_topic=""
  if [[ -n "$CLAUDE_SESSION_ID" ]]; then
    # Claude Codeセッション中の場合、トピックを表示
    claude_topic="[Claude] "
  fi
  
  # iTerm2のタイトルを設定（Claude Codeトピック + ディレクトリ名）
  echo -ne "\033]0;${claude_topic}${PWD##*/}\007"
}
# 補完システムを初期化
autoload -U compinit && compinit

source ~/completion-for-pnpm.zsh

# pエイリアスを解除してから関数として定義
unalias p 2>/dev/null || true

# pコマンドをfzf対応の関数として定義
p() {
  # 引数なしの場合はpackage.jsonのscriptsをfzfで選択
  if [[ $# -eq 0 ]]; then
    if [[ -f package.json ]]; then
      local script
      script=$(node -pe "
        try {
          const pkg = JSON.parse(require('fs').readFileSync('package.json', 'utf8'));
          const scripts = pkg.scripts || {};
          const maxLen = Math.max(...Object.keys(scripts).map(k => k.length));
          Object.entries(scripts)
            .map(([name, cmd]) => name.padEnd(maxLen + 2) + '│ ' + cmd)
            .join('\n');
        } catch(e) {
          '';
        }
      " | fzf --delimiter='│' \
              --preview='echo "📦 Script: {1}" && echo "━━━━━━━━━━━━━━━━━━━━" && echo "{2}"' \
              --preview-window=up:3:wrap \
              --header='Select npm script to run' \
              --height=70% \
              --ansi | awk -F'│' '{print $1}' | xargs)
      
      if [[ -n $script ]]; then
        echo "Running: pnpm run $script"
        pnpm run $script
      fi
    else
      echo "package.json not found in current directory"
    fi
  else
    # 引数がある場合は通常のpnpmコマンドを実行
    pnpm "$@"
  fi
}

# pコマンドにもpnpmの補完を適用（引数ありの場合）
compdef p=pnpm

# pnpm/p runの後でpackage.jsonのscriptsを補完
_pnpm_run_scripts() {
  if [[ -f package.json ]]; then
    local scripts=$(node -pe "Object.keys(JSON.parse(require('fs').readFileSync('package.json', 'utf8')).scripts || {}).join(' ')" 2>/dev/null)
    if [[ -n $scripts ]]; then
      _values 'scripts' $scripts
    fi
  fi
}

# pnpm runとp runの補完を設定
compdef '_pnpm_run_scripts' 'pnpm run'
compdef '_pnpm_run_scripts' 'p run'

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

alias gg="git log --graph --pretty=format:\" %C(dim white)%ad │ %an │ %h%C(reset)%n%C(auto)%d%C(reset) %s%n\" --date=format:\"%m/%d %H:%M\" --all"
alias gg='git fetch --all --prune && git log --graph --pretty=format:" %C(dim white)%ad │ %an │ %h%C(reset)%n%C(auto)%d%C(reset) %s%n" --date=format:"%m/%d %H:%M" --all'
alias ts="tig status"

# cdコマンドをラップして引数なしの場合はfzfを使用
cd() {
  if [[ $# -eq 0 ]]; then
    # 引数なしの場合は現在のディレクトリ以下をfzfで選択
    local selected_dir
    selected_dir=$(
      find . -type d -not -path '*/\.*' 2>/dev/null | \
      fzf --preview 'echo "📁 $(basename {})" && echo "━━━━━━━━━━━━━━━━━━━━" && ls -1 {} 2>/dev/null | head -30 || echo "アクセスできません"' \
          --preview-window right:50%:wrap \
          --header 'Select directory to change to' \
          --bind 'ctrl-/:toggle-preview' \
          --height 70% \
          --ansi
    )
    
    if [[ -n "$selected_dir" ]]; then
      builtin cd "$selected_dir"
    fi
  else
    # 引数がある場合は通常のcdコマンドを実行
    builtin cd "$@"
  fi
}

# Ctrl+zでzコマンドを実行（引数なしでfzf起動）
bindkey -s '^z' 'z\n'

# vエイリアスを解除して関数として再定義
unalias v 2>/dev/null || true

# vコマンドをラップして引数なしの場合はfzfを使用
v() {
  if [[ $# -eq 0 ]]; then
    # 引数なしの場合はファイルをfzfで選択
    local selected_file
    selected_file=$(
      find . -type f -not -path '*/\.*' -not -path '*/node_modules/*' 2>/dev/null | \
      fzf --preview 'bat --style=numbers --color=always --line-range=:500 {} 2>/dev/null || cat {} 2>/dev/null' \
          --preview-window right:60%:wrap \
          --header 'Select file to edit with nvim' \
          --bind 'ctrl-/:toggle-preview' \
          --height 70% \
          --ansi
    )
    
    if [[ -n "$selected_file" ]]; then
      nvim "$selected_file"
    fi
  else
    # 引数がある場合は通常のnvimを実行
    nvim "$@"
  fi
}


# Git aliases
alias gs='git status'
alias gl='git log --oneline -10'
alias gr='git reset --hard HEAD'

# Superwhisper troubleshooting
alias sfix='~/.claude/scripts/fix-superwhisper.sh'
alias secure-input='ioreg -l -w 0 | grep SecureInput'
alias reset-clipboard='killall pboard'

# dotfiles
alias dotsync="~/Work/dotfiles/sync-dotfiles.sh"
alias dotpush="~/Work/dotfiles/push-dotfiles.sh"
export PATH=~/.npm-global/bin:$PATH

# Claude Code Slack通知設定
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/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"
export SLACK_NOTIFICATIONS_ENABLED="true"
export SLACK_CHANNEL="#general"  # 必要に応じて変更
export SLACK_USERNAME="Claude Code"
export SLACK_ICON_EMOJI=":robot_face:"

# コマンド出力後の % を非表示にする
setopt PROMPT_CR
setopt PROMPT_SP


# >>> Cursor Agent c alias >>>
# Managed by assistant: run Cursor Agent with c (auto-approve enabled)
unalias c 2>/dev/null
unset -f c 2>/dev/null
c() {
  cursor-agent --force "$@"
  local exit_code=$?
  if [ $exit_code -eq 0 ]; then
    osascript -e 'display notification "Cursor Agent完了" with title "WezTerm" sound name "Glass"'
  else
    osascript -e 'display notification "Cursor Agentエラー終了" with title "WezTerm" sound name "Basso"'
  fi
  return $exit_code
}
# <<< Cursor Agent c alias <<<

# Added by Codex CLI: ensure ~/.local/bin is in PATH
export PATH="/Users/soichiro/.local/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Library/Apple/usr/bin:/Users/soichiro/.npm-global/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/opt/homebrew/opt/fzf/bin"
export PATH="$HOME/.local/bin:$PATH"
alias gpsf="git push --force-with-lease"
