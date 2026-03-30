---
name: Shogun to Avengers Migration
overview: 将軍システム（multi-agent-shogun）をMCUアベンジャーズ組織体制（Avengers Multi-Agent System v5.0）へ全面変換する。Agent Teams APIはそのまま活用し、エージェント名・ペルソナ・階層・安全ルールをAvengers仕様に置き換える。対象は指示書9本、スクリプト10本、コマンド7本、CLAUDE.md、設定ファイル、ドキュメント等の計40ファイル超。
todos:
  - id: step1-rename
    content: "Step 1: ファイルリネームとディレクトリ骨格 — 指示書6本リネーム、スクリプト3本リネーム、コマンド3本リネーム、スキル2本リネーム（全てgit mv）"
    status: pending
  - id: step2-boot-scripts
    content: "Step 2: 起動基盤スクリプト書き換え — claude-avengers, project-env.sh, check-team-spawn.sh, hooks/guard.sh, tmux-grid-layout.sh の環境変数・パス参照更新"
    status: pending
  - id: step3a-fury
    content: "Step 3a: nick_fury_core.md + nick_fury_ref.md 作成 — shogun_core/ref.mdベース、Furyペルソナ、YAML/パス/recipient全更新"
    status: pending
  - id: step3b-jarvis
    content: "Step 3b: jarvis.md 作成 — karo.md(645行)ベース、Task Routing追加、F012追加、recipient全更新"
    status: pending
  - id: step3c-bruce
    content: "Step 3c: bruce_banner.md 作成 — metsuke.md(359行)ベース、role=strategist、戦略分析追加"
    status: pending
  - id: step3d-strange
    content: "Step 3d: doctor_strange.md 新規作成 — reviewer、設計レビュー・リスク分析特化"
    status: pending
  - id: step3e-dev-workers
    content: "Step 3e: tony_stark.md + peter_parker.md 作成 — ashigaru.md(471行)ベース、開発特化Worker"
    status: pending
  - id: step3f-test-workers
    content: "Step 3f: captain_america.md + captain_marvel.md 作成 — ashigaru.mdベース、テスト/レビュー特化Worker"
    status: pending
  - id: step3g-shuri
    content: "Step 3g: shuri.md 新規作成 — idea role、Fury直属、JARVIS管理外"
    status: pending
  - id: step4-claude-md
    content: "Step 4: CLAUDE.md 書き換え — 全面差し替え（タイトル、階層図、名前表、セッション名、言語設定）+ 新規セクション追加（Git Workflow、Test Rules、Task Routing等）"
    status: pending
  - id: step5-scripts
    content: "Step 5a: 大型スクリプト書き換え — assemble.sh(715行), disassemble.sh(331行), watchdog.sh(306行), first_setup.sh(709行)"
    status: pending
  - id: step5-commands
    content: "Step 5b: コマンド内容書き換え(3本) + 新規コマンド移植(4本) + settings.json hooks更新 + スキル内容更新"
    status: pending
  - id: step6-cleanup
    content: "Step 6: 不要ファイル削除(trash)、README/CHANGELOG更新、.gitignore更新、テスト・検証"
    status: pending
isProject: false
---

# Shogun to Avengers Migration Plan

## 背景

現在のリポジトリは `multi-agent-shogun`（mainブランチ）ベース。戦国時代モチーフの階層（将軍/家老/目付/足軽）をMCUアベンジャーズ体制（Fury/JARVIS/Bruce/Strange/Tony/Peter/Cap/Marvel/Shuri）に全面変換する。

[MIGRATION_TO_AVENGERS.md](MIGRATION_TO_AVENGERS.md) の11フェーズを、推奨実装順序に従い6ステップに集約して実行する。

---

## Step 1: ファイルリネームとディレクトリ骨格 (Phase 1)

全体の骨格を確立する。既存ファイルのリネームと新規ファイルの空作成。

### 指示書リネーム
- `instructions/shogun_core.md` (165行) -> `instructions/nick_fury_core.md`
- `instructions/shogun_ref.md` (243行) -> `instructions/nick_fury_ref.md`
- `instructions/karo.md` (645行) -> `instructions/jarvis.md`
- `instructions/metsuke.md` (359行) -> `instructions/bruce_banner.md`
- `instructions/ashigaru.md` (471行) -> Worker個別ファイルのベースとして利用後に削除
- `instructions/ashigaru-checker.md` -> 削除（Bruceが担当）

### 新規指示書作成
- `instructions/doctor_strange.md` (bruce_banner.md系 + 設計レビュー特化)
- `instructions/tony_stark.md` (ashigaru.mdベース + 開発特化)
- `instructions/peter_parker.md` (ashigaru.mdベース + 開発特化)
- `instructions/captain_america.md` (ashigaru.mdベース + テスト特化)
- `instructions/captain_marvel.md` (ashigaru.mdベース + テスト特化)
- `instructions/shuri.md` (新規、アイデア整理専用)

### スクリプトリネーム
- `shutsujin_departure.sh` (715行) -> `assemble.sh`
- `tettai_retreat.sh` (331行) -> `disassemble.sh`
- `scripts/claude-shogun` (35行) -> `scripts/claude-avengers`

### コマンドリネーム
- `commands/jintate.md` (109行) -> `commands/reassemble.md`
- `commands/shisatsu.md` (126行) -> `commands/inspect.md`
- `commands/tettai.md` (118行) -> `commands/retreat.md`

### スキルリネーム
- `skills/shogun-model-switch/` -> `skills/avengers-model-switch/`
- `skills/shogun-readme-sync/` -> `skills/avengers-readme-sync/`

### 環境変数の全置換対象（全スクリプト横断）
- `SHOGUN_ROOT` -> `AVENGERS_ROOT`
- `SHOGUN_DATA_DIR` -> `AVENGERS_DATA_DIR`
- `SHOGUN_ROLE` -> `AVENGERS_ROLE`
- `TMUX_SHOGUN` -> `TMUX_FURY`
- `TMUX_MULTIAGENT` -> `TMUX_AVENGERS`
- `.shogun/` -> `.avengers/`
- `shogun-team-` -> `avengers-team-`

---

## Step 2: 起動基盤スクリプト (Phase 4 前半)

Step 1のリネーム後、起動に必須なスクリプトの内容を書き換える。

### `scripts/claude-avengers` (旧 claude-shogun, 35行)
- 全環境変数を `AVENGERS_*` に変更
- `AVENGERS_ROLE=fury` に変更

### `scripts/project-env.sh` (61行)
- 全変数名を変更: `SHOGUN_DATA_DIR` -> `AVENGERS_DATA_DIR` 等
- tmuxセッション名: `shogun-` -> `fury-`, `multiagent-` -> `avengers-`
- チーム名: `shogun-team-` -> `avengers-team-`

### `scripts/check-team-spawn.sh` (66行)
- `.shogun` -> `.avengers`, `SHOGUN_ROLE` -> `AVENGERS_ROLE`

### `scripts/hooks/guard.sh` + `test_guard.sh`
- 内部の `.shogun` 参照を `.avengers` に変更

### `scripts/tmux-grid-layout.sh` (273行)
- セッション名参照を更新

---

## Step 3: 指示書の書き換え (Phase 3) — 最大作業量

9ファイルの指示書を並列で作成可能。以下の共通変更を全指示書に適用:
- recipient名の全面更新 (shogun->fury, karo->jarvis, metsuke->bruce, ashigaruN->tony/peter/cap/marvel)
- `.shogun/` -> `.avengers/`
- 戦国風口調 -> MCU風日本語
- ペルソナの変更

### 3a. `nick_fury_core.md` + `nick_fury_ref.md`
- [shogun_core.md](instructions/shogun_core.md) (165行) ベース
- YAML Front Matter: role=team_leader, agent_id=fury, codename="Nick Fury"
- forbidden_actions: F001 karo->jarvis, F002 ashigaru->Worker
- workflow: .shogun->`.avengers`, shogun_context->fury_context
- spawn テンプレート（ref内）: JARVIS/Bruce/Strange/Tony/Peter/Cap/Marvel/Shuri
- SGATE-1, 作戦書プロトコル, CP-1~CP-5 はそのまま維持
- Fury固有: Action Required Rule, Shuri直接指示例外, /project コマンド

### 3b. `jarvis.md`
- [karo.md](instructions/karo.md) (645行) ベース
- YAML: role=task_manager, agent_id=jarvis, codename="JARVIS"
- Task Routingテーブル追加（strategy->bruce/strange, dev->tony/peter, test->cap/marvel）
- F012 JARVIS先回り禁止ルール追加
- dashboard.md唯一責任者、IDLE削減、RACE-001 はそのまま維持

### 3c. `bruce_banner.md`
- [metsuke.md](instructions/metsuke.md) (359行) ベース
- role: reviewer -> strategist（QC + 戦略分析）
- 5項目チェック維持 + 戦略分析能力追加
- 報告先: jarvis

### 3d. `doctor_strange.md` (新規)
- bruce_banner.md系ベース
- role: reviewer, 設計レビュー・リスク分析特化
- 代替案提示（14,000,605通りの可能性）

### 3e. `tony_stark.md` + `peter_parker.md`
- [ashigaru.md](instructions/ashigaru.md) (471行) ベース
- role=worker, specialty=development
- recipient "karo" -> "jarvis"
- 開発特化ペルソナ

### 3f. `captain_america.md` + `captain_marvel.md`
- ashigaru.md ベース
- role=worker, specialty=testing_and_review
- テスト/レビュー特化ペルソナ

### 3g. `shuri.md` (新規)
- role=idea, JARVIS管理外（Fury直属）
- 実装はしない（提案のみ）
- 報告先は常にFury

---

## Step 4: CLAUDE.md 書き換え (Phase 2)

指示書完成後に全体整合を取りながら [CLAUDE.md](CLAUDE.md) (446行) を書き換え。

### 基本差し替え
- タイトル: "multi-agent-shogun" -> "Avengers Multi-Agent System"
- 階層構造図: 将軍->Fury, 家老->JARVIS, 目付->Bruce, 足軽->専門Worker
- エージェント名一覧テーブル: 全Avengers名に
- セッション構成: shogun/multiagent -> fury/avengers
- 言語設定: 戦国風 -> MCU風日本語
- 指示書パス: 全新パスに更新
- `.shogun/` 参照 -> `.avengers/`
- 「上様お伺い」-> "Action Required"

### 新規セクション追加
- Destructive Operation Safety (Tier 1/2/3) — 既存内容を維持・強化
- Git Workflow (featureブランチ必須、main直接コミット禁止)
- Test Rules (SKIP=FAIL, Preflight check)
- Context Budget Rules (1000行超全読み禁止)
- Task Routing Table (YAML形式)
- Report Preservation Rules
- Agent Behavior Rules (F010-F016)

---

## Step 5: 残りスクリプト・コマンド・設定 (Phase 4後半 + 5 + 6-8)

### 大型スクリプト
- `assemble.sh` (715行): バナー変更、変数名全置換、tmuxセッション名変更、`.avengers/`ディレクトリ構築、固定8名構成(ashigaru_count削除)、INIT_PROMPT変更
- `disassemble.sh` (331行): `.shogun/`->`.avengers/`、fury_context、セッション名変更
- `watchdog.sh` (306行): `.shogun`->`.avengers`、queue/参照があればAgent Teams方式に更新
- `first_setup.sh` (709行): ブランディング変更、config/テンプレートからashigaru_count削除、`.avengers/`

### コマンド内容書き換え (3ファイル)
- `commands/reassemble.md`: recipient名全更新、パス参照更新
- `commands/inspect.md`: `TMUX_MULTIAGENT`->`TMUX_AVENGERS`、役職名更新
- `commands/retreat.md`: `.shogun/`->`.avengers/`、fury_context

### 新規コマンド移植 (4ファイル)
- `commands/add-todo.md`, `commands/todos.md`, `commands/project.md`, `commands/implement-todo.md`
- 現avengersの `.claude/commands/` から移植、Agent Teams API対応

### 設定
- `config/settings.yaml` テンプレート（first_setup.sh内）から `ashigaru_count` 削除
- `.claude/settings.json` (1005行): hooks参照パス `.shogun`->`.avengers` に更新

### スキル内容更新
- `skills/avengers-model-switch/SKILL.md`: shogun参照を更新
- `skills/avengers-readme-sync/SKILL.md`: 同上

---

## Step 6: 削除・ドキュメント・テスト (Phase 9-11)

### 不要ファイル削除（trashコマンド使用）
- `instructions/ashigaru.md` (個別ファイルに分割済み)
- `instructions/ashigaru-checker.md` (Bruceが担当)
- `AGENT_TEAMS_MIGRATION.md` (参考資料として残すか要確認)

### ドキュメント更新
- `README.md`: "multi-agent-shogun" -> "Avengers Multi-Agent System"
- `README_ja.md`: 同上
- `CHANGELOG.md`: v5.0 エントリ追加
- `docs/philosophy.md`: 戦国->MCU参照があれば更新

### `.gitignore` 更新
- `.shogun/` -> `.avengers/`

### テスト・検証
- `first_setup.sh` 実行 -> config/ 正常生成確認
- `./assemble.sh` 実行 -> `.avengers/` 構築確認
- tmuxセッション名確認
- エージェント通信テスト
- コマンドテスト (`/inspect`, `/reassemble`, `/retreat`)
- spawn制限テスト
- Shuri独立性テスト

---

## 注意事項

- `karo.md` は645行に拡張済み — `jarvis.md` への変換時にTask Routing等の追加が必要
- `ashigaru.md` は471行に拡張済み — Worker分割時に共通部分の整合を取ること
- `.shogun/` はプロジェクトローカル（作業ディレクトリ内に生成）— `.avengers/` も同様
- `config/` はリポジトリに含まれない — `first_setup.sh` が初回生成する設計
- `queue/` ディレクトリは存在しない — Agent Teams の TaskCreate/TaskList が代替
- `watchdog.sh` に旧queue/参照が残る可能性 — Agent Teams方式に更新が必要
- ファイル削除は `rm` ではなく `trash` コマンドを使用
- `git mv` でリネームし、git履歴を保持
