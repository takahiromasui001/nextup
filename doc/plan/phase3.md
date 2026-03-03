# Phase 3: Now（いまやる）

## 3-1. Now固定ヘッダー（Deck上部） [Done]

- `DeckController#index` のビューに Now固定ヘッダーを追加
- 表示条件: `current_user.now_item_id` が存在する場合のみ表示
- 表示内容: title / action_type / time_bucket
- ボタン:
  - `unpin`（外す）: `PinsController#destroy`
  - `done`（完了）: `CompletionsController#create`（status: done）
- 実装: Turbo Frameで独立させ、アクション後に差し替え

## 3-2. unpin（外す）と now_item_id のクリア [Done]

- `PinsController#destroy`
  - `current_user.update!(now_item_id: nil)`
  - Itemの `status` は変更しない（activeのまま候補に戻る）
  - トースト:「Nowを外しました」
  - Deck画面の場合: シャッフルリストを再生成（外したItemが候補に戻るため）
- snooze / done 実行時に Now中のItemだった場合も `now_item_id = nil` にする
  - `SnoozeController#create`, `CompletionsController#create` で対応
