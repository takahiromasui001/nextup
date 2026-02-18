# Phase 5: 詳細・History・仕上げ

## 5-1. 詳細画面（表示・編集・アーカイブ）

- `ItemsController#show`: Item詳細を表示
- 表示項目: title / url（リンク）/ memo / action_type / time_bucket / energy / status / created_at
- `ItemsController#edit` / `#update`: 編集フォーム
  - 編集可能: title / url / memo / action_type / time_bucket / energy
- アーカイブボタン:
  - `ArchivesController#create`（archiveの唯一の導線）
  - `status` が `active` または `snoozed` の場合のみ表示（`done` のItemには出さない）
  - `status = :archived` に更新
  - Now中のItemの場合: `current_user.update!(now_item_id: nil)` も同時実行
  - トースト:「アーカイブしました」
  - 実行後: Items画面へリダイレクト

## 5-2. Items画面（全status タブ切替）

- `ItemsController#index`
- タブで status を切り替え: active / snoozed / done / archived（デフォルト: active）
- タブ切替: クエリパラメータ（`?status=active` 等）、Turbo Frameでリスト部分のみ差し替え
- 表示内容: title / action_type / time_bucket / updated_at
- 並び順: 新しい順（`updated_at DESC`）
- 各Itemタップ → 詳細画面へ遷移

## 5-3. PWAマニフェスト（ホーム画面追加のみ）

- `public/manifest.json` を作成
  - `name` / `short_name` / `icons` / `start_url` / `display: standalone` / `theme_color`
- `application.html.erb` に `<link rel="manifest">` を追加
- アイコン画像を用意（192x192 / 512x512）
- オフライン対応はMVP外（Service Workerは設定しない）
