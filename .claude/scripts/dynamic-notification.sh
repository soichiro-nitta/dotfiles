#!/bin/bash
# 動的通知スクリプト（改善された再入防止機構付き）
set -euo pipefail

# 改善された共通関数を読み込む
source ~/.claude/scripts/claude-hook-common.sh

# 古いロックファイルをクリーンアップ
cleanup_old_locks 60

# Hook入力を解析（v2を使用して環境変数を正しく設定）
parse_hook_input_v2

# set -uエラーを防ぐため、未定義の場合のみデフォルト値を設定
: ${CLAUDE_SESSION_ID:=}
: ${CLAUDE_TRANSCRIPT_PATH:=}
: ${CLAUDE_HOOK_EVENT:=}
: ${HOOK_INPUT:=}
: ${CLAUDE_NOTIFICATIONS_ENABLED:=false}
: ${CLAUDE_NOTIFICATION_SOUND_ENABLED:=false}
: ${CLAUDE_SPEECH_ENABLED:=false}

# 改善された再入防止チェック（Hook名でスコープ分け）
check_and_set_hook_suppress_scoped "dynamic_notification" || {
    debug_log_v2 "dynamic-notification already running, skipping" "" "dynamic-notification"
    exit 0
}

# PIDベースのロックも取得（二重保証）
acquire_pid_lock_v2 "dynamic_notification" 60 || {
    debug_log_v2 "Failed to acquire PID lock" "" "dynamic-notification"
    exit 0
}

# デバッグログ開始
debug_log_v2 "=== Hook開始 ===" "" "dynamic-notification"
debug_log_v2 "Session: $CLAUDE_SESSION_ID" "" "dynamic-notification"
debug_log_v2 "Event: $CLAUDE_HOOK_EVENT" "" "dynamic-notification"

# トランスクリプトパスを解決（プロジェクト固有のパスも探す）
resolve_transcript_path_extended() {
    # 既にパスが設定されている場合は何もしない
    if [ -n "${CLAUDE_TRANSCRIPT_PATH:-}" ] && [ -f "$CLAUDE_TRANSCRIPT_PATH" ]; then
        debug_log_v2 "Using existing transcript path: $CLAUDE_TRANSCRIPT_PATH" "" "dynamic-notification"
        return 0
    fi
    
    # まず標準の解決を試みる
    resolve_transcript_path
    
    # それでも見つからない場合、プロジェクト固有のパスを探す
    if [ -z "${CLAUDE_TRANSCRIPT_PATH:-}" ] || [ ! -f "$CLAUDE_TRANSCRIPT_PATH" ]; then
        # プロジェクトパスのハッシュを生成
        local project_hash=$(pwd | sed 's/\//-/g')
        local transcript_dir="$HOME/.claude/projects/$project_hash"
        
        debug_log_v2 "Looking for transcript in project dir: $transcript_dir" "" "dynamic-notification"
        
        if [ -d "$transcript_dir" ]; then
            # セッションIDで検索
            if [ -n "${CLAUDE_SESSION_ID:-}" ]; then
                local session_file="$transcript_dir/${CLAUDE_SESSION_ID}.jsonl"
                if [ -f "$session_file" ]; then
                    export CLAUDE_TRANSCRIPT_PATH="$session_file"
                    debug_log_v2 "Found transcript by session ID: $session_file" "" "dynamic-notification"
                    return 0
                fi
            fi
            
            # 最新のトランスクリプトを使用
            local latest_transcript=$(ls -t "$transcript_dir"/*.jsonl 2>/dev/null | head -1)
            if [ -n "$latest_transcript" ] && [ -f "$latest_transcript" ]; then
                export CLAUDE_TRANSCRIPT_PATH="$latest_transcript"
                debug_log_v2 "Using latest transcript: $latest_transcript" "" "dynamic-notification"
                return 0
            fi
        fi
    fi
    
    if [ -z "${CLAUDE_TRANSCRIPT_PATH:-}" ] || [ ! -f "$CLAUDE_TRANSCRIPT_PATH" ]; then
        debug_log_v2 "No transcript path found" "" "dynamic-notification"
        return 1
    fi
    
    return 0
}

# トランスクリプトパスを解決
resolve_transcript_path_extended

# Slack設定を読み込む
source ~/.claude/scripts/slack-config.sh 2>/dev/null || true

# 作業内容を生成（会話要約を優先）
generate_message() {
    # 会話の要約を試みる
    if [ -n "$CLAUDE_TRANSCRIPT_PATH" ] && [ -f "$CLAUDE_TRANSCRIPT_PATH" ]; then
        debug_log_v2 "Generating summary from transcript" "" "dynamic-notification"
        
        # 会話ログから最近のメッセージを抽出
        local recent_messages=$(tail -n 500 "$CLAUDE_TRANSCRIPT_PATH" 2>/dev/null | \
            jq -r 'select(.type=="user" or .type=="assistant") | 
            select(.message.content | type=="array") |
            select(.message.content[0].text or .message.content[0].content) |
            if .message.role=="user" then 
                "ユーザー: " + ((.message.content[0].text // .message.content[0].content // "") | tostring | .[0:100])
            else 
                "Claude: " + ((.message.content[0].text // "") | tostring | .[0:100])
            end' 2>/dev/null | \
            grep -v "^$" | \
            grep -v "^Caveat: The messages below were generated" | \
            grep -v "^The user has closed" | \
            tail -n 20)
        
        if [ -n "$recent_messages" ]; then
            local prompt="以下はClaude Codeでの会話ログです。
$recent_messages

完了した作業内容を15文字以内で1行で答えてください。
「〜を完了」「〜を実装」「〜を修正」の形式で。
例: ReactHook実装完了"
            
            # タイムアウトを短縮（10秒）
            local summary=$(call_claude_safely "$prompt" 10)
            
            if [ $? -eq 0 ] && [ -n "$summary" ]; then
                echo "$summary" | head -1
                return
            fi
        fi
    fi
    
    # フォールバック
    echo "セッションを終了しました"
}

# 読み上げ用の詳細なメッセージを生成
generate_detailed_speech_message() {
    local short_message="$1"
    
    # 会話の要約を試みる
    if [ -n "$CLAUDE_TRANSCRIPT_PATH" ] && [ -f "$CLAUDE_TRANSCRIPT_PATH" ]; then
        # 会話ログから最近のメッセージを抽出（より多くのコンテキスト）
        local recent_messages=$(tail -n 800 "$CLAUDE_TRANSCRIPT_PATH" 2>/dev/null | \
            jq -r 'select(.type=="user" or .type=="assistant") | 
            select(.message.content | type=="array") |
            select(.message.content[0].text or .message.content[0].content) |
            if .message.role=="user" then 
                "ユーザー: " + ((.message.content[0].text // .message.content[0].content // "") | tostring | .[0:200])
            else 
                "Claude: " + ((.message.content[0].text // "") | tostring | .[0:200])
            end' 2>/dev/null | grep -v "^$" | tail -n 30)
        
        if [ -n "$recent_messages" ]; then
            local prompt="以下はClaude Codeでの会話ログです。
$recent_messages

この作業セッションで何を行ったか、読み上げ用の説明文を生成してください。
以下の要件に従ってください：

1. 最大50文字以内で、自然な日本語で説明
2. 技術的な詳細を含めて具体的に説明
3. 「〜を修正しました」「〜を実装しました」「〜を改善しました」の形式
4. ファイル名や技術用語は分かりやすい日本語に変換

例：
- 「コメント機能のグラデーション表示エラーを修正し、未使用定数を削除しました」
- 「Hookの通知設定を変更し、ファイル編集時のみ通知するよう改善しました」
- 「型チェック機能をNext.js開発サーバー起動時のみ動作するよう最適化しました」

出力は説明文のみを1行で。"
            
            # タイムアウトを短縮（10秒）
            local detailed_message=$(call_claude_safely "$prompt" 10)
            
            if [ $? -eq 0 ] && [ -n "$detailed_message" ]; then
                echo "$detailed_message" | head -1
                return
            fi
        fi
    fi
    
    # フォールバック（短いメッセージをそのまま使用）
    echo "$short_message"
}

# 最初のユーザープロンプトを取得
get_first_user_prompt() {
    local transcript_path="$1"
    
    if [ -z "$transcript_path" ] || [ ! -f "$transcript_path" ]; then
        debug_log_v2 "No transcript path provided or file doesn't exist" "" "dynamic-notification"
        return 1
    fi
    
    # 会話ログから最初の有効なユーザーメッセージを抽出
    # content が文字列の場合と配列の場合の両方に対応
    # command-name, Caveat, 画像などを除外
    local first_prompt=$(cat "$transcript_path" 2>/dev/null | \
        jq -r 'select(.type=="user") | 
        if .message.content | type == "string" then
            .message.content
        elif .message.content | type == "array" then
            # 配列の場合、各要素をチェック
            .message.content[] | 
            if .type == "text" then
                .text // .content // ""
            else
                ""
            end
        else
            ""
        end' 2>/dev/null | \
        grep -v "^$" | \
        grep -v "^以下はClaude Codeでの会話ログです" | \
        grep -v "^完了した作業内容を" | \
        grep -v "^Caveat: The messages below were generated" | \
        grep -v "^The user has closed" | \
        grep -v "^<command-name>" | \
        grep -v "^<local-command-stdout>" | \
        grep -v "^(no content)" | \
        head -1)
    
    if [ -n "$first_prompt" ]; then
        debug_log_v2 "Found first user prompt: ${first_prompt:0:50}..." "" "dynamic-notification"
        echo "$first_prompt"
        return 0
    fi
    
    debug_log_v2 "No user prompt found in transcript" "" "dynamic-notification"
    return 1
}

# 詳細な要約を生成（Slack用）
generate_detailed_summary() {
    local transcript_path="$1"
    
    if [ -z "$transcript_path" ] || [ ! -f "$transcript_path" ]; then
        return 1
    fi
    
    # 会話ログから最近のuser/assistantメッセージを抽出（最大30件）
    local recent_messages=$(tail -n 800 "$transcript_path" 2>/dev/null | \
        jq -r 'select(.type=="user" or .type=="assistant") | 
        select(.message.content | type=="array") |
        select(.message.content[0].text or .message.content[0].content) |
        if .message.role=="user" then 
            "ユーザー: " + ((.message.content[0].text // .message.content[0].content // "") | tostring | .[0:200])
        else 
            "Claude: " + ((.message.content[0].text // "") | tostring | .[0:200])
        end' 2>/dev/null | grep -v "^$" | tail -n 30)
    
    if [ -z "$recent_messages" ]; then
        return 1
    fi
    
    # Claudeに詳細な要約を依頼
    local prompt="以下はClaude Codeでの作業セッションの会話ログです。
$recent_messages

この会話をもとに、現在の作業内容を報告してください。200文字以内で記載してください。

最初に作業内容を一行で要約し（現在進行形）、その後に詳細を箇条書きで記載してください。
一行要約は「〜に取り組んでいます」「〜を実施中です」などの現在進行形で書いてください。

例：
Hook通知システムの改善作業を実施中です。

• gtimeoutの互換性問題を調査・修正中
• 会話から自動的に作業内容を要約する機能を開発中
• ひらがな変換処理の最適化を実施中

「会話ログから」「コミット履歴から」などのメタ的な表現は使わず、直接作業内容を書いてください。"
    
    # Claudeで要約（タイムアウトを15秒に短縮）
    local summary=$(call_claude_safely "$prompt" 15)
    
    if [ $? -eq 0 ] && [ -n "$summary" ]; then
        echo "$summary"
        return 0
    fi
    
    return 1
}

# Slack通知（非同期）
send_to_slack_async() {
    local message="$1"
    
    # Slack通知が無効な場合はスキップ
    if [ "$SLACK_NOTIFICATIONS_ENABLED" != "true" ] || [ -z "$SLACK_WEBHOOK_URL" ]; then
        debug_log_v2 "Slack notifications disabled" "" "dynamic-notification"
        return
    fi
    
    # バックグラウンドで実行
    (
        # 詳細な要約を生成
        local detailed_summary=""
        if [ -n "$CLAUDE_TRANSCRIPT_PATH" ] && [ -f "$CLAUDE_TRANSCRIPT_PATH" ]; then
            detailed_summary=$(generate_detailed_summary "$CLAUDE_TRANSCRIPT_PATH")
        fi
        
        # 詳細な要約がない場合は短い要約を使用
        if [ -z "$detailed_summary" ]; then
            detailed_summary="$message"
        fi
        
        # 最初のユーザープロンプトを取得
        local user_prompt=""
        if [ -n "$CLAUDE_TRANSCRIPT_PATH" ] && [ -f "$CLAUDE_TRANSCRIPT_PATH" ]; then
            user_prompt=$(get_first_user_prompt "$CLAUDE_TRANSCRIPT_PATH")
        fi
        
        # プロジェクト情報を取得
        local project_name=""
        local project_type=""
        local git_info=""
        
        # Git情報を取得（存在する場合のみ）
        if git rev-parse --git-dir >/dev/null 2>&1; then
            # Gitリポジトリがある場合はリポジトリ名を取得
            local git_root=$(git rev-parse --show-toplevel 2>/dev/null)
            if [ -n "$git_root" ]; then
                project_name=$(basename "$git_root")
                project_type="プロジェクト"
            else
                project_name=$(basename "$PWD")
                project_type="ディレクトリ"
            fi
            
            local changed_files=$(git diff --name-only HEAD 2>/dev/null | wc -l | tr -d ' ')
            if [ "$changed_files" != "0" ]; then
                git_info=", \"short\": true
                },
                {
                    \"title\": \"変更ファイル数\",
                    \"value\": \"${changed_files}\""
            fi
        else
            # Gitリポジトリがない場合はグローバル作業として扱う
            project_name="グローバル"
            project_type="作業環境"
        fi
        
        local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
        
        # セッションIDを含める
        local session_info=""
        if [ -n "$CLAUDE_SESSION_ID" ]; then
            session_info=", \"short\": true
                },
                {
                    \"title\": \"セッションID\",
                    \"value\": \"${CLAUDE_SESSION_ID:0:8}...\""
        fi
        
        # プロンプト用のattachmentを作成
        local prompt_attachment=""
        if [ -n "$user_prompt" ]; then
            # エスケープ処理（JSONで使用するため）
            local escaped_prompt=$(echo "$user_prompt" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')
            prompt_attachment=",
        {
            \"color\": \"#439FE0\",
            \"fields\": [
                {
                    \"title\": \"実行されたプロンプト\",
                    \"value\": \"\`\`\`${escaped_prompt}\`\`\`\",
                    \"short\": false
                }
            ]
        }"
        fi
        
        # Slackメッセージのペイロードを作成
        local payload=$(cat <<EOF
{
    "text": "${detailed_summary}",
    "attachments": [
        {
            "color": "good",
            "fields": [
                {
                    "title": "${project_type}",
                    "value": "${project_name}"${git_info}${session_info},
                    "short": true
                },
                {
                    "title": "作業時刻",
                    "value": "${timestamp}",
                    "short": false
                }
            ]
        }${prompt_attachment}
    ]
}
EOF
)
        
        # Slackに送信
        curl -X POST -H 'Content-type: application/json' \
            --data "$payload" \
            "$SLACK_WEBHOOK_URL" \
            2>> /tmp/hook_debug.log || debug_log_v2 "Slack notification failed" "" "dynamic-notification"
            
        debug_log_v2 "Slack notification sent" "" "dynamic-notification"
    ) &
}

# メッセージを生成
MESSAGE=$(generate_message)
debug_log_v2 "Generated message: $MESSAGE" "" "dynamic-notification"

# 通知用の短いメッセージ
# MESSAGEの内容に応じて適切なプレフィックスを選択
if [[ "$MESSAGE" == *"セッションを終了しました"* ]]; then
    DISPLAY_MESSAGE="$MESSAGE"
else
    DISPLAY_MESSAGE="$MESSAGE"
fi

# 通知（非同期）
if [ "$CLAUDE_NOTIFICATIONS_ENABLED" = "true" ]; then
    osascript -e "display notification \"$DISPLAY_MESSAGE\" with title \"Claude Code\" sound name \"Glass\"" &
fi

# 読み上げ用の詳細なメッセージを生成
SPEECH_MESSAGE=$(generate_detailed_speech_message "$MESSAGE")
debug_log_v2 "Generated speech message: $SPEECH_MESSAGE" "" "dynamic-notification"

# 読み上げ（非同期）
if [ -n "$SPEECH_MESSAGE" ] && [ "$CLAUDE_SPEECH_ENABLED" = "true" ]; then
    (
        if [ "$CLAUDE_NOTIFICATION_SOUND_ENABLED" = "true" ]; then
            afplay /System/Library/Sounds/Glass.aiff 2>/dev/null || true
        fi
        sleep 0.5
        # sayコマンドで読み上げ（詳細なメッセージを使用）
        say -r 180 "$SPEECH_MESSAGE"
    ) &
fi

# Slack通知（非同期）
send_to_slack_async "$MESSAGE"

debug_log_v2 "Hook処理完了" "" "dynamic-notification"

# 明示的に正常終了
exit 0
