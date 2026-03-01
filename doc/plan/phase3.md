# Phase 3: Now（いまやる）

## 3-1. Now固定ヘッダー（Deck上部）

- `DeckController#index` のビューに Now固定ヘッダーを追加
- 表示条件: `current_user.now_item_id` が存在する場合のみ表示
- 表示内容: title / action_type / time_bucket
- ボタン:
  - `unpin`（外す）: `PinsController#destroy`
  - `done`（完了）: `CompletionsController#create`（status: done）
- 実装: Turbo Frameで独立させ、アクション後に差し替え

## 3-2. unpin（外す）と now_item_id のクリア

- `PinsController#destroy`
  - `current_user.update!(now_item_id: nil)`
  - Itemの `status` は変更しない（activeのまま候補に戻る）
  - トースト:「Nowを外しました」
  - Deck画面の場合: シャッフルリストを再生成（外したItemが候補に戻るため）
- snooze / done 実行時に Now中のItemだった場合も `now_item_id = nil` にする
  - `SnoozeController#create`, `CompletionsController#create` で対応

## 3-3. Now入れ替えダイアログ（replace / cancel）

- Phase 2の `pin_now` を修正: Nowが既にある場合はダイアログを表示
- ダイアログ表示: Turbo Stream or モーダル（Stimulus controllerで制御）
- 選択肢:
  - `replace`（入れ替える）
    - `current_user.update!(now_item_id: new_item.id)`
    - 旧Nowの `status` は変更しない（activeのまま候補に戻る）
    - トースト:「Nowを入れ替えました」
  - `cancel`（キャンセル）
    - ダイアログを閉じるだけ
- ルーティング: `PinsController#create`（replace時も同じアクション、既存Now有無でダイアログ表示を分岐）

