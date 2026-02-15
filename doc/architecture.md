# アーキテクチャ

---

## 1. 技術スタック

- **バックエンド**: Ruby on Rails
- **フロントエンド**: Hotwire（Turbo + Stimulus）
- **データベース**: SQLite

---

## 2. 認証

- **OmniAuth + Google OAuth 2.0**
- Userモデルに `provider`、`uid`、`email`、`name`、`avatar_url` を保持
- セッション管理はRails標準のcookieベースセッション

---

## 3. データモデル

### User（ユーザー）

- `id`（ID）
- `provider`（認証プロバイダ）: string（`'google_oauth2'`）
- `uid`（外部ID）: string
- `email`（メールアドレス）: string
- `name`（表示名）: string
- `avatar_url`（アバターURL）: string（nullable）
- `now_item_id`（Now対象）: Item FK or null（1件だけ構造的に保証）
  - **FK制約: ON DELETE SET NULL**

### Item（やりたいこと1件）

- `id`（ID）
- `user_id`（ユーザー）: User FK（必須）
- `title`（タイトル）: string NOT NULL。ユーザー入力 or URL由来の自動取得
- `url`（URL）: string（nullable）。URLがあればリンクとして保持
- `memo`（メモ）: text（nullable）。ちょっとしたメモ
- `action_type`（行動タイプ）:
  - `read`（読む）
  - `watch`（観る）
  - `do`（やる）
  - `think`（考える）
- `time_bucket`（所要時間ざっくり）: `5 | 10 | 20 | 40 | 60 | 60_plus`（60分以上）
- `energy`（気力）※任意: `low`（低） / `mid`（中） / `high`（高）
- `status`（状態）:
  - `active`（候補として有効）
  - `snoozed`（あとで中）
  - `done`（完了）
  - `archived`（アーカイブ/捨て）
- `snooze_until`（あとで期限）: datetime or null
- `created_at`, `updated_at`, `last_opened_at`

---

## 4. snooze復帰ルール

- **ApplicationControllerのbefore_actionで毎リクエスト実行**: `status = snoozed` かつ `snooze_until` が過去のItemを `status = active` に更新する
- これによりDeckの候補抽出は `status = active` だけで判定可能

---

## 5. title自動取得（フロント非同期）

- Addフォームの `url` 欄にURLをペーストすると、フロントからサーバーのtitle取得APIを非同期で呼び出す
- 取得成功時: `title` 欄にページタイトルをプリフィル（ユーザーは編集可）
- 取得失敗時: `title` 欄は空のまま、ユーザーに手入力を促す
- バックグラウンドジョブは使用しない

---

## 6. Now中Itemの状態管理

- Now中のItemの `status` は **activeのまま**維持
- Deckのクエリで `user.now_item_id` と一致するItemを除外することで、Deckに出さない
- done/snooze/archive実行時は `user.now_item_id` を自動的に `null` にする

---

## 7. セキュリティ実装方針

- URL/メモの表示時は**HTMLエスケープ（XSS対策）**必須
- title取得API（サーバーサイド）は**SSRF対策**
  - タイムアウト設定
  - プライベートIP除外
  - リダイレクト制限

---

## 8. タイムゾーン

- **Asia/Tokyo固定**（全日時計算に適用）
