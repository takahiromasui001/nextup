# NextUp 実装計画サマリー

## Phase 1: プロジェクト基盤

1. Rails new（SQLite）+ 基本設定（タイムゾーン Asia/Tokyo）
2. i18n設定（ja.yml、デフォルトlocale: ja）
3. OmniAuth Google認証 + Userモデル（`now_item_id` 含む）
4. Itemモデル（enum, バリデーション, FK）+ マイグレーション
5. seedデータ（各status・属性パターンを網羅）

## Phase 2: Deck（候補デッキ）

6. snooze復帰の before_action 実装
7. タブナビゲーション（Deck / Add / Items、モバイルファースト、下部固定）
8. Deck画面 — フィルタUI（time_bucket / action_type / energy）
9. 候補抽出クエリ（active + Now除外 + フィルタAND）+ シャッフル
10. カード1枚表示UI + スワイプ操作（Stimulus）
11. カードアクション（pin_now / snooze / done）+ トースト通知

## Phase 3: Now（いまやる）

12. Now固定ヘッダー（Deck上部）— unpin / done / open
13. Now入れ替えダイアログ（replace / cancel）

## Phase 4: Add（追加）

15. ItemsController#new / #create — フォームUI
16. title自動取得API（SSRF対策込み）
17. Stimulus で URL ペースト検知 → title プリフィル

## Phase 5: 詳細・History・仕上げ

18. 詳細画面（表示・編集・アーカイブボタン）
19. Items画面（全status タブ切替、新しい順）
20. PWAマニフェスト（ホーム画面追加のみ）
