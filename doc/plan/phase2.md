# Phase 2: Deck（候補デッキ）

## 2-1. snooze復帰の before_action [DONE]

- `ApplicationController` に `before_action :restore_snoozed_items`
- 処理: `current_user.items.where(status: :snoozed).where('snooze_until <= ?', Time.current).update_all(status: :active, snooze_until: nil)`
- ログイン済みユーザーのみ実行

## 2-2. タブナビゲーション（下部固定） [DONE]

- 共通レイアウト（`application.html.erb`）に下部固定タブバーを配置
- タブ: Deck / Add / Items
- モバイルファースト: `position: fixed; bottom: 0` で画面下部に常駐
- 現在のタブをハイライト

## 2-3. Deck画面 — フィルタUI [DONE]

- `DeckController#index`
- フィルタはDeck上部に横並びで配置（チップ or セレクト）
  - `action_type`: 読む / 観る / やる / 考える（単一選択、未選択=全件）
  - `time_bucket`: 5分 / 10分 / 20分 / 40分 / 60分 / 60分以上（単一選択）
  - `energy`: 低 / 中 / 高（単一選択）
- フィルタ変更時: Turbo Frameでカード部分のみ差し替え
- フィルタ条件はクエリパラメータで管理（Deckを開くたびにリセット）

## 2-4. 候補抽出クエリ + シャッフル [DONE]

- 抽出条件:
  - `status: :active`
  - `id != current_user.now_item_id`（Now除外）
  - フィルタ条件をANDで結合
  - `energy` フィルタ指定時: `energy IS NOT NULL AND energy = ?`（未設定Itemは除外）
- シャッフル: `order('RANDOM()')` で取得し、IDリストをセッションに保持
  - フィルタ変更時はリストを再生成
  - 前後スワイプでリスト内を移動（現在位置もセッション管理）

## 2-5. カード1枚表示UI + スワイプ操作 [DONE]

- カード表示内容: title / action_type / time_bucket / energy
- URLありの場合: カード上にリンクボタン（`target="_blank"`で新規タブ）
- スワイプ操作（Stimulus controller）:
  - タッチイベント（`touchstart` / `touchmove` / `touchend`）でスワイプ検知
  - 左右スワイプ: シャッフル済みリスト内の前後移動
  - スワイプ方向に応じたアニメーション（カードがスライドアウト → 次カードが表示）
- 候補0件: 空状態UIを表示

## 2-6. カードアクション + スワイプアクション + トースト通知

- **上スワイプ → pin_now / 下スワイプ → snooze（プリセット選択へ）**
- **カードタップ → 詳細画面へ遷移**
- **pin_now**:
  - `user.now_item_id = item.id` に更新
  - Nowが既にある場合 → Phase 3（入れ替えダイアログ）で対応。Phase 2では単純に上書き
  - トースト:「Nowにセットしました」
- **snooze**:
  - スワイプ後にプリセット選択UI表示（明日 / 週末 / 来週）
  - `status = :snoozed`, `snooze_until` を設定
  - Now中のItemの場合: `user.now_item_id = null`
  - トースト:「○○までスヌーズしました」
- **done**:
  - ボタン操作（カード上に完了ボタン配置）
  - `status = :done`
  - Now中のItemの場合: `user.now_item_id = null`
  - トースト:「完了しました」
- アクション実行後: 次のカードを表示（リストから除去して次へ）
- トースト: Stimulus controllerで一定時間後に自動消去

## 2-7. カードタップ → 詳細画面遷移 + Now除外の適用

- **カードタップ → 詳細画面へ遷移**
  - タップ検出（swipe_controller でドラッグ量が小さい場合をタップとみなす）
  - 遷移先の詳細画面は別途設計
- **Now除外の適用**（2-4 の未実装分）
  - `DeckController#index` で `Items::DeckFilter.new(..., exclude_id: current_user.now_item_id)` を渡す
