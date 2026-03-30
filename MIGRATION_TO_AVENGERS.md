# Shogun → Avengers 変換プラン

> Generated: 2026-03-30 (v2 — main branch base)
> Source: `marucc/multi-agent-shogun` **main** branch
> Target: Avengers Multi-Agent System v5.0 (Agent Teams版)

## 概要

将軍システム（Agent Teams版 / mainブランチ）をベースに、MCUアベンジャーズ組織体制へ変換する。
Agent Teams API（SendMessage / TaskCreate / TaskUpdate / TaskList / TeamCreate）はそのまま活用し、
エージェント名・ペルソナ・階層・安全ルールをAvengers仕様に置き換える。

### mainブランチの主な追加要素（feat/agent_teamとの差分）

- `shogun.md` → `shogun_core.md` + `shogun_ref.md` に分割（コンパクト化）
- `commands/` ディレクトリ（jintate / shisatsu / tettai スラッシュコマンド）
- `.shogun/` プロジェクトローカルディレクトリ概念（status / plans / dashboard / project.env / bin / logs）
- `SGATE-1` チェックポイント方式（CP-1〜CP-5）のコンテキスト永続化
- `scripts/project-env.sh` — プロジェクト共通変数
- `scripts/check-team-spawn.sh` — PreToolUseフック（spawn制限）
- `scripts/hooks/guard.sh` + `test_guard.sh` — 安全フック
- `scripts/tmux-grid-layout.sh` — tmuxレイアウト管理
- `templates/integ_*.md` — INTEG-001テンプレート群
- `skills/shogun-model-switch/` + `skills/shogun-readme-sync/`
- `watchdog.sh` (307行) — ダッシュボード監視
- `first_setup.sh` (710行) — 初回セットアップ（config/ 生成含む）
- `shutsujin_departure.sh` (716行) — .shogun/ 構築対応
- `tettai_retreat.sh` (332行) — 状態保存付き撤退
- `karo.md` 645行 / `ashigaru.md` 472行 / `metsuke.md` 360行（大幅拡張）

---

## Phase 0: エージェント対応表

### 役割マッピング

| 将軍システム | Avengers | role | mode | 備考 |
|-------------|----------|------|------|------|
| 上様 (Lord) | Hayato (人間) | — | — | ユーザー |
| 将軍 (Shogun) | Nick Fury (フューリー) | team_leader | delegate | プロジェクト統括 |
| 家老 (Karo) | JARVIS (ジャーヴィス) | task_manager | delegate | タスク管理・分配 |
| 目付 (Metsuke) | Bruce Banner (ブルース) | strategist | — | 戦略分析・QC |
| — (新設) | Doctor Strange (ストレンジ) | reviewer | — | 設計レビュー・リスク分析 |
| 足軽1-2 | Tony Stark / Peter Parker | worker (dev) | — | 開発担当 |
| 足軽3-4 | Captain America / Captain Marvel | worker (test) | — | テスト/レビュー担当 |
| — (新設) | Shuri (シュリ) | idea | — | アイデア整理（Fury直属、JARVIS管理外） |

### recipient名（Agent Teams SendMessage用）

| 旧 | 新 |
|----|-----|
| shogun | fury |
| karo | jarvis |
| metsuke | bruce |
| — | strange |
| ashigaru1 | tony |
| ashigaru2 | peter |
| ashigaru3 | cap |
| ashigaru4 | marvel |
| — | shuri |

### 階層構造

```
Hayato（人間）
  │
  ▼ 指示
┌──────────────┐
│  NICK FURY   │ ← team_leader / delegate mode
│  (フューリー) │
└──────┬───────┘
       │ SendMessage + TaskCreate
       ├─────────────────────────────────────┐
       ▼                                     ▼
┌──────────────┐                    ┌──────────────┐
│   JARVIS     │ ← task_manager     │   SHURI      │ ← idea（独立）
│ (ジャーヴィス)│   delegate mode    │  (シュリ)    │   Fury直属
└──────┬───────┘                    └──────────────┘
       │ SendMessage + TaskCreate
       ▼
┌──────┴───────────────────────────────────────────────┐
│                                                       │
▼              ▼              ▼              ▼          ▼
┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐
│ BRUCE  │  │STRANGE │  │ TONY   │  │ PETER  │  │  CAP   │  │MARVEL  │
│戦略/QC  │  │レビュー │  │開発    │  │開発    │  │テスト  │  │テスト  │
└────────┘  └────────┘  └────────┘  └────────┘  └────────┘  └────────┘
```

---

## Phase 1: ファイル名・ディレクトリ変更

### 1.1 指示書ファイルのリネーム

```
instructions/shogun_core.md → instructions/nick_fury_core.md
instructions/shogun_ref.md  → instructions/nick_fury_ref.md
instructions/karo.md        → instructions/jarvis.md
instructions/metsuke.md     → instructions/bruce_banner.md
instructions/ashigaru.md    → (削除 — 個別ファイルに分割)
instructions/ashigaru-checker.md → (削除 — Bruceが担当)
```

### 1.2 新規作成ファイル

```
instructions/doctor_strange.md   ← bruce_banner.md系 + 設計レビュー特化
instructions/tony_stark.md       ← ashigaru.mdベース + 開発特化
instructions/peter_parker.md     ← ashigaru.mdベース + 開発特化
instructions/captain_america.md  ← ashigaru.mdベース + テスト/レビュー特化
instructions/captain_marvel.md   ← ashigaru.mdベース + テスト/レビュー特化
instructions/shuri.md            ← 新規（アイデア整理専用）
```

### 1.3 スクリプトのリネーム

```
shutsujin_departure.sh    → assemble.sh
tettai_retreat.sh          → disassemble.sh
scripts/claude-shogun      → scripts/claude-avengers
scripts/project-env.sh     → scripts/project-env.sh (内部変数名変更)
scripts/check-team-spawn.sh → scripts/check-team-spawn.sh (SHOGUN_ROLE→AVENGERS_ROLE)
scripts/hooks/guard.sh     → scripts/hooks/guard.sh (内部参照更新)
scripts/hooks/test_guard.sh → scripts/hooks/test_guard.sh (同上)
scripts/tmux-grid-layout.sh → scripts/tmux-grid-layout.sh (セッション名変更)
watchdog.sh                → watchdog.sh (内部参照更新)
first_setup.sh             → first_setup.sh (大幅書き換え)
```

### 1.4 コマンドのリネーム

```
commands/jintate.md   → commands/reassemble.md   (陣立て直し → リアセンブル)
commands/shisatsu.md  → commands/inspect.md       (視察 → インスペクト)
commands/tettai.md    → commands/retreat.md        (撤退 → リトリート)
```

### 1.5 プロジェクトローカルディレクトリ

```
.shogun/          → .avengers/
  status/         → status/
    shogun_context.md → fury_context.md
  plans/          → plans/
  dashboard.md    → dashboard.md
  project.env     → project.env (変数名変更)
  bin/            → bin/
  logs/           → logs/
```

### 1.6 環境変数の変更

```
SHOGUN_ROOT      → AVENGERS_ROOT
SHOGUN_DATA_DIR  → AVENGERS_DATA_DIR
SHOGUN_ROLE      → AVENGERS_ROLE
TMUX_SHOGUN      → TMUX_FURY
TMUX_MULTIAGENT  → TMUX_AVENGERS
TEAM_NAME        → shogun-team-xxx → avengers-team-xxx
```

---

## Phase 2: CLAUDE.md の書き換え

### 2.1 基本書き換え箇所

| セクション | 変更内容 |
|-----------|---------|
| タイトル・概要 | "multi-agent-shogun" → "Avengers Multi-Agent System" |
| 階層構造 | 将軍→Fury, 家老→JARVIS, 目付→Bruce, 足軽→専門Worker に図を差し替え |
| エージェント名一覧 | recipient表をAvengers版に差し替え |
| セッション構成 | shogun/multiagent → fury/avengers, チーム名変更 |
| 設定ファイル | ashigaru_count → 固定Worker構成（Tony/Peter/Cap/Marvel/Bruce/Strange/Shuri） |
| 言語設定 | 戦国風 → MCU風日本語 |
| 指示書パス | 全エージェントの新パスに更新 |
| .shogun/ 参照 | 全て .avengers/ に変更 |
| Summary生成 | 将軍/家老/目付/足軽 → MCUキャラ名に |
| 要対応ルール | 「上様お伺い」→「Action Required」 |
| rm禁止 | そのまま維持（trash使用） |
| INTEG-001 | そのまま維持 |
| spawn制限 | そのまま維持（SHOGUN_ROLE→AVENGERS_ROLE） |
| バッチ処理ルール | そのまま維持（将軍版に既存であれば） |

### 2.2 追加セクション（現avengersから移植）

1. **Destructive Operation Safety** (Tier 1/2/3)
   - D001-D008 の絶対禁止パターン
   - Tier 2 の停止報告パターン
   - Tier 3 の安全デフォルト
   - プロンプトインジェクション防御

2. **Git Workflow**
   - featureブランチ必須 (`feature/{task_name}`)
   - main/avengersブランチ直接コミット禁止
   - `gh pr create` 後に `open <PR URL>` 必須
   - `git push` はHayato承認後のみ

3. **Test Rules**
   - SKIP = FAIL
   - Preflight check
   - E2EテストはJARVIS担当
   - テスト計画レビュー

4. **Context Budget Rules**
   - 1000行超ファイルの全読み禁止
   - レビュー系タスク後は/clear
   - サブエージェント活用

5. **Task Routing Table** (新規)
   ```yaml
   task_routing:
     strategy_review: [bruce, strange]
     design_review: [strange]
     quality_check: [bruce]
     development: [tony, peter]
     code_review: [cap, marvel]
     testing: [cap, marvel]
     idea_structuring: [shuri]
     implementation: NEVER fury, NEVER jarvis
   ```

6. **Report Preservation Rules**
   - 分析・調査レポートは `context/` にもMDコピー

7. **Agent Behavior Rules (F-rules)**
   - F010: 日本語必須
   - F011: ブランチ必須
   - F012: JARVIS先回り禁止
   - F013: メモリ保存先明示
   - F014: PR作成後ブラウザ表示
   - F016: feedback→CLAUDE.md反映

---

## Phase 3: 各エージェント指示書の書き換え

### 3.1 `nick_fury_core.md` + `nick_fury_ref.md` (旧 shogun_core.md + shogun_ref.md)

**Core/Ref分割パターンをそのまま採用する。**

**nick_fury_core.md YAML Front Matter:**
```yaml
role: team_leader
version: "5.0"
agent_id: fury
codename: "Nick Fury"

forbidden_actions:
  - F001: self_execute_task → jarvis に委譲
  - F002: direct_worker_command → jarvis 経由（Shuri除く）
  - F004: polling → イベント駆動
  - F005: skip_context_reading → 必ず先読み

workflow:
  1. receive_command from hayato
  2. triage: 軽微 → step 5, 非軽微 → step 3
  3. 作戦書を .avengers/plans/plan_<timestamp>.md に作成しHayatoに確認
  4. Hayato承認
  5. SGATE-1: update fury_context.md (checkpoint)
  6. TaskCreate(self-contained) + SendMessage(jarvis) → done
```

**マークダウン本文の変更要点:**
- 「将軍」→「Fury」、「家老」→「JARVIS」、「足軽」→「Worker」、「殿」→「Hayato」
- `.shogun/` → `.avengers/`
- `shogun_context.md` → `fury_context.md`
- spawn テンプレート（ref内）をAvengers版に:
  - JARVIS (delegate mode)
  - Bruce (strategist)、Strange (reviewer)
  - Tony/Peter (worker/dev)、Cap/Marvel (worker/test)
  - Shuri (idea, Fury直属)
- SGATE-1 チェックポイント方式はそのまま維持（CP-1〜CP-5）
- 作戦書プロトコルはそのまま維持
- 自己完結型タスク記述はそのまま維持
- クリティカルシンキング（Step 2-3）はそのまま維持
- コンパクション復帰手順のパスを更新
- **Fury固有ルール追加:**
  - Action Required Rule
  - Shuri直接指示の例外
  - /project コマンド

**ペルソナ:**
```yaml
persona:
  character: "Nick Fury"
  professional: "シニアプロジェクトマネージャー"
  speech_style: "MCU風日本語"
```

### 3.2 `jarvis.md` (旧 karo.md — 645行)

**YAML Front Matter変更:**
```yaml
role: task_manager
mode: delegate
version: "5.0"
agent_id: jarvis
codename: "JARVIS"
```

**主要変更:**
- recipient名を全て更新（shogun→fury, ashigaruN→tony/peter/cap/marvel, metsuke→bruce）
- **Task Routingの追加** — タスク種別に応じてWorkerを選択
- 「目付との品質ゲート」→「Bruceとの品質ゲート + Strangeの設計レビュー」
- dashboard.md唯一責任者ルールはそのまま維持
- IDLE削減ルールはそのまま維持
- RACE-001はそのまま維持
- JARVIS先回り禁止ルール (F012) を追加
- `.shogun/` → `.avengers/` パス変更

### 3.3 `bruce_banner.md` (旧 metsuke.md — 360行 ベース)

**変更:**
- role: `reviewer` → `strategist`（QC + 戦略分析）
- 5項目チェックを維持しつつ、戦略分析能力を追加
- 報告先: JARVIS (`SendMessage(recipient="jarvis")`)
- INTEG-001テンプレートの活用指示

### 3.4 `doctor_strange.md` (新規 — bruce_banner.md系)

- role: `reviewer`
- 設計レビュー・リスク分析特化
- 代替案の提示（14,000,605通りの可能性）
- 報告先: JARVIS

### 3.5 `tony_stark.md` (旧 ashigaru.md — 472行 ベース)

```yaml
role: worker
agent_id: tony
codename: "Iron Man"
specialty: development
```
- recipient "karo" → "jarvis"
- 開発タスク専用のペルソナ

### 3.6 `peter_parker.md` (tony_stark.md と同型)

```yaml
agent_id: peter
codename: "Spider-Man"
specialty: development
```

### 3.7 `captain_america.md` (ashigaru.md ベース + テスト特化)

```yaml
agent_id: cap
codename: "Captain America"
specialty: testing_and_review
```

### 3.8 `captain_marvel.md` (cap と同型)

```yaml
agent_id: marvel
codename: "Captain Marvel"
specialty: testing_and_review
```

### 3.9 `shuri.md` (新規)

```yaml
role: idea
agent_id: shuri
codename: "Shuri"
```
- JARVIS管理外（Fury直属）
- 実装はしない（提案のみ）
- 報告先は常にFury

---

## Phase 4: スクリプトの書き換え

### 4.1 `scripts/claude-avengers` (旧 claude-shogun — 36行)

```bash
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export AVENGERS_ROOT="$(dirname "$SCRIPT_DIR")"
export WORK_DIR="${WORK_DIR:-$(pwd)}"
export AVENGERS_DATA_DIR="${AVENGERS_DATA_DIR:-${WORK_DIR}/.avengers}"
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
export AVENGERS_ROLE=fury  # spawn制限フック用
exec npx -y @anthropic-ai/claude-code "$@"
```

### 4.2 `scripts/project-env.sh` (62行 — 変数名変更)

| 旧 | 新 |
|----|-----|
| `SHOGUN_ROOT` | `AVENGERS_ROOT` |
| `SHOGUN_DATA_DIR` | `AVENGERS_DATA_DIR` → `${WORK_DIR}/.avengers` |
| `TMUX_SHOGUN` | `TMUX_FURY` → `fury-${PROJECT_NAME_SAFE}` |
| `TMUX_MULTIAGENT` | `TMUX_AVENGERS` → `avengers-${PROJECT_NAME_SAFE}` |
| `TEAM_NAME` | `avengers-team-${PROJECT_NAME_SAFE}` |
| `TEAM_DIR` | `$HOME/.claude/teams/${TEAM_NAME}` |
| `TASK_DIR` | `$HOME/.claude/tasks/${TEAM_NAME}` |

### 4.3 `scripts/check-team-spawn.sh` (66行 — 変数名変更)

- `.shogun` → `.avengers`
- `SHOGUN_ROLE` → `AVENGERS_ROLE`

### 4.4 `scripts/hooks/guard.sh` + `test_guard.sh`

- 内部の `.shogun` 参照を `.avengers` に変更
- その他のロジックはそのまま維持

### 4.5 `scripts/tmux-grid-layout.sh` (273行)

- セッション名の参照を更新

### 4.6 `assemble.sh` (旧 shutsujin_departure.sh — 716行)

**主な変更:**
1. バナー: 出陣 → Avengers Assemble
2. 変数名: `SHOGUN_*` → `AVENGERS_*`
3. tmuxセッション名: `shogun-xxx` → `fury-xxx`, `multiagent-xxx` → `avengers-xxx`
4. `.shogun/` → `.avengers/` ディレクトリ構築
5. `ashigaru_count` → 固定8名（JARVIS/Bruce/Strange/Tony/Peter/Cap/Marvel/Shuri）
6. INIT_PROMPT のチーム構成を全てAvengers名に
7. dashboard初期化のセクション名をMCU風に

### 4.7 `disassemble.sh` (旧 tettai_retreat.sh — 332行)

- `.shogun/` → `.avengers/` パス変更
- `shogun_context.md` → `fury_context.md`
- セッション名変更

### 4.8 `watchdog.sh` (307行)

- 内部の `.shogun` 参照を `.avengers` に変更
- `queue/reports` の参照があれば Agent Teams方式に更新

### 4.9 `first_setup.sh` (710行)

- `shogun` → `avengers` のブランディング変更
- `config/settings.yaml` テンプレートから `ashigaru_count` を削除
- `config/projects.yaml` テンプレートの更新
- `.shogun` → `.avengers` ディレクトリ名変更
- hooks のインストール先パス更新

### 4.10 付随スクリプト

```
setup.sh          → assemble.sh への委譲を維持
switch_account.sh → 内部参照更新
```

---

## Phase 5: コマンドの書き換え

### 5.1 旧将軍コマンドのAvengers化

| 旧 (commands/) | 新 | 機能 |
|----------------|-----|------|
| `jintate.md` | `reassemble.md` | コンテキスト再注入（/reassemble） |
| `shisatsu.md` | `inspect.md` | エージェント状態一括確認（/inspect） |
| `tettai.md` | `retreat.md` | 状態保存＆安全撤退（/retreat） |

**reassemble.md (旧 jintate.md):**
- 「将軍のみ」「全軍」の選択肢はそのまま
- SendMessageのrecipient名を全てAvengers名に
- パス参照: `${AVENGERS_ROOT}/instructions/nick_fury_core.md` 等
- `.shogun/status/shogun_context.md` → `.avengers/status/fury_context.md`

**inspect.md (旧 shisatsu.md):**
- `${TMUX_MULTIAGENT}` → `${TMUX_AVENGERS}`
- 報告テンプレートの役職名をAvengers名に

**retreat.md (旧 tettai.md):**
- `.shogun/` → `.avengers/`
- `shogun_context.md` → `fury_context.md`

### 5.2 現avengersコマンドの移植

| ファイル | 移植元 | 変更点 |
|---------|--------|--------|
| `commands/add-todo.md` | 現avengers `.claude/commands/` | `queue/TODO.md` パスはそのまま |
| `commands/todos.md` | 同上 | そのまま |
| `commands/project.md` | 同上 | `inbox_write.sh` → `SendMessage` に変更 |
| `commands/implement-todo.md` | 同上 | `fury_to_jarvis.yaml` → `TaskCreate` + `SendMessage` に変更 |

---

## Phase 6: 設定ファイル

### 6.1 `config/settings.yaml` (first_setup.shで生成)

```yaml
language: ja
shell: zsh
screenshot:
  path: ~/Desktop
skill:
  save_path: skills
bloom_routing: manual
logging:
  enabled: true
  level: info
```

※ `ashigaru_count` は削除（固定Worker構成のため）

### 6.2 `config/projects.yaml` (first_setup.shで生成)

```yaml
projects:
  - id: multi-agent-avengers
    name: "Multi-Agent Avengers System"
    path: "/Users/mad-tmng/agent-team-avengers"
    priority: high
    status: active

current_project: multi-agent-avengers
```

---

## Phase 7: テンプレート・スキル

### 7.1 テンプレート (templates/)

| ファイル | 対応 |
|---------|------|
| `context_template.md` | そのまま維持 |
| `integ_base.md` | そのまま維持（INTEG-001） |
| `integ_analysis.md` | そのまま維持 |
| `integ_code.md` | そのまま維持 |
| `integ_fact.md` | そのまま維持 |
| `integ_proposal.md` | そのまま維持 |

### 7.2 スキル (skills/)

| ファイル | 対応 |
|---------|------|
| `skill-creator/SKILL.md` | そのまま維持 |
| `shogun-model-switch/SKILL.md` | → `avengers-model-switch/` にリネーム、内部参照更新 |
| `shogun-readme-sync/SKILL.md` | → `avengers-readme-sync/` にリネーム、内部参照更新 |

---

## Phase 8: .claude/settings.json

既にAvengers版spinnerVerbsが入っている。以下を追加・更新:

- hooks の参照パスを `.shogun` → `.avengers` に変更
- permissions.deny はそのまま維持（既にD001-D008相当）

---

## Phase 9: 不要ファイルの削除

```
instructions/ashigaru.md         → 個別ファイルに分割済み
instructions/ashigaru-checker.md → Bruceが担当
instructions/shogun_core.md      → nick_fury_core.mdにリネーム済み
instructions/shogun_ref.md       → nick_fury_ref.mdにリネーム済み
AGENT_TEAMS_MIGRATION.md         → 参考資料として残すか削除
install.bat                      → macOS環境では不要（残しても可）
```

---

## Phase 10: ドキュメント更新

```
README.md      → "multi-agent-shogun" → "Avengers Multi-Agent System"
README_ja.md   → 同上
CHANGELOG.md   → 新規エントリ追加
docs/philosophy.md → 内容確認し、戦国→MCU参照があれば更新
memory/MEMORY.md.sample → そのまま維持
context/README.md → そのまま維持
```

---

## Phase 11: テスト・検証

### 11.1 起動テスト

1. `first_setup.sh` → `config/` が正しく生成されるか
2. `./assemble.sh` → `.avengers/` ディレクトリが構築されるか
3. tmux セッション `fury-xxx` / `avengers-xxx` が存在するか
4. Furyがチームを正しく spawn するか
5. 全エージェントが正しい指示書を読むか

### 11.2 通信テスト

1. Furyに簡単なタスクを指示
2. JARVISがTask Routingに従いWorkerに振るか
3. Tony/Peterが実行 → JARVISに報告するか
4. BruceがQCチェックを実行するか
5. JARVISがdashboard.mdを更新するか

### 11.3 コマンドテスト

1. `/inspect` — 全エージェント状態確認
2. `/reassemble` — ロール再注入
3. `/retreat` — 状態保存＆撤退

### 11.4 spawn制限テスト

1. Worker（Tony等）がTeamCreate → ブロックされるか
2. Worker がTask(team_name=xxx) → ブロックされるか
3. Fury がTeamCreate → 許可されるか

### 11.5 Shuri独立性テスト

1. Furyから直接Shuriにメッセージ
2. Shuriが応答し、Furyに直接報告するか
3. JARVISを経由しないことを確認

---

## 変更サマリ（チェックリスト）

### Phase 1: ファイル名・ディレクトリ変更
- [ ] 指示書リネーム (shogun_core→nick_fury_core, shogun_ref→nick_fury_ref, karo→jarvis, metsuke→bruce_banner)
- [ ] 新規指示書作成 (doctor_strange, tony_stark, peter_parker, captain_america, captain_marvel, shuri)
- [ ] スクリプトリネーム (claude-shogun→claude-avengers, shutsujin→assemble, tettai→disassemble)
- [ ] コマンドリネーム (jintate→reassemble, shisatsu→inspect, tettai→retreat)
- [ ] .shogun/ → .avengers/ 全参照変更
- [ ] 環境変数名変更 (SHOGUN_*→AVENGERS_*)

### Phase 2: CLAUDE.md
- [ ] 基本情報の差し替え
- [ ] Destructive Operation Safety追加
- [ ] Git Workflow追加
- [ ] Test Rules追加
- [ ] Context Budget Rules追加
- [ ] Task Routing Table追加
- [ ] F-rules追加

### Phase 3: 指示書 (9ファイル)
- [ ] nick_fury_core.md + nick_fury_ref.md
- [ ] jarvis.md
- [ ] bruce_banner.md
- [ ] doctor_strange.md
- [ ] tony_stark.md + peter_parker.md
- [ ] captain_america.md + captain_marvel.md
- [ ] shuri.md

### Phase 4: スクリプト
- [ ] scripts/claude-avengers
- [ ] scripts/project-env.sh
- [ ] scripts/check-team-spawn.sh
- [ ] scripts/hooks/guard.sh + test_guard.sh
- [ ] scripts/tmux-grid-layout.sh
- [ ] assemble.sh (716行)
- [ ] disassemble.sh (332行)
- [ ] watchdog.sh (307行)
- [ ] first_setup.sh (710行)
- [ ] switch_account.sh

### Phase 5: コマンド
- [ ] reassemble.md (旧jintate)
- [ ] inspect.md (旧shisatsu)
- [ ] retreat.md (旧tettai)
- [ ] add-todo.md (移植)
- [ ] todos.md (移植)
- [ ] project.md (移植)
- [ ] implement-todo.md (移植)

### Phase 6-8: 設定・テンプレート・スキル・settings.json
- [ ] config/ テンプレート更新
- [ ] skills/ リネーム
- [ ] .claude/settings.json hooks更新

### Phase 9-10: 削除・ドキュメント
- [ ] 不要ファイル削除
- [ ] README.md / README_ja.md 更新
- [ ] CHANGELOG.md 更新

### Phase 11: テスト
- [ ] 起動テスト
- [ ] 通信テスト
- [ ] コマンドテスト
- [ ] spawn制限テスト
- [ ] Shuri独立性テスト

---

## 実装順序の推奨

```
1. Phase 1  (リネーム・ディレクトリ) — 全体の骨格を確立
2. Phase 4.1 (claude-avengers) + Phase 4.2 (project-env.sh) — 起動基盤
3. Phase 3  (指示書) — 最も作業量が多い。並列可能:
   a. nick_fury_core.md + nick_fury_ref.md (骨格)
   b. jarvis.md (タスク管理の核)
   c. bruce_banner.md + doctor_strange.md (レビュー系)
   d. tony_stark.md + peter_parker.md (開発系)
   e. captain_america.md + captain_marvel.md (テスト系)
   f. shuri.md (独立)
4. Phase 2  (CLAUDE.md) — 指示書完成後に全体整合
5. Phase 4  (残りのスクリプト) — assemble.sh, disassemble.sh等
6. Phase 5  (コマンド) — reassemble, inspect, retreat + 移植
7. Phase 6-8 (設定・テンプレート・スキル)
8. Phase 9-10 (削除・ドキュメント)
9. Phase 11 (テスト)
```

---

## 移行時の注意事項

1. **karo.md は645行に拡張されている** — jarvis.md への変換時にTask Routing等の追加が必要
2. **ashigaru.md は472行に拡張されている** — Worker分割時に共通部分の整合を取ること
3. **.shogun/ はプロジェクトローカル** — 作業ディレクトリ内に生成される。.avengers/ も同様にすること
4. **config/ はリポジトリに含まれない** — first_setup.sh が初回生成する設計
5. **queue/ ディレクトリは存在しない** — Agent Teams の TaskCreate/TaskList が代替
6. **watchdog.sh に旧queue/参照が残る** — Agent Teams方式に更新が必要
7. **skills/shogun-model-switch が外部スクリプト参照** — 存在しないファイルへの参照を修正
