# Phase 1: プロジェクト基盤

## 1-1. Rails new + 基本設定

- `rails new nextup --database=sqlite3 --css=tailwind --skip-jbuilder --skip-mailer --skip-mailbox --skip-action-text --skip-active-storage`
- `config/application.rb`
  - `config.time_zone = 'Tokyo'`
  - `config.i18n.default_locale = :ja`

## 1-2. i18n設定

- `config/locales/ja.yml` を作成
- 対象（MVP最小限）:
  - ActiveRecord モデル名・属性名（User, Item）
  - enum表示ラベル（action_type, time_bucket, energy, status）
  - フラッシュメッセージ / トースト通知の共通文言
  - バリデーションエラーメッセージ（rails-i18n gem）

## 1-3. OmniAuth Google認証 + Userモデル

- Gem: `omniauth-google-oauth2`, `omniauth-rails_csrf_protection`
- マイグレーション:
  ```
  users
    provider:string  NOT NULL
    uid:string       NOT NULL
    email:string     NOT NULL
    name:string      NOT NULL
    now_item_id:bigint (nullable, FK → items, ON DELETE SET NULL)
    timestamps
  ```

  - `now_item_id` のFK制約はItemテーブル作成後に追加（1-4で同時対応）
  - unique index: `[provider, uid]`
- Userモデル: `belongs_to :now_item, class_name: 'Item', optional: true`
- SessionsController: `create`（コールバック）/ `destroy`（ログアウト）
- `current_user` ヘルパー + 未ログイン時リダイレクト

## 1-4. Itemモデル + マイグレーション

- マイグレーション:
  ```
  items
    user_id:bigint      NOT NULL, FK → users
    title:string        NOT NULL
    url:string
    memo:text
    action_type:integer (enum)
    time_bucket:integer (enum)
    energy:integer      (enum)
    status:integer      NOT NULL, default: 0 (active)
    snooze_until:datetime
    timestamps
  ```

  - index: `[user_id, status]`
  - `users.now_item_id` へのFK制約もここで追加
- Itemモデル:
  - `belongs_to :user`
  - `validates :title, presence: true`
  - enum定義:
    - `action_type`: read, watch, do, think
    - `time_bucket`: 5, 10, 20, 40, 60, 60_plus
    - `energy`: low, mid, high
    - `status`: active, snoozed, done, archived

## 1-5. seedデータ

- テスト用User 1名（開発環境用の固定ユーザー）
- Item 10〜15件程度、以下のパターンを網羅。それぞれ3件ずつ:
  - 各status（active x複数, snoozed, done, archived）
  - action_type / time_bucket / energy の各値を散らす
  - URLあり・なし混在
  - memoあり・なし混在
  - snoozed: snooze_until が未来のもの・過去のもの各1件
  - 1件を `user.now_item_id` に設定（Now状態の確認用）
