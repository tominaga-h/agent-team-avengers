# MIGRATION_PLAN_FIX

対象: Opus 4.6 実装済みコードレビュー  
基準: `MIGRATION_TO_AVENGERS.md` / `.cursor/plans/shogun_to_avengers_migration_307bbd79.plan.md`

## 再レビュー結果（未解消のみ）

1. **[高] `assemble.sh` が「固定8名構成」要件を満たしていない**

- `first_setup.sh` では「固定メンバー構成（Fury/JARVIS/Bruce/Strange/Tony/Peter/Cap/Marvel/Shuri）」を明記している一方、`assemble.sh` は `worker_count` / `ashigaru_count` を読み取る可変構成のまま。
- 初期値が 3 のため、起動時に Worker が不足し、構成が要件とズレる可能性が高い。
- `INIT_PROMPT` でも明示的に spawn 指示しているのは `jarvis` と `bruce` + 可変 Worker 群のみで、`strange` / `shuri` が固定で含まれる保証がない。
- 修正案:
  - `assemble.sh` から `worker_count` / `ashigaru_count` 依存を削除し、固定メンバー8名（配下7名）を明示 spawn に統一する。
  - バナーや表示文言の「Worker×N」も固定チーム名ベースに変更する。

1. **[高] `/reassemble` が存在しないスクリプト `compact_team.sh` を参照している**

- `commands/reassemble.md` は `.avengers/bin/compact_team.sh` の実行を前提にしているが、`assemble.sh` 側に当該スクリプトの生成処理がない。
- 実運用で `/reassemble` 実行時に失敗する。
- 修正案:
  - `assemble.sh` で `.avengers/bin/compact_team.sh` を生成する。
  - もしくは `commands/reassemble.md` から当該依存を外し、現行実装に合わせた手順（tmux direct send 等）へ更新する。

1. **[中] プラン完了ステータスと実装成果物が不一致**

- プランでは `step5-commands` が completed だが、`commands/` 配下は `reassemble.md` / `inspect.md` / `retreat.md` の3本のみ。
- プラン本文で移植対象としている `commands/add-todo.md` / `commands/todos.md` / `commands/project.md` / `commands/implement-todo.md` が未実装。
- 修正案:
  - 4ファイルを実装するか、不要であればプラン側のスコープから除外して completed 判定条件を更新する。

1. **[低] 移行プラン文書の参照整合が未修正**

- `.cursor/plans/shogun_to_avengers_migration_307bbd79.plan.md` の Step 3 には、Step 1 でリネーム済みの旧パス（例: `instructions/shogun_core.md`）へのリンクが残っている。
- 実装完了後に計画を参照する際、追跡性が落ちる。
- 修正案:
  - Step 3 の参照を現行ファイルに合わせるか、「旧名（履歴参照用）」注記に置き換える。

1. **[低] 通信テストの受け入れ条件が依然として曖昧**

- プランの Step 6 は「エージェント通信テスト」とのみ記載され、判定基準（Routing/QC/dashboard更新）が不足している。
- 修正案:
  - 以下を期待結果として明文化する:
    - Fury 指示を JARVIS が Task Routing で適切に配分
    - 実行担当が JARVIS へ完了報告
    - Bruce の QC 実行
    - JARVIS による `.avengers/dashboard.md` 更新

## 解消済みとして削除した項目

- `.claude/settings.json` の `permissions.deny` 維持漏れ（実装済み）
- `install.bat` 判断項目不足（ファイル存在を確認、現状は残置運用で整合）
