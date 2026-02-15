# アプリ仕様（確定版）

> 前提：Webアプリ（スマホSafari / PWAでも利用）。PWAはホーム画面追加のみ、オフライン対応はMVP外。
> 特徴：**フィルタ後にスワイプで選ぶ（Deck）**＋**Now（いまやる）を1件固定でピン留め**。
> 認証：OmniAuthを利用したGoogle認証。

---

## 0. 目的

- 隙間時間にXを見ちゃう反射を、**「やりたかったこと」へ戻す**行動に差し替える
- "保存の墓場"を避け、**迷わず選べる（スワイプ）＋いまやるを固定（Now）**で前に進める

---

## 1. 画面構成（最小4タブ＋詳細画面）

1. **Deck（候補デッキ）**
   - フィルタ後に1枚カードをスワイプして選ぶ
2. **Now（いまやる）**
   - ピン留めした1件を固定表示（目立つ）
3. **Add（追加）**
   - URL/メモを最短で登録
4. **History（履歴）**
   - done/archivedになったItemの一覧（タブで分離）
5. **詳細画面**（タブではなく遷移先）
   - Itemの詳細表示・編集・アーカイブ操作を行う画面

---

## 2. コアコンセプト（UIルール）

- **Nowは同時に1件のみ**
- Nowがある時は **Deck上部に"目立つNow固定ヘッダー"**を常駐表示
- Deckは **一覧ではなく1枚カードのデッキ**（無限スクロール禁止）
- Deckの候補表示順は**シャッフル済みリスト方式**（アクセス時に候補をシャッフルし順番に表示。前後スワイプで行き来可能）
- 追加時の入力は最小（気力は必須にしない）
- 操作後（snooze/done/pin等）は**トースト通知**でフィードバックを表示
- スワイプ方向とアクションの割り当ては **TBD**（実装時に決定）

---

## 3. データモデル（コード識別子＋日本語）

### User（ユーザー）

- `id`（ID）
- `now_item_id`（Now対象）: Item FK or null（1件だけ構造的に保証）
  - **FK制約: ON DELETE SET NULL**

### Item（やりたいこと1件）

- `id`（ID）
- `user_id`（ユーザー）: User FK（必須）
- `title`（タイトル）: string（必須）。URLありの場合はフロントで非同期取得してプリフィル、ユーザーが編集も可
- `url`（URL）: string（任意）。URLがあればリンクとして保持
- `memo`（メモ）: text（任意）。ちょっとしたメモ
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

### snooze復帰ルール

- **ApplicationControllerのbefore_actionで毎リクエスト実行**: `status = snoozed` かつ `snooze_until` が過去のItemを `status = active` に更新する
- これによりDeckの候補抽出は `status = active` だけで判定可能

---

## 4. Add（追加）の仕様

### 追加体験（スマホSafari想定）

- 入口は1つ：`＋Add`
- 入力項目：
  - `title`（必須）: タイトル
  - `url`（任意）: URLをペーストすると、フロントから非同期でページタイトルを取得し `title` 欄にプリフィル。ユーザーは編集可。取得失敗時は `title` 欄を空のまま手入力を促す
  - `memo`（任意）: ちょっとしたメモ
  - `action_type`（任意）: 読む等
  - `time_bucket`（任意）: 5/10/20…
  - `energy`（任意）: 気力
- 任意項目が未選択の場合はnull（フィルタ時に各条件の対象外となる）

---

## 5. Deck（候補デッキ）の仕様

### フィルタ

- 時間：`time_bucket`（単一選択・完全一致）
- タイプ：`action_type`（単一選択。未選択=全タイプ対象）
- 気力：`energy`（単一選択）
- **全フィルタは任意**。未選択の場合は条件なし（全件対象）
- フィルタ条件は**AND**で結合
- フィルタ条件は**毎回リセット**（Deckを開くたびに初期状態＝全件表示）
- **energy未設定のItemは、energyフィルタ指定時に候補から除外される**

### 候補の抽出条件（基本）

Deckに出すのは：

- `status = active`
- `user.now_item_id` と一致するItemは出さない

### 候補が0件の場合

- 空状態UIを表示：「該当する候補がありません。フィルタを変更するか、Addで追加してください」

### Deckのカード操作（アクション）

- `open`（開く）
  - カードタップ：詳細画面へ遷移
  - URLありの場合はカード上にリンクボタンを表示。タップで新規タブでURLを開く
  - 実行時 `last_opened_at` 更新
- `pin_now`（いまやる）
  - `user.now_item_id = item.id`
  - 既にNowがある場合は「入れ替え（置換）」確認（後述）
- `snooze`（あとで）
  - `status = snoozed`
  - `snooze_until` をプリセットで設定（後述）
- `done`（完了）
  - `status = done`
  - Nowに設定中のItemの場合、`user.now_item_id = null` も同時に実行

> **Now中のItemへの操作**: done/snooze/archive実行時は `user.now_item_id` を自動的に `null` にする。

### snoozeプリセット

| ラベル | snooze_until の値 |
|--------|------------------|
| 明日 | 翌日 0:00（Asia/Tokyo） |
| 週末 | 次の土曜 0:00（Asia/Tokyo） |
| 来週 | 次の月曜 0:00（Asia/Tokyo） |

---

## 6. Now（いまやる）の仕様（1件固定）

### 表示

- Now = `user.now_item_id` が指すItem **1件**
- Now中のItemのstatusは **activeのまま**（Deckからはクエリで除外）
- Deck上部に **Now固定ヘッダー**を表示（Nowがある時だけ）
  - 表示：タイトル / action_type / time
  - ボタン：`open`（開く） / `unpin`（外す） / `done`（完了）

### `unpin`（外す）

- `user.now_item_id = null`
- `status` は active のまま（候補に戻る）
- 直後のDeckで再び出てくる可能性あり（フィルタ次第）

### Now入れ替え（置換）

Nowがある状態で別のItemを `pin_now` したら：

- ダイアログ：
  - `replace`（入れ替える）：`user.now_item_id` を新Itemに差し替え（旧Nowは候補へ戻る）
  - `cancel`（キャンセル）

---

## 7. 詳細画面の仕様

- Deckのカードタップ（openアクション）またはHistory等から遷移
- **表示項目**: title、url（リンク）、memo、action_type、time_bucket、energy、status、created_at、last_opened_at
- **編集**: title、url、memo、action_type、time_bucket、energy を編集可能
- **アーカイブ**: 詳細画面内に「アーカイブ」ボタンを配置（archiveの唯一の導線）
  - `status = archived` に更新
  - Nowに設定中の場合は `user.now_item_id = null` も同時に実行

---

## 8. "捨てる"の扱い

- `archived`（アーカイブ/捨て）は **明示的操作**にする
  - 導線は**詳細画面の「アーカイブ」ボタンのみ**
- 繰り返しsnoozeするItemは、アーカイブを検討するサイン

---

## 9. セキュリティ

- URL/メモの表示時は**HTMLエスケープ（XSS対策）**必須
- title取得API（サーバーサイド）は**SSRF対策**（タイムアウト設定、プライベートIP除外、リダイレクト制限）

---

## 10. MVP範囲（最初に作る）

- Add（URL/メモ、action_type+time+energy、手動ペースト）
- Deck（任意フィルタ＋シャッフル＋スワイプ＋open/pin/snooze/done）
- Now（1件固定＋Deck上部に目立つ固定ヘッダー＋unpin/replace）
- History（done/archivedをタブで分離した一覧表示、新しい順）
- 詳細画面（表示・編集・アーカイブ）

### MVP外（将来検討）

- 完了数カウンター（達成感の可視化）
- プッシュ通知
- 長期放置Itemのレビュー促進
- PWAオフライン対応
- Historyからの復活（done/archived → active）
- マルチデバイス同時操作の競合制御
- 詳細画面にスレッド形式のメモ追加機能

---

## 11. 実装前に決めると良い小さな定義

- タイムゾーン: **Asia/Tokyo固定**（全日時計算に適用）
- スワイプ方向とアクションの割り当て（TBD）
