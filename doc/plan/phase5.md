# Phase 5: 一覧・詳細・仕上げ

## 5-1. Items画面（全status タブ切替） [DONE]

- `ItemsController#index`
- タブで status を切り替え: active / snoozed / done / archived（デフォルト: active）
- タブ切替: クエリパラメータ（`?status=active` 等）、Turbo Frameでリスト部分のみ差し替え
- 表示内容: title / action_type / time_bucket / updated_at
- 並び順: 新しい順（`updated_at DESC`）

## 5-2. カード内 詳細表示（開閉式） [DONE]

- 各カードに「詳細」ボタンを配置
- ボタン押下でカード内に詳細情報を展開／折りたたみ（別画面遷移なし）
- 開閉状態の保存はしない（画面遷移やリロードで閉じた状態に戻る）
- 展開時の表示項目: title / url（リンク）/ memo / action_type / time_bucket / energy / status / created_at

## 5-3. URLペースト時のローディング表示 [DONE]

- URLフィールドにURLをペーストしてタイトル取得中、タイトルフィールド付近にローディング表示（例: 「タイトルを取得中...」）
- 取得完了（成功・失敗問わず）で非表示にする

## 5-4. アイテムの更新 [DONE]

- `ItemsController#edit` / `#update`: 編集フォーム
  - 編集可能: title / url / memo / action_type / time_bucket / energy

## 5-5. アーカイブ [DONE]

- `ArchivesController#create`（archiveの唯一の導線）
- `status` が `active` または `snoozed` の場合のみ表示（`done` のItemには出さない）
- `status = :archived` に更新
- Now中のItemの場合: `current_user.update!(now_item_id: nil)` も同時実行
- トースト:「アーカイブしました」
- 実行後: Items画面へリダイレクト

## 5-6. PWAマニフェスト（ホーム画面追加のみ） [DONE]

- `public/manifest.json` を作成
  - `name` / `short_name` / `icons` / `start_url` / `display: standalone` / `theme_color`
- `application.html.erb` に `<link rel="manifest">` を追加
- アイコン画像を用意（192x192 / 512x512）
- オフライン対応はMVP外（Service Workerは設定しない）
