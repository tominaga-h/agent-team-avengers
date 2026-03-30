---
name: avengers-model-switch
description: |
  エージェントのCLI/モデルをライブ切替するスキル。settings.yaml更新→/exit→新CLI起動→
  pane metadata更新を一発で実行。Thinking有無も制御。
  「モデル切替」「Sonnetにして」「Opusに変えて」「Worker全員切替」「Thinking切って」で起動。
allowed-tools: Bash(bash scripts/switch_cli.sh *), Read, Edit
---

# /model-switch - Agent CLI Live Switcher

## Overview

稼働中のエージェントのCLI種別・モデル・Thinking設定をライブで切り替える。
`settings.yaml` → `build_cli_command()` → `/exit` → 新CLI起動 → pane metadata更新 を一貫実行。

## When to Use

- 「TonyをOpusにして」「Worker全員Sonnetに切替」
- 「モデル切替」「モデル変えて」「CLI変えて」
- 「Thinking切って」「Thinking有効にして」
- 「CodexからClaudeに戻して」「Sparkにして」
- タスクの性質に応じてモデルを切り替えたいとき

## Architecture

```
settings.yaml (source of truth)
    │
    ├─ cli.agents.{id}.type      → claude | codex | copilot | kimi
    ├─ cli.agents.{id}.model     → claude-sonnet-4-6 | claude-opus-4-6 | ...
    └─ cli.agents.{id}.thinking  → true | false
         │
         ├── build_cli_command()
         │   └─ thinking: false → "MAX_THINKING_TOKENS=0 claude --model ..."
         │   └─ thinking: true  → "claude --model ..."
         │
         └── get_model_display_name()
             └─ thinking: true  → "Sonnet+T" / "Opus+T"
             └─ thinking: false → "Sonnet" / "Opus"
```

## Display Name Mapping

| model (settings.yaml) | 表示名 | +Thinking |
|---|---|---|
| claude-sonnet-4-6 | Sonnet | Sonnet+T |
| claude-opus-4-6 | Opus | Opus+T |
| claude-haiku-4-5-20251001 | Haiku | Haiku+T |
| gpt-5.3-codex | Codex | — |
| gpt-5.3-codex-spark | Spark | — |

## Instructions

### 単体切替

```bash
# settings.yaml の現在値で再起動
bash scripts/switch_cli.sh tony

# モデル変更（settings.yaml も自動更新）
bash scripts/switch_cli.sh tony --model claude-opus-4-6

# CLI種別ごと変更（Codex → Claude）
bash scripts/switch_cli.sh peter --type claude --model claude-sonnet-4-6

# Claude → Codex Spark
bash scripts/switch_cli.sh cap --type codex --model gpt-5.3-codex-spark
```

### 一括切替

```bash
# 全 Worker を Sonnet に
for agent in tony peter cap marvel; do
    bash scripts/switch_cli.sh "$agent" --type claude --model claude-sonnet-4-6
done

# 全エージェント（JARVIS・Bruce含む）を再起動
for agent in jarvis bruce strange tony peter cap marvel shuri; do
    bash scripts/switch_cli.sh "$agent"
done
```

### Thinking 制御

settings.yaml の `thinking` フィールドを編集してから switch_cli.sh を実行:

```yaml
# config/settings.yaml
cli:
  agents:
    tony:
      type: claude
      model: claude-opus-4-6
      thinking: false  # ← MAX_THINKING_TOKENS=0 で起動
```

```bash
bash scripts/switch_cli.sh tony
```

## Files

| ファイル | 役割 |
|---|---|
| `scripts/switch_cli.sh` | メインスクリプト |
| `lib/cli_adapter.sh` | `build_cli_command()`, `get_model_display_name()` |
| `config/settings.yaml` | エージェント設定（type, model, thinking） |
| `logs/switch_cli.log` | 実行ログ |

## Constraints

- **Fury ペインには送信しない**: switch_cli.sh は avengers セッションのペインのみ対象
- **実行中のエージェントに注意**: タスク実行中に切り替えるとデータ消失の可能性あり。idle確認してから実行
- **Codex → Claude 切替時**: Codex の /exit が不安定な場合がある。Escape + Ctrl-C で確実に終了させる
