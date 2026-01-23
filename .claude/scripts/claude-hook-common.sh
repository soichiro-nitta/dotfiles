#!/bin/bash
# Claude Hook共通関数ライブラリ（統一版）
# 基本機能と拡張機能を統合

# ===== 基本的な共通関数 =====

# 再入防止チェック関数
# 使用例: check_and_set_hook_suppress || exit 0
check_and_set_hook_suppress() {
    if [[ "${CLAUDE_HOOK_SUPPRESS:-}" = "1" ]]; then
        return 1  # 既に実行中
    fi
    export CLAUDE_HOOK_SUPPRESS=1
    return 0  # 実行可能
}

# Claude CLIを安全に呼び出す関数（タイムアウト付き）
# 使用例: result=$(call_claude_safely "プロンプト" 10)
call_claude_safely() {
    local prompt="$1"
    local timeout="${2:-10}"  # デフォルト10秒
    local caller_name="${3:-hook}"  # 呼び出し元の名前
    
    # Hook内から再帰的に呼ばれるのを防ぐ
    if [[ "${CLAUDE_HOOK_SUPPRESS:-}" != "1" ]]; then
        export CLAUDE_HOOK_SUPPRESS=1
    fi
    
    # Claude CLI実行開始をログに記録
    local claude_log_file="/tmp/claude_cli_execution_${CLAUDE_SESSION_ID:-unknown}_$(date +%s).log"
    {
        echo "=== Claude CLI Execution Log ==="
        echo "Time: $(date)"
        echo "Caller: $caller_name"
        echo "Session ID: ${CLAUDE_SESSION_ID:-unknown}"
        echo "Timeout: ${timeout}s"
        echo "Model: sonnet"
        echo "Prompt length: ${#prompt} chars"
        echo ""
        echo "Prompt:"
        echo "---"
        echo "$prompt" | head -100  # 最初の100行のみログに記録
        [ $(echo "$prompt" | wc -l) -gt 100 ] && echo "[... truncated ...]"
        echo "---"
        echo ""
        echo "Execution started at: $(date +%H:%M:%S)"
    } > "$claude_log_file"
    
    # リアルタイムログ出力（Claude Codeコンソール用）
    if [ "${CLAUDE_CODE_REALTIME_LOG:-1}" = "1" ]; then
        echo "[Claude CLI] Executing from: $caller_name" >&2
        echo "[Claude CLI] Model: sonnet, Timeout: ${timeout}s" >&2
        echo "[Claude CLI] Prompt preview: $(echo "$prompt" | head -1 | cut -c1-60)..." >&2
    fi
    
    # Claude実行（タイムアウト付き）
    local result=""
    local start_time=$(date +%s)
    
    if command -v gtimeout >/dev/null 2>&1; then
        # GNU timeout (macOSでHomebrewでインストールした場合)
        result=$(CLAUDE_HOOK_SUPPRESS=1 printf '%s\n' "$prompt" | \
                 CLAUDE_HOOK_SUPPRESS=1 gtimeout "$timeout" claude -p --model sonnet --output-format text 2>&1)
    elif command -v timeout >/dev/null 2>&1; then
        # 標準のtimeout
        result=$(CLAUDE_HOOK_SUPPRESS=1 printf '%s\n' "$prompt" | \
                 CLAUDE_HOOK_SUPPRESS=1 timeout "$timeout" claude -p --model sonnet --output-format text 2>&1)
    else
        # timeoutコマンドがない場合は直接実行（推奨されない）
        result=$(CLAUDE_HOOK_SUPPRESS=1 printf '%s\n' "$prompt" | \
                 CLAUDE_HOOK_SUPPRESS=1 claude -p --model sonnet --output-format text 2>&1)
    fi
    
    local exit_code=$?
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # 実行結果をログに追記
    {
        echo "Execution completed at: $(date +%H:%M:%S)"
        echo "Duration: ${duration}s"
        echo "Exit code: $exit_code"
        echo ""
        echo "Response:"
        echo "---"
        echo "$result" | head -200  # 最初の200行のみログに記録
        [ $(echo "$result" | wc -l) -gt 200 ] && echo "[... truncated ...]"
        echo "---"
    } >> "$claude_log_file"
    
    # Claude Codeが読めるようにセッションディレクトリにもコピー
    if [ -n "${CLAUDE_SESSION_ID:-}" ]; then
        local project_hash=$(pwd | md5 -q | cut -c1-8 2>/dev/null || pwd | md5sum | cut -c1-8)
        local session_dir="/tmp/claude_session_${CLAUDE_SESSION_ID}_${project_hash}"
        if [ -d "$session_dir" ]; then
            cp "$claude_log_file" "$session_dir/claude_cli_$(date +%s).log"
        fi
    fi
    
    # デバッグログにも記録
    debug_log_v2 "Claude CLI executed: duration=${duration}s, exit_code=$exit_code, log=$claude_log_file" "" "$caller_name"
    
    # リアルタイムログ出力（実行完了）
    if [ "${CLAUDE_CODE_REALTIME_LOG:-1}" = "1" ]; then
        echo "[Claude CLI] Completed in ${duration}s (exit code: $exit_code)" >&2
        if [ $exit_code -eq 0 ]; then
            echo "[Claude CLI] Response preview: $(echo "$result" | head -1 | cut -c1-80)..." >&2
        fi
    fi
    
    # タイムアウトの場合
    if [ $exit_code -eq 124 ] || [ $exit_code -eq 143 ]; then
        echo "[タイムアウト]" >&2
        debug_log_v2 "Claude CLI timed out after ${timeout}s" "" "$caller_name"
        if [ "${CLAUDE_CODE_REALTIME_LOG:-1}" = "1" ]; then
            echo "[Claude CLI] ERROR: Timed out after ${timeout}s" >&2
        fi
        return 1
    fi
    
    # その他のエラー
    if [ $exit_code -ne 0 ]; then
        echo "[エラー: $exit_code]" >&2
        if [ "${CLAUDE_CODE_REALTIME_LOG:-1}" = "1" ]; then
            echo "[Claude CLI] ERROR: Command failed with exit code $exit_code" >&2
        fi
        return 1
    fi
    
    # 正常終了
    echo "$result"
    return 0
}

# 進捗通知付きでClaude実行（長時間タスク用）
call_claude_safely_with_progress() {
    local prompt="$1"
    local timeout="${2:-30}"  # デフォルト30秒
    local progress_message="${3:-処理中...}"
    
    # 進捗通知
    : ${CLAUDE_NOTIFICATIONS_ENABLED:=false}
    if [ "$CLAUDE_NOTIFICATIONS_ENABLED" = "true" ]; then
        osascript -e "display notification \"$progress_message\" with title \"Claude Code\"" 2>/dev/null || true
    fi
    
    # Claude実行
    call_claude_safely "$prompt" "$timeout"
}

# Hook入力情報を解析する関数
# 使用例: HOOK_INPUT=$(parse_hook_input)
parse_hook_input() {
    # Hook入力を読み込む
    local input=$(cat || true)
    
    # 入力をそのまま返す（環境変数の設定は呼び出し側で行う）
    echo "$input"
}

# トランスクリプトパスを解決（フォールバック処理付き）
resolve_transcript_path() {
    # 既にパスが設定されている場合は何もしない
    if [ -n "${CLAUDE_TRANSCRIPT_PATH:-}" ] && [ -f "$CLAUDE_TRANSCRIPT_PATH" ]; then
        return 0
    fi
    
    # セッションIDがある場合は推測を試みる
    if [ -n "${CLAUDE_SESSION_ID:-}" ]; then
        # 一般的なトランスクリプトの場所を探す
        local possible_paths=(
            "/tmp/claude_transcript_${CLAUDE_SESSION_ID}.jsonl"
            "${HOME}/.claude/transcripts/${CLAUDE_SESSION_ID}.jsonl"
            "/var/tmp/claude_${CLAUDE_SESSION_ID}.jsonl"
        )
        
        for path in "${possible_paths[@]}"; do
            if [ -f "$path" ]; then
                export CLAUDE_TRANSCRIPT_PATH="$path"
                debug_log "Transcript path resolved: $path"
                return 0
            fi
        done
    fi
    
    # 最新のトランスクリプトを探す（フォールバック）
    local latest_transcript=$(find /tmp -name "claude_transcript_*.jsonl" -type f -mtime -1 2>/dev/null | head -1)
    if [ -n "$latest_transcript" ] && [ -f "$latest_transcript" ]; then
        export CLAUDE_TRANSCRIPT_PATH="$latest_transcript"
        debug_log "Using latest transcript: $latest_transcript"
        return 0
    fi
    
    debug_log "No transcript path found"
    return 1
}

# デバッグログ関数
debug_log() {
    local message="$1"
    local log_file="${2:-/tmp/hook_debug.log}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$log_file"
}

# セッションベースのロック管理
acquire_session_lock() {
    local lock_name="${1:-hook}"
    local session_id="${CLAUDE_SESSION_ID:-default}"
    local lock_file="/tmp/claude_${lock_name}_${session_id}.lock"
    
    # ロックファイルが既に存在する場合
    if [ -f "$lock_file" ]; then
        local pid=$(cat "$lock_file" 2>/dev/null)
        # プロセスが実際に存在するかチェック
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            return 1  # ロック取得失敗
        fi
        # 古いロックファイルを削除
        rm -f "$lock_file"
    fi
    
    # 新しいロックファイルを作成
    echo $$ > "$lock_file"
    
    # スクリプト終了時にロックファイルを削除
    trap "rm -f '$lock_file'" EXIT
    
    return 0  # ロック取得成功
}

# ===== 拡張機能（改善された再入防止機構） =====

# セッション＋Hook名＋ツール名での再入防止（より細かい制御）
# 使用例: check_hook_running "dynamic-notification" "Bash" || exit 0
check_hook_running() {
    local hook_name="${1:-default}"
    local tool_name="${2:-any}"
    local session_id="${CLAUDE_SESSION_ID:-global}"
    
    # セッション＋Hook名＋ツール名で一意の識別子を生成
    local lock_id=$(echo "${session_id}_${hook_name}_${tool_name}" | md5 -q 2>/dev/null || echo "${session_id}_${hook_name}_${tool_name}" | md5sum | cut -d' ' -f1)
    local lock_file="/tmp/claude_hook_${lock_id}.lock"
    
    # アトミックなロックファイル作成を試みる
    if ! (set -C; echo $$ > "$lock_file") 2>/dev/null; then
        # ロックファイルが既に存在する場合
        if [ -f "$lock_file" ]; then
            local old_pid=$(cat "$lock_file" 2>/dev/null)
            # プロセスが実際に存在するかチェック
            if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
                debug_log "Hook $hook_name/$tool_name is already running (PID: $old_pid)"
                return 0  # 既に実行中
            else
                # 古いロックファイルを削除して再試行
                rm -f "$lock_file"
                if (set -C; echo $$ > "$lock_file") 2>/dev/null; then
                    trap "rm -f '$lock_file'" EXIT
                    return 1  # 実行可能
                fi
            fi
        fi
        return 0  # 既に実行中
    fi
    
    # ロック取得成功
    trap "rm -f '$lock_file'" EXIT
    return 1  # 実行可能
}

# 改善されたPIDファイルベースの再入防止
# タイムスタンプ付きで古いロックを自動クリーンアップ
acquire_pid_lock_v2() {
    local hook_name="${1:-hook}"
    local session_id="${CLAUDE_SESSION_ID:-global}"
    local max_age_minutes="${2:-60}"  # デフォルト60分で古いロックを削除
    
    # MD5ハッシュでファイル名を短縮
    local lock_id=$(echo "${session_id}_${hook_name}" | md5 -q 2>/dev/null || echo "${session_id}_${hook_name}" | md5sum | cut -d' ' -f1)
    local pid_file="/tmp/claude_hook_${lock_id}.pid"
    
    # 古いロックファイルの自動削除
    find /tmp -name "claude_hook_*.pid" -mmin +${max_age_minutes} -delete 2>/dev/null
    
    # アトミックなロック取得
    local temp_file="${pid_file}.$$"
    echo $$ > "$temp_file"
    
    if ln "$temp_file" "$pid_file" 2>/dev/null; then
        # ロック取得成功
        rm -f "$temp_file"
        trap "rm -f '$pid_file'" EXIT
        return 0
    else
        # 既存のPIDファイルをチェック
        if [ -f "$pid_file" ]; then
            local old_pid=$(cat "$pid_file" 2>/dev/null)
            if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
                rm -f "$temp_file"
                debug_log "Hook $hook_name is already running (PID: $old_pid)"
                return 1  # 既に実行中
            else
                # 古いPIDファイルを削除して再試行
                rm -f "$pid_file"
                if ln "$temp_file" "$pid_file" 2>/dev/null; then
                    rm -f "$temp_file"
                    trap "rm -f '$pid_file'" EXIT
                    return 0
                fi
            fi
        fi
        rm -f "$temp_file"
        return 1  # ロック取得失敗
    fi
}

# グローバル再入防止の改善版
# CLAUDE_HOOK_SUPPRESSを使用するが、Hook名でスコープを分ける
check_and_set_hook_suppress_scoped() {
    local hook_name="${1:-default}"
    
    # Hook名ごとの環境変数
    local hook_name_upper=$(echo "$hook_name" | tr '[:lower:]' '[:upper:]')  # Bash 3.2互換の大文字変換
    local env_var="CLAUDE_HOOK_SUPPRESS_${hook_name_upper}"
    env_var=$(echo "$env_var" | tr -cd '[:alnum:]_')
    
    # Bash 3.2互換の間接参照（set -u対応）
    if eval "[[ \"\${$env_var:-}\" = \"1\" ]]"; then
        return 1  # 既に実行中
    fi
    
    eval "export $env_var=1"
    
    # プロセス終了時にフラグをクリア
    trap "unset $env_var" EXIT
    
    return 0  # 実行可能
}

# 非同期Claude CLI呼び出し（改善版）
# より安全なプロセス管理とタイムアウト処理
call_claude_async_v2() {
    local prompt="$1"
    local callback_script="${2:-}"  # 結果を処理するコールバックスクリプト
    local timeout="${3:-10}"
    
    # 一意の結果ファイル
    local timestamp=$(date +%s%N)
    local result_file="/tmp/claude_result_${timestamp}_$$.txt"
    
    # バックグラウンドで実行
    (
        # 完全に独立したプロセスとして実行
        setsid bash -c "
            # プロセス優先度を下げる
            renice +15 $$ >/dev/null 2>&1
            
            # Claude実行
            if command -v gtimeout >/dev/null 2>&1; then
                CLAUDE_HOOK_SUPPRESS=1 printf '%s\n' '$prompt' | \
                CLAUDE_HOOK_SUPPRESS=1 gtimeout $timeout claude -p --model sonnet --output-format text > '$result_file' 2>&1
            else
                CLAUDE_HOOK_SUPPRESS=1 printf '%s\n' '$prompt' | \
                CLAUDE_HOOK_SUPPRESS=1 timeout $timeout claude -p --model sonnet --output-format text > '$result_file' 2>&1
            fi
            
            # コールバック実行（指定された場合）
            if [ -n '$callback_script' ] && [ -f '$callback_script' ]; then
                '$callback_script' '$result_file'
            fi
            
            # 結果ファイルを削除
            rm -f '$result_file'
        " </dev/null >/dev/null 2>&1 &
    ) &
    
    local pid=$!
    debug_log "Started async Claude process (PID: $pid)"
    echo "$pid"
}

# デバッグログ関数の改善版（タイムスタンプとセッションID付き）
debug_log_v2() {
    local message="$1"
    local log_file="${2:-/tmp/hook_debug.log}"
    local session_id="${CLAUDE_SESSION_ID:-unknown}"
    local hook_name="${3:-}"
    
    local log_entry="[$(date '+%Y-%m-%d %H:%M:%S')] [Session: ${session_id:0:8}]"
    [ -n "$hook_name" ] && log_entry="$log_entry [$hook_name]"
    log_entry="$log_entry $message"
    
    echo "$log_entry" >> "$log_file"
}

# ロックファイルのクリーンアップ関数
cleanup_old_locks() {
    local max_age_minutes="${1:-60}"
    
    # 古いロックファイルを削除
    find /tmp -name "claude_hook_*.lock" -mmin +${max_age_minutes} -delete 2>/dev/null
    find /tmp -name "claude_hook_*.pid" -mmin +${max_age_minutes} -delete 2>/dev/null
    
    # 古い結果ファイルも削除
    find /tmp -name "claude_result_*.txt" -mmin +30 -delete 2>/dev/null
    
    debug_log_v2 "Cleaned up old lock files"
}

# 改善されたHook入力解析関数（環境変数を正しく設定）
# 使用例: parse_hook_input_v2
parse_hook_input_v2() {
    # Hook入力を読み込む（グローバル変数に保存）
    HOOK_INPUT=$(cat || true)
    
    # グローバル変数として設定
    if [ -n "$HOOK_INPUT" ]; then
        CLAUDE_SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // empty' 2>/dev/null || true)
        CLAUDE_TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || true)
        CLAUDE_HOOK_EVENT=$(echo "$HOOK_INPUT" | jq -r '.hook_event_name // empty' 2>/dev/null || true)
        CLAUDE_TOOL_NAME=$(echo "$HOOK_INPUT" | jq -r '.tool_name // empty' 2>/dev/null || true)
        
        # エクスポート（サブプロセスでも使用可能に）
        export CLAUDE_SESSION_ID
        export CLAUDE_TRANSCRIPT_PATH
        export CLAUDE_HOOK_EVENT
        export CLAUDE_TOOL_NAME
    fi
}

# すべての関数をエクスポート
export -f check_and_set_hook_suppress
export -f call_claude_safely
export -f call_claude_safely_with_progress
export -f parse_hook_input
export -f resolve_transcript_path
export -f debug_log
export -f acquire_session_lock
export -f check_hook_running
export -f acquire_pid_lock_v2
export -f check_and_set_hook_suppress_scoped
export -f call_claude_async_v2
export -f debug_log_v2
export -f cleanup_old_locks
export -f parse_hook_input_v2
