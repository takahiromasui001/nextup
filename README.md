# NextUp

隙間時間に「あとでやろう」を1つ選んですぐ始められるタスク選択アプリ。**Deck** でフィルタ＆スワイプして候補を選び、**Now** に1件ピン留めして集中する。

## 主な機能

- **Deck**: 候補カードをシャッフル表示。時間・タイプ・気力でフィルタし、スワイプで操作（pin / snooze / done）
- **Now**: Deckからピン留めした1件をDeck上部に固定表示
- **Add**: URL貼り付けでタイトル自動取得。最小入力で素早く登録
- **Items**: 全ステータス（active / snoozed / done / archived）のItem一覧

## 技術スタック

- Ruby on Rails（SQLite）
- Hotwire（Turbo + Stimulus）
- Tailwind CSS
- OmniAuth（Google認証）

## セットアップ

```bash
bin/setup
bin/dev
```

## ドキュメント

- [アプリ仕様](doc/spec.md)
- [ER図](doc/er.md)
- [アーキテクチャ](doc/architecture.md)
- [実装計画サマリー](doc/plan/summary.md)
