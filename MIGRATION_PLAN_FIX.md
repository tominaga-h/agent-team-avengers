# MIGRATION_PLAN_FIX

対象: `.cursor/plans/shogun_to_avengers_migration_307bbd79.plan.md`  
基準: `MIGRATION_TO_AVENGERS.md`

## 指摘事項

1. **Step 3 の参照リンクが実行順と矛盾**

- 現行プランでは Step 1 で `instructions/shogun_core.md` / `instructions/shogun_ref.md` をリネームした後に、Step 3 で旧パスへのリンク参照が残っている。
- この状態だと Step 1 実行後にリンク切れとなり、作業者が参照元を辿れない。
- 修正案:
  - Step 3 のリンク表記を「旧ファイル名（参照元）」という注記に変更し、リンク先は現ファイル（例: `instructions/nick_fury_core.md`）に揃える。
  - もしくは Step 3 冒頭に「旧ファイルは Step 1 前提で参照不可のため、差分は git history で確認」と明記する。

1. **Phase 8 相当のチェックが一部欠落**

- 基準文書には `.claude/settings.json` で「hooks パス更新」に加えて「`permissions.deny` は維持（D001-D008相当）」が明記されている。
- 現行プランは hooks 更新のみ記載で、`permissions.deny` の非改変確認が抜けている。
- 修正案:
  - Step 5 の設定セクションに「`permissions.deny` が意図せず変更されていないことを確認」を追加。
  - 検証チェックリストにも同項目を追加。

1. **不要ファイル整理の候補が1件不足**

- 基準文書の Phase 9 には `install.bat`（macOS環境では不要、残置可）が候補として記載されている。
- 現行プランの削除候補に `install.bat` の判断項目がないため、整理方針が不完全。
- 修正案:
  - Step 6 の削除候補に `install.bat` を追加し、「残置/削除の判断を明示する」運用にする。

1. **通信テストの受け入れ条件が基準より粗い**

- 基準文書の通信テストは「JARVISのルーティング」「BruceのQC実行」「JARVISのdashboard更新」まで明示されている。
- 現行プランは「エージェント通信テスト」と抽象化され、完了判定が曖昧。
- 修正案:
  - Step 6 テスト項目に以下の期待結果を明文化:
    - Fury指示 → JARVISがTask Routingに従って担当へ割当
    - 実行担当（Tony/Peter等）がJARVISへ完了報告
    - BruceがQCを実行
    - JARVISが `.avengers/dashboard.md` を更新

## 反映優先度

- **高**: 指摘 1, 2（作業中断・安全設定逸脱リスク）
- **中**: 指摘 4（テスト完了判定の曖昧化）
- **低**: 指摘 3（運用整理の抜け）
