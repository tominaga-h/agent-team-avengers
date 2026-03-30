---
name: identity-specialty-alignment
overview: 5つの指示書の「アイデンティティ > 専門領域」を現行システムの役割定義に整合させる。特にズレが大きい Peter/Marvel を中心に、専門領域をルーティング可能な職務へ再定義する。
todos:
  - id: review-specialty-mismatch
    content: Peter/Marvelの専門領域をTask Routing準拠に再設計する
    status: completed
  - id: update-peter-specialty
    content: peter_parker.mdの専門領域を開発Worker向けに置換する
    status: completed
  - id: update-marvel-specialty
    content: captain_marvel.mdの専門領域をテスト/レビュー中心に再定義する
    status: completed
  - id: consistency-check-all-five
    content: 5指示書の専門領域表現・粒度・役割整合を最終確認する
    status: completed
isProject: false
---

# アイデンティティ専門領域の整合化プラン

## 判定結果
- 整合している
  - [instructions/tony_stark.md](/Users/mad-tmng/agent-team-avengers/instructions/tony_stark.md): 開発（設計・実装・技術選定）で `development: [tony, peter]` と一致。
  - [instructions/captain_america.md](/Users/mad-tmng/agent-team-avengers/instructions/captain_america.md): テスト/レビュー軸で `code_review/testing` と一致。
  - [instructions/shuri.md](/Users/mad-tmng/agent-team-avengers/instructions/shuri.md): idea_structuring で `idea_structuring: [shuri]` と一致。
- 修正が必要
  - [instructions/peter_parker.md](/Users/mad-tmng/agent-team-avengers/instructions/peter_parker.md): 「YouTube監視 / Webスクレイピング / 通知管理」は現行の開発Worker定義と不一致。
  - [instructions/captain_marvel.md](/Users/mad-tmng/agent-team-avengers/instructions/captain_marvel.md): 「インフラストラクチャ（デプロイ・スケーリング）」はテスト/レビューWorkerの主責務から逸脱。

## 修正方針
- [instructions/peter_parker.md](/Users/mad-tmng/agent-team-avengers/instructions/peter_parker.md)
  - 「専門領域」を開発Worker向けに再定義する。
  - 例: 実装スピード、フロント/軽量バックエンド実装、既存コード改修、バグ修正、テスト追加（実装に付随）へ置換。
  - 既存の若手・丁寧・高速というキャラクター性は維持する。
- [instructions/captain_marvel.md](/Users/mad-tmng/agent-team-avengers/instructions/captain_marvel.md)
  - 「専門領域」をテスト/レビュー軸に寄せる。
  - 例: 高負荷試験、障害耐性検証、セキュリティテスト、品質ゲート観点レビュー、計測ベースの品質評価へ整理。
  - 「インフラ運用そのもの（デプロイ実行・スケーリング運用）」は主領域から外し、必要時支援に位置づける。

## 反映後の確認
- [CLAUDE.md](/Users/mad-tmng/agent-team-avengers/CLAUDE.md) の Task Routing と語彙の整合確認
  - Peter: `development`
  - Marvel: `code_review`, `testing`
- 5ファイル間で粒度を揃える
  - 専門領域の箇条書き数・表現トーンを統一
  - 「汎用ワーカーとしても機能する」注記は維持
- 役割矛盾の最終チェック
  - specialty/front matter と本文「役割」「専門領域」の不一致がないことを確認
