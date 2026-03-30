#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# project-env.sh - プロジェクト共通変数定義
# ═══════════════════════════════════════════════════════════════════════════════
#
# 全スクリプトが source して使う共通ヘルパー。
# WORK_DIR と AVENGERS_ROOT が設定済みの前提で、以下を導出する:
#
#   PROJECT_NAME_SAFE  - basename を sanitize（tmux セッション名用）
#   AVENGERS_DATA_DIR  - ${WORK_DIR}/.avengers
#   TMUX_FURY          - fury-<project> セッション名
#   TMUX_AVENGERS      - avengers-<project> セッション名
#   TEAM_NAME          - Agent Teams チーム名
#   TEAM_DIR           - ~/.claude/teams/${TEAM_NAME}
#   TASK_DIR           - ~/.claude/tasks/${TEAM_NAME}
#   DASHBOARD_PATH     - ダッシュボードファイルパス
#   STATUS_DIR         - ステータスディレクトリ
#   LOGS_DIR           - ログディレクトリ
#   BIN_DIR            - ラッパースクリプトディレクトリ
#
# 使い方:
#   WORK_DIR="$(pwd)"
#   AVENGERS_ROOT="/path/to/multi-agent-avengers"
#   source "${AVENGERS_ROOT}/scripts/project-env.sh"
#
# ═══════════════════════════════════════════════════════════════════════════════

# 必須変数チェック
if [ -z "$WORK_DIR" ]; then
    echo "ERROR: WORK_DIR が設定されていません" >&2
    exit 1
fi

if [ -z "$AVENGERS_ROOT" ]; then
    echo "ERROR: AVENGERS_ROOT が設定されていません" >&2
    exit 1
fi

# プロジェクト名を basename から生成し、tmux に安全な文字列に sanitize
# - ドット・スペース・スラッシュをハイフンに置換
# - 先頭のハイフン/ドットを除去
PROJECT_NAME_RAW="$(basename "$WORK_DIR")"
PROJECT_NAME_SAFE="$(echo "$PROJECT_NAME_RAW" | tr ' ./' '---' | sed 's/^[-.]*//')"

# プロジェクト固有のデータディレクトリ
AVENGERS_DATA_DIR="${WORK_DIR}/.avengers"

# tmux セッション名
TMUX_FURY="fury-${PROJECT_NAME_SAFE}"
TMUX_AVENGERS="avengers-${PROJECT_NAME_SAFE}"

# Agent Teams
TEAM_NAME="avengers-team-${PROJECT_NAME_SAFE}"
TEAM_DIR="$HOME/.claude/teams/${TEAM_NAME}"
TASK_DIR="$HOME/.claude/tasks/${TEAM_NAME}"

# プロジェクト固有パス
DASHBOARD_PATH="${AVENGERS_DATA_DIR}/dashboard.md"
STATUS_DIR="${AVENGERS_DATA_DIR}/status"
LOGS_DIR="${AVENGERS_DATA_DIR}/logs"
BIN_DIR="${AVENGERS_DATA_DIR}/bin"
