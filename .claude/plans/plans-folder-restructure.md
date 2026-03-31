# 実装プラン: .avengers/plans フォルダ再構成

## 現状の問題

### 問題1: フラットなファイル構造
`.avengers/plans/` 直下に全ファイルが並んでおり、プランが増えると見通しが悪い。
現在18ファイル（Fury作戦書3件 + Bruce/Shuri/Strangeのレビュー等15件）が混在。

### 問題2: Fury作戦書の命名が不透明
`plan_20260331_0910.md` — 日時しか分からず、中身を開かないと何のプランか不明。

## 変更方針

### 1. サブフォルダ構成

```
.avengers/plans/
├── fury/                          # Fury の作戦書
│   ├── 20260331_tmux-integration.md
│   ├── 20260331_task-board.md
│   └── 20260331_my-task.md
├── reviews/                       # Bruce/Strange のレビュー・戦略分析
│   ├── bruce/
│   │   └── task-3/                # Fury の親タスク番号でグルーピング
│   │       ├── mytask_design.md
│   │       └── rotation_review.md
│   └── strange/
│       └── task-3/
│           ├── mytask_design.md
│           └── rotation_review.md
└── shuri/                         # Shuri のアイデア・提案
    ├── shuri_task_mgmt_proposal.md
    └── ...
```

**ルール**:
- `fury/` — Fury が作成する作戦書のみ
- `reviews/{bruce,strange}/task-N/` — Bruce/Strange のレビュー・戦略分析。**Nは Fury の親タスク番号**（Bruce/Strange 個別のサブタスク番号ではない）。同一親タスクに紐づくレビューを1フォルダに集約することで、タスク単位での視認性を確保する
- `shuri/` — Shuri のアイデア・提案
- 必要に応じてサブフォルダ追加可（例: `archive/`）

### 2. Fury作戦書の命名規則変更

**旧**: `plan_<YYYYMMDD_HHMM>.md`
**新**: `<YYYYMMDD>_<slug>.md`

- `YYYYMMDD` — 作成日（ソート用）
- `slug` — 内容を表すケバブケース（英語、簡潔に）
- 例: `20260331_tmux-integration.md`, `20260331_my-task-cli.md`

### 3. 変更が必要なファイル一覧

| ファイル | 変更内容 |
|---------|---------|
| `instructions/nick_fury_core.md` (L19, L92) | パス `.avengers/plans/plan_<timestamp>.md` → `.avengers/plans/fury/<YYYYMMDD>_<slug>.md` |
| `instructions/nick_fury_ref.md` (L130, L167) | 同上 |
| `CLAUDE.md` | 作戦書パスの記述更新（該当箇所） |
| `instructions/jarvis.md` | レビュー成果物の保存先を `reviews/{bruce,strange}/task-N/` に変更。タスク作成時に Fury 親タスク番号を指定するルールを追記 |
| `instructions/bruce_banner.md` | レビュー成果物の出力先パスを更新 |
| `instructions/doctor_strange.md` | レビュー成果物の出力先パスを更新 |

### 4. 既存ファイルの移行

現在の `.avengers/plans/` 内ファイルを新構成に移動:

```bash
# fury/ に移動（リネーム）
plan_20260331_0910.md → fury/20260331_tmux-integration.md
plan_20260331_1054.md → fury/20260331_task-board.md
plan_20260331_1843.md → fury/20260331_my-task.md

# reviews/ に移動（Fury親タスク番号でサブフォルダ作成）
bruce_*.md → reviews/bruce/task-N/（プレフィックス bruce_ を除去）
strange_*.md → reviews/strange/task-N/（プレフィックス strange_ を除去）

# shuri/ に移動
shuri_*.md → shuri/
```

### 5. fury_context.md への影響

fury_context.md 内の作戦書パス参照も新パスに更新が必要。

## スコープ外

- plans フォルダの自動アーカイブ機能
- plans の検索・一覧コマンド
