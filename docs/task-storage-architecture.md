# タスクストレージアーキテクチャ — Agent Teams のデータ永続化

> **対象**: agent-team-avengers（Agent Teams 版）
> **最終更新**: 2026-03-31

## 概要

Claude Code の Agent Teams は、タスク管理・メッセージ通信・チーム構成のすべてを
**ローカルファイルシステム上の JSON ファイル**で管理する。
データベースや外部サービスは使わず、`~/.claude/` 配下のディレクトリ構造がそのまま通信基盤となる。

## ディレクトリ構成

```
~/.claude/
├── tasks/<team_name>/          # タスク管理（TaskCreate/TaskUpdate/TaskList）
│   ├── .lock                   # 排他制御用ロックファイル
│   ├── 1.json                  # タスクID=1
│   ├── 2.json                  # タスクID=2
│   └── ...
└── teams/<team_name>/          # チーム設定 + メッセージ通信
    ├── config.json             # チーム構成定義
    └── inboxes/                # エージェント別メッセージ受信箱
        ├── fury.json
        ├── jarvis.json
        ├── tony.json
        └── ...
```

`<team_name>` はプロジェクトごとに一意。本プロジェクトでは `avengers-team-agent-team-avengers`。

## タスクファイル（tasks/）

### 保存先

```
~/.claude/tasks/avengers-team-agent-team-avengers/N.json
```

タスクは `TaskCreate` で作成されるたびに連番 ID の JSON ファイルとして保存される。

### スキーマ

```json
{
  "id": "1",
  "subject": "タスクの件名",
  "description": "詳細説明（Markdown形式）",
  "activeForm": "現在の作業状態の説明",
  "owner": "jarvis",
  "status": "in_progress",
  "blocks": [],
  "blockedBy": []
}
```

| フィールド | 型 | 説明 |
|-----------|------|------|
| `id` | string | タスクID（ファイル名と一致） |
| `subject` | string | タスクの件名 |
| `description` | string | 詳細説明。Markdown 形式で背景・判断事項・成功基準を記述 |
| `activeForm` | string | 現在の作業状態を人間が読める形で示す |
| `owner` | string | 担当エージェント名（`jarvis`, `tony`, `bruce` 等） |
| `status` | string | 状態。`in_progress`, `completed` 等 |
| `blocks` | array | このタスクが完了しないと着手できないタスクの ID リスト |
| `blockedBy` | array | このタスクの着手に必要な前提タスクの ID リスト |

### 排他制御

`.lock` ファイルにより、複数エージェントが同時にタスクファイルを書き換える際の競合を防止する。

## チーム設定ファイル（teams/config.json）

### 保存先

```
~/.claude/teams/avengers-team-agent-team-avengers/config.json
```

### 主要フィールド

```json
{
  "name": "avengers-team-agent-team-avengers",
  "description": "チームの説明",
  "createdAt": 1774887041630,
  "leadAgentId": "team-lead@avengers-team-agent-team-avengers",
  "leadSessionId": "UUID",
  "members": [
    {
      "agentId": "jarvis@avengers-team-agent-team-avengers",
      "name": "jarvis",
      "agentType": "task_manager",
      "model": "claude-opus-4-6",
      "prompt": "初期プロンプト（指示書の読み込み指示等）",
      "color": "blue",
      "tmuxPaneId": "%36",
      "cwd": "/Users/mad-tmng/agent-team-avengers",
      "backendType": "tmux",
      "isActive": false
    }
  ]
}
```

| フィールド | 説明 |
|-----------|------|
| `name` | チーム名（ディレクトリ名と一致） |
| `leadAgentId` | チームリーダーの agentId |
| `leadSessionId` | リーダーのセッション UUID |
| `members[]` | メンバー配列。各メンバーに agentId, 名前, モデル, 初期プロンプト, tmux pane ID, 色などを持つ |
| `members[].isActive` | エージェントが現在アクティブ（処理中）かどうか |
| `members[].backendType` | バックエンド種別。本構成では `tmux` |

## メッセージ受信箱（teams/inboxes/）

### 保存先

```
~/.claude/teams/avengers-team-agent-team-avengers/inboxes/<agent_name>.json
```

エージェントごとに1つの JSON ファイルが受信箱となる。`SendMessage` で送信されたメッセージは受信者の inbox に追記される。

### スキーマ（メッセージ1件）

```json
{
  "from": "tony",
  "text": "メッセージ本文",
  "summary": "要約（オプション）",
  "timestamp": "2026-03-30T16:11:25.699Z",
  "color": "purple",
  "read": true
}
```

| フィールド | 説明 |
|-----------|------|
| `from` | 送信者のエージェント名 |
| `text` | メッセージ本文 |
| `summary` | メッセージの要約（`SendMessage` の `summary` パラメータ） |
| `timestamp` | ISO 8601 形式の送信日時 |
| `color` | 送信者に割り当てられた色（UI表示用） |
| `read` | 受信者が読んだかどうかのフラグ |

## 全体像

```
┌──────────────────────────────────────────────────────────────┐
│                    Agent Teams 通信基盤                       │
│                                                              │
│  ┌─────────────┐    TaskCreate     ┌──────────────────┐     │
│  │   Agent A    │ ──────────────→  │ tasks/N.json     │     │
│  │ (tmux pane)  │    TaskUpdate     │  - subject       │     │
│  │              │ ──────────────→  │  - owner         │     │
│  │              │    TaskList       │  - status        │     │
│  │              │ ←──────────────  │  - blocks        │     │
│  └──────┬───────┘                  └──────────────────┘     │
│         │                                                    │
│         │ SendMessage              ┌──────────────────┐     │
│         └──────────────────────→  │ inboxes/B.json   │     │
│                                    │  - from: A       │     │
│                                    │  - text          │     │
│  ┌─────────────┐  auto-delivery   │  - read: false   │     │
│  │   Agent B    │ ←──────────────  └──────────────────┘     │
│  │ (tmux pane)  │                                            │
│  └─────────────┘                                             │
│                                                              │
│  排他制御: .lock ファイルでタスク書き込みの競合を防止         │
└──────────────────────────────────────────────────────────────┘
```

## 他のチームとの関係

`~/.claude/tasks/` 配下には Agent Teams 以外のタスクディレクトリも存在しうる。
UUID 形式のディレクトリ名は、単独の Claude Code セッションや他のチームのタスクに対応する。

```
~/.claude/tasks/
├── avengers-team-agent-team-avengers/   # 本チームのタスク
├── 0f88501d-e999-4534-...               # 他セッションのタスク
├── 433eb75d-6e69-440a-...
└── b827cfc9-9a10-4177-...
```

## 設計上のポイント

1. **ファイルシステムベースの MQ**: 外部依存なしにエージェント間通信を実現。JSON ファイルの読み書きだけで動作する
2. **透明性**: すべてのタスクとメッセージが平文 JSON で保存されるため、デバッグや監査が容易
3. **ロックファイルによる排他制御**: 複数エージェントの同時書き込みを `.lock` ファイルで防止
4. **受信箱パターン**: 各エージェントが自分専用の inbox を持ち、ポーリングなしでメッセージを受信（Agent Teams が自動配信）
5. **tmux との統合**: `config.json` の `tmuxPaneId` で各エージェントの物理的なペイン位置を追跡
