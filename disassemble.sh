#!/usr/bin/env bash
# 🏯 Avengers Multi-Agent System Disassembleスクリプト（全終了用）
# Disassemble Script - Graceful shutdown of all agents
# Agent Teams 版
#
# 使用方法:
#   ./disassemble.sh                        # 通常Disassemble（カレントディレクトリの .avengers/ を使用）
#   ./disassemble.sh --project-dir=/path     # 指定ディレクトリのプロジェクトをDisassemble
#   ./disassemble.sh -f                      # 強制Disassemble（バックアップなし）
#   ./disassemble.sh -h                      # ヘルプ表示

set -e

# Avengers Multi-Agent System のルートディレクトリ
AVENGERS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 色付きログ関数
log_info() {
    echo -e "\033[1;33m【報】\033[0m $1"
}

log_success() {
    echo -e "\033[1;32m【成】\033[0m $1"
}

log_disassemble() {
    echo -e "\033[1;36m【退】\033[0m $1"
}

# ═══════════════════════════════════════════════════════════════════════════════
# オプション解析
# ═══════════════════════════════════════════════════════════════════════════════
FORCE_MODE=false
PROJECT_DIR=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE_MODE=true
            shift
            ;;
        --project-dir=*)
            PROJECT_DIR="${1#*=}"
            shift
            ;;
        -h|--help)
            echo ""
            echo "🏯 Avengers Multi-Agent System Disassembleスクリプト（Agent Teams 版）"
            echo ""
            echo "使用方法: ./disassemble.sh [オプション]"
            echo ""
            echo "オプション:"
            echo "  -f, --force              強制Disassemble（バックアップなし）"
            echo "  --project-dir=<path>     Disassemble対象のプロジェクトディレクトリを指定"
            echo "  -h, --help               このヘルプを表示"
            echo ""
            echo "例:"
            echo "  ./disassemble.sh                          # カレントディレクトリのプロジェクトをDisassemble"
            echo "  ./disassemble.sh --project-dir=/path/to/project"
            echo "  ./disassemble.sh -f                       # 強制Disassemble（即座に終了）"
            echo ""
            echo "WORK_DIR 発見ロジック:"
            echo "  1. \$(pwd)/.avengers が存在すればカレントディレクトリ"
            echo "  2. --project-dir= で指定されたディレクトリ"
            echo "  3. フォールバック: AVENGERS_ROOT"
            echo ""
            exit 0
            ;;
        *)
            echo "不明なオプション: $1"
            echo "./disassemble.sh -h でヘルプを表示"
            exit 1
            ;;
    esac
done

# ═══════════════════════════════════════════════════════════════════════════════
# WORK_DIR 発見ロジック
# ═══════════════════════════════════════════════════════════════════════════════
if [ -n "$PROJECT_DIR" ] && [ -d "${PROJECT_DIR}/.avengers" ]; then
    WORK_DIR="$PROJECT_DIR"
elif [ -d "$(pwd)/.avengers" ]; then
    WORK_DIR="$(pwd)"
else
    WORK_DIR="$AVENGERS_ROOT"
fi

# プロジェクト共通変数を読み込み
source "${AVENGERS_ROOT}/scripts/project-env.sh"

# ═══════════════════════════════════════════════════════════════════════════════
# Disassembleバナー表示
# ═══════════════════════════════════════════════════════════════════════════════
show_disassemble_banner() {
    clear
    echo ""
    echo -e "\033[1;36m╔══════════════════════════════════════════════════════════════════════════════════╗\033[0m"
    echo -e "\033[1;36m║\033[0m \033[1;37m████████╗███████╗████████╗████████╗ █████╗ ██╗\033[0m                                 \033[1;36m║\033[0m"
    echo -e "\033[1;36m║\033[0m \033[1;37m╚══██╔══╝██╔════╝╚══██╔══╝╚══██╔══╝██╔══██╗██║\033[0m                                 \033[1;36m║\033[0m"
    echo -e "\033[1;36m║\033[0m \033[1;37m   ██║   █████╗     ██║      ██║   ███████║██║\033[0m                                 \033[1;36m║\033[0m"
    echo -e "\033[1;36m║\033[0m \033[1;37m   ██║   ██╔══╝     ██║      ██║   ██╔══██║██║\033[0m                                 \033[1;36m║\033[0m"
    echo -e "\033[1;36m║\033[0m \033[1;37m   ██║   ███████╗   ██║      ██║   ██║  ██║██║\033[0m                                 \033[1;36m║\033[0m"
    echo -e "\033[1;36m║\033[0m \033[1;37m   ╚═╝   ╚══════╝   ╚═╝      ╚═╝   ╚═╝  ╚═╝╚═╝\033[0m                                 \033[1;36m║\033[0m"
    echo -e "\033[1;36m╠══════════════════════════════════════════════════════════════════════════════════╣\033[0m"
    echo -e "\033[1;36m║\033[0m       \033[1;37mDisassembleじゃーーー！！！\033[0m    \033[1;35m⚔\033[0m    \033[1;33m本日の戦、ここまで！\033[0m                    \033[1;36m║\033[0m"
    echo -e "\033[1;36m╚══════════════════════════════════════════════════════════════════════════════════╝\033[0m"
    echo ""
}

# バナー表示
show_disassemble_banner

log_info "プロジェクト: ${PROJECT_NAME_SAFE} (${WORK_DIR})"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# 存在確認（tmux セッション + Agent Teams データ）
# ═══════════════════════════════════════════════════════════════════════════════
FURY_EXISTS=false
AVENGERS_EXISTS=false
TEAM_DATA_EXISTS=false

if tmux has-session -t "${TMUX_FURY}" 2>/dev/null; then
    FURY_EXISTS=true
fi

if tmux has-session -t "${TMUX_AVENGERS}" 2>/dev/null; then
    AVENGERS_EXISTS=true
fi

if [ -d "$TEAM_DIR" ] || [ -d "$TASK_DIR" ]; then
    TEAM_DATA_EXISTS=true
fi

if [ "$FURY_EXISTS" = false ] && [ "$AVENGERS_EXISTS" = false ] && [ "$TEAM_DATA_EXISTS" = false ]; then
    log_info "既に解散済みです（セッション・チームデータなし）"
    echo ""
    exit 0
fi

# 現在の状態を表示
log_info "現在の状態:"
[ "$FURY_EXISTS" = true ] && log_info "  ├─ tmux: ${TMUX_FURY} セッション ... 稼働中"
[ "$AVENGERS_EXISTS" = true ] && log_info "  ├─ tmux: ${TMUX_AVENGERS} セッション ... 稼働中"
[ "$TEAM_DATA_EXISTS" = true ] && log_info "  ├─ Agent Teams: チームデータ (${TEAM_NAME}) ... 存在"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# バックアップ（強制モードでなければ）
# ═══════════════════════════════════════════════════════════════════════════════
if [ "$FORCE_MODE" = false ]; then
    BACKUP_DIR="${LOGS_DIR}/backup_$(date '+%Y%m%d_%H%M%S')"
    NEED_BACKUP=false

    # dashboard.md のバックアップ判定
    if [ -f "${DASHBOARD_PATH}" ]; then
        if grep -q "cmd_" "${DASHBOARD_PATH}" 2>/dev/null; then
            NEED_BACKUP=true
        fi
    fi

    # Agent Teams タスクデータの存在確認
    if [ -d "$TASK_DIR" ]; then
        NEED_BACKUP=true
    fi

    if [ "$NEED_BACKUP" = true ]; then
        log_info "📦 ダッシュボードをバックアップ中..."
        mkdir -p "$BACKUP_DIR" || true

        # dashboard.md のバックアップ
        if [ -f "${DASHBOARD_PATH}" ]; then
            cp "${DASHBOARD_PATH}" "$BACKUP_DIR/" 2>/dev/null || true
            log_success "  ├─ dashboard.md バックアップ完了"
        fi

        # Agent Teams タスクデータのバックアップ
        if [ -d "$TASK_DIR" ]; then
            cp -r "$TASK_DIR" "$BACKUP_DIR/tasks-${TEAM_NAME}" 2>/dev/null || true
            log_success "  ├─ Agent Teams タスクデータ バックアップ完了"
        fi

        log_success "  └─ バックアップ先: $BACKUP_DIR"
        echo ""
    fi
fi

# ═══════════════════════════════════════════════════════════════════════════════
# 未完了タスク保存（-f モードでも実行）
# ═══════════════════════════════════════════════════════════════════════════════
if [ -d "$TASK_DIR" ]; then
    PENDING_YAML="${STATUS_DIR}/pending_tasks.yaml"
    PENDING_COUNT=0
    PENDING_ENTRIES=""

    for task_file in "$TASK_DIR"/*.json; do
        [ -f "$task_file" ] || continue

        task_status=$(jq -r '.status // empty' "$task_file" 2>/dev/null) || continue
        [ "$task_status" = "completed" ] && continue

        task_id=$(jq -r '.id // empty' "$task_file" 2>/dev/null) || true
        task_subject=$(jq -r '.subject // empty' "$task_file" 2>/dev/null) || true
        task_description=$(jq -r '.description // empty' "$task_file" 2>/dev/null) || true
        task_owner=$(jq -r '.owner // empty' "$task_file" 2>/dev/null) || true
        task_blocked_by=$(jq -r '(.blockedBy // []) | map(tostring) | join(", ")' "$task_file" 2>/dev/null) || true

        # ダブルクォートをエスケープ
        task_id="${task_id//\"/\\\"}"
        task_subject="${task_subject//\"/\\\"}"
        task_owner="${task_owner//\"/\\\"}"
        task_status="${task_status//\"/\\\"}"

        # YAML エントリを構築（description はリテラルブロックで出力）
        PENDING_ENTRIES="${PENDING_ENTRIES}  - id: \"${task_id}\"
    subject: \"${task_subject}\"
    description: |
$(echo "$task_description" | sed 's/^/      /')
    owner: \"${task_owner}\"
    status: \"${task_status}\"
    blockedBy: [${task_blocked_by}]
"
        PENDING_COUNT=$((PENDING_COUNT + 1))
    done

    if [ "$PENDING_COUNT" -gt 0 ]; then
        mkdir -p "${STATUS_DIR}"
        SAVED_AT=$(date "+%Y-%m-%d %H:%M")
        {
            echo "# 未完了タスク一覧（Disassemble時自動保存）"
            echo "# 再アセンブル時にFuryが読み込み、JARVISにタスクを再割り当てする"
            echo "saved_at: \"${SAVED_AT}\""
            echo "tasks:"
            printf '%s' "$PENDING_ENTRIES"
        } > "$PENDING_YAML"
        log_info "📜 未完了タスク ${PENDING_COUNT} 件を保存した"
        log_success "  └─ 保存先: ${PENDING_YAML}"
        echo ""
    else
        log_info "📜 未完了タスクなし（全任務完了済み）"
        echo ""
    fi
fi

# ═══════════════════════════════════════════════════════════════════════════════
# FuryセッションID保存（-f モードでない場合）
# ═══════════════════════════════════════════════════════════════════════════════
# Claude Code のセッションファイルは ~/.claude/projects/<sanitized-path>/<uuid>.jsonl
# に保存される。FuryのセッションIDを保存しておくと再アセンブル時に --continue で復元できる。
SESSION_ID_FILE="${STATUS_DIR}/fury_session_id"

if [ "$FORCE_MODE" = false ] && [ "$FURY_EXISTS" = true ]; then
    # WORK_DIR からセッションディレクトリを導出（/ を - に置換）
    CLAUDE_PROJECT_DIR="$HOME/.claude/projects/$(echo "$WORK_DIR" | tr '/' '-')"

    if [ -d "$CLAUDE_PROJECT_DIR" ]; then
        # 最新の .jsonl ファイル（Furyのセッション）を取得
        LATEST_SESSION=$(ls -t "$CLAUDE_PROJECT_DIR"/*.jsonl 2>/dev/null | head -1)
        if [ -n "$LATEST_SESSION" ]; then
            SESSION_ID=$(basename "$LATEST_SESSION" .jsonl)
            mkdir -p "${STATUS_DIR}"
            echo "$SESSION_ID" > "$SESSION_ID_FILE"
            log_info "📎 FuryのセッションID を保存: ${SESSION_ID:0:8}..."
        fi
    fi
elif [ "$FORCE_MODE" = true ]; then
    # 強制Disassemble: セッションIDファイルを削除（再開不可にする）
    if [ -f "$SESSION_ID_FILE" ]; then
        trash "$SESSION_ID_FILE" 2>/dev/null || true
        log_info "📎 強制Disassembleのため、セッションID を破棄"
    fi
fi

# ═══════════════════════════════════════════════════════════════════════════════
# Disassemble処理
# ═══════════════════════════════════════════════════════════════════════════════
log_disassemble "🏯 全チーム Disassemble 開始..."
echo ""

# STEP 1: tmux セッション終了（Claude Code プロセスも終了する）
if [ "$AVENGERS_EXISTS" = true ]; then
    log_disassemble "  └─ JARVIS・Bruce・Worker のセッションを終了中..."
    tmux kill-session -t "${TMUX_AVENGERS}" 2>/dev/null
    log_success "     └─ ${TMUX_AVENGERS} セッション終了"
fi

if [ "$FURY_EXISTS" = true ]; then
    log_disassemble "  └─ Fury の司令室を終了中..."
    tmux kill-session -t "${TMUX_FURY}" 2>/dev/null
    log_success "     └─ ${TMUX_FURY} セッション終了"
fi

# STEP 2: Agent Teams チームデータのクリーンアップ
if [ "$TEAM_DATA_EXISTS" = true ]; then
    log_disassemble "  └─ Agent Teams チームデータを撤収中..."

    if [ -d "$TEAM_DIR" ]; then
        trash "$TEAM_DIR" 2>/dev/null || true
        log_success "     └─ チーム設定（teams/${TEAM_NAME}）撤収完了"
    fi

    if [ -d "$TASK_DIR" ]; then
        trash "$TASK_DIR" 2>/dev/null || true
        log_success "     └─ タスクデータ（tasks/${TEAM_NAME}）撤収完了"
    fi
fi

echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# 完了メッセージ
# ═══════════════════════════════════════════════════════════════════════════════
echo -e "\033[1;36m  ╔══════════════════════════════════════════════════════════╗\033[0m"
echo -e "\033[1;36m  ║\033[0m  \033[1;37m🏯 Disassemble 完了！お疲れ様でした！\033[0m              \033[1;36m║\033[0m"
echo -e "\033[1;36m  ╚══════════════════════════════════════════════════════════╝\033[0m"
echo ""
echo "  次回アセンブルするには:"
echo "  ┌──────────────────────────────────────────────────────────┐"
echo "  │  新規アセンブル:                                                │"
echo "  │    .avengers/bin/assemble.sh                               │"
if [ -f "$SESSION_ID_FILE" ]; then
echo "  │                                                          │"
echo "  │  前回セッション引き継ぎ:                                  │"
echo "  │    .avengers/bin/assemble.sh --resume                     │"
fi
echo "  └──────────────────────────────────────────────────────────┘"
echo ""
echo "  ════════════════════════════════════════════════════════════"
echo "   See you next mission！"
echo "  ════════════════════════════════════════════════════════════"
echo ""
