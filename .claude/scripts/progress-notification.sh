#!/bin/bash
# 進捗通知スクリプト（改善された再入防止機構付き）
set -euo pipefail

# 改善された共通関数を読み込む
source ~/.claude/scripts/claude-hook-common.sh

# Hook入力を解析（v2を使用して環境変数を正しく設定）
parse_hook_input_v2

# set -uエラーを防ぐため、未定義の場合のみデフォルト値を設定
: ${CLAUDE_SESSION_ID:=}
: ${CLAUDE_TRANSCRIPT_PATH:=}
: ${CLAUDE_HOOK_EVENT:=}
: ${CLAUDE_TOOL_NAME:=}
: ${HOOK_INPUT:=}
: ${CLAUDE_NOTIFICATIONS_ENABLED:=false}
: ${CLAUDE_NOTIFICATION_SOUND_ENABLED:=false}

# PostToolUseイベントのみ処理
if [ "$CLAUDE_HOOK_EVENT" != "PostToolUse" ]; then
    exit 0
fi

# ツール名ごとの再入防止（同じツールの連続実行を防ぐ）
check_hook_running "progress_notification" "$CLAUDE_TOOL_NAME" && {
    debug_log_v2 "progress-notification for $CLAUDE_TOOL_NAME already running, skipping" "" "progress-notification"
    exit 0
}

# デバッグログ
debug_log_v2 "Progress Hook: Tool=$CLAUDE_TOOL_NAME" "" "progress-notification"

# トランスクリプトパスを解決
resolve_transcript_path

# Slack設定を読み込む（デフォルト値付き）
export SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-https://hooks.slack.com/services/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}"
export SLACK_NOTIFICATIONS_ENABLED="${SLACK_NOTIFICATIONS_ENABLED:-true}"
source ~/.claude/scripts/slack-config.sh 2>/dev/null || true

# ファイル・フォルダ変更以外のツールは通知をスキップ
case "$CLAUDE_TOOL_NAME" in
    "Edit"|"MultiEdit"|"Write")
        # ファイル・フォルダ変更のみ処理を続行
        ;;
    *)
        # その他のツールは通知をスキップ
        debug_log_v2 "Skipping notification for non-file operation: $CLAUDE_TOOL_NAME" "" "progress-notification"
        exit 0
        ;;
esac

# 作業の進行状況を要約（軽量版）
generate_progress_summary() {
    local tool_name="$1"
    
    # ツール実行の詳細情報を取得
    case "$tool_name" in
        "Edit"|"MultiEdit"|"Write")
            local file=$(echo "$HOOK_INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null | xargs basename 2>/dev/null)
            [ -n "$file" ] && echo "${file}を編集" && return
            ;;
    esac
    
    # フォールバック
    echo "ファイルを編集中..."
}

# メッセージを生成
MESSAGE=$(generate_progress_summary "$CLAUDE_TOOL_NAME")
debug_log_v2 "Progress message: $MESSAGE" "" "progress-notification"

# 通知（非同期）
if [ "$CLAUDE_NOTIFICATIONS_ENABLED" = "true" ]; then
    osascript -e "display notification \"$MESSAGE\" with title \"Claude Code\"" &
fi

# 効果音（非同期）
if [ "$CLAUDE_NOTIFICATION_SOUND_ENABLED" = "true" ]; then
    afplay /System/Library/Sounds/Blow.aiff 2>/dev/null || true &
fi

debug_log_v2 "Progress notification completed" "" "progress-notification"

# 正常終了
exit 0
