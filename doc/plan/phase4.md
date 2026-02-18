# Phase 4: Add（追加）

## 4-1. ItemsController#new / #create — フォームUI

- `ItemsController#new`: 空のItemフォームを表示
- `ItemsController#create`: バリデーション後に保存、Deckへリダイレクト
- フォーム入力項目:
  - `title`（必須）: テキスト入力
  - `url`（任意）: テキスト入力（ペースト検知はStimulusで対応 → 4-3）
  - `memo`（任意）: テキストエリア
  - `action_type`（任意）: セレクト or チップ選択（read / watch / do / think）
  - `time_bucket`（任意）: セレクト or チップ選択（5 / 10 / 20 / 40 / 60 / 60_plus）
  - `energy`（任意）: セレクト or チップ選択（low / mid / high）
- 任意項目は未選択時にnullで保存
- バリデーションエラー時: フォームをそのまま再表示

## 4-2. title自動取得API（SSRF対策込み）

- `TitlesController#show`（GET `/titles?url=...`）
- サーバーサイドで対象URLのHTMLを取得し `<title>` を返す
- SSRF対策:
  - タイムアウト設定（例: 5秒）
  - プライベートIPアドレス・ループバックアドレスへのアクセス禁止
  - リダイレクト回数制限（最大3回程度）
  - `http` / `https` スキームのみ許可
- レスポンス: `{ title: "取得したタイトル" }` or エラー時は空レスポンス（フロントで空のままにする）

## 4-3. StimulusでURLペースト検知 → titleプリフィル

- Stimulus controller を `url` フィールドにアタッチ
- `paste` イベントを検知し、ペーストされた値がURL形式かチェック
- URL形式の場合: `TitlesController#show` にリクエスト
  - 取得成功: `title` フィールドが空の場合のみプリフィル（入力済みは上書きしない）
  - 取得失敗 or タイムアウト: `title` フィールドは空のまま手入力を促す
- 取得中はローディング表示（任意）
