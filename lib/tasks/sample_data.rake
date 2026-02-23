namespace :sample_data do
  desc 'Create sample items for a user. Usage: bin/rails sample_data:create USER_UID=xxx'
  task create: :environment do
    uid = ENV.fetch('USER_UID') { abort 'USER_UID is required. Usage: bin/rails sample_data:create USER_UID=xxx' }
    user = User.find_by!(uid: uid)

    items_data = [
      { title: 'Rubyの基礎を学ぶ', action_type: :read, time_bucket: :twenty, energy: :mid, status: :active, url: 'https://example.com/ruby-basics', memo: 'チャプター3から再開' },
      { title: 'Rails公式ガイドを読む', action_type: :read, time_bucket: :forty, energy: :high, status: :active, memo: 'Active Recordの章' },
      { title: 'RSpec入門動画を見る', action_type: :watch, time_bucket: :sixty, energy: :low, status: :active, url: 'https://example.com/rspec-video' },
      { title: 'Docker環境を構築する', action_type: :do, time_bucket: :sixty_plus, energy: :high, status: :active },
      { title: 'アプリ設計を考える', action_type: :think, time_bucket: :ten, energy: :mid, status: :active, url: 'https://example.com/design-doc', memo: 'ER図の見直し' },
      { title: 'TypeScript入門', action_type: :read, time_bucket: :twenty, energy: :mid, status: :snoozed, snooze_until: 3.days.from_now },
      { title: 'CI/CD設定を見直す', action_type: :do, time_bucket: :forty, energy: :high, status: :snoozed, snooze_until: 2.days.ago, memo: 'GitHub Actions周り' },
      { title: 'テスト戦略を検討', action_type: :think, time_bucket: :five, energy: :low, status: :snoozed, snooze_until: 1.week.from_now, url: 'https://example.com/test-strategy' },
      { title: 'Git入門記事を読む', action_type: :read, time_bucket: :ten, energy: :low, status: :done },
      { title: 'デプロイ手順を確認', action_type: :watch, time_bucket: :five, energy: :low, status: :done, url: 'https://example.com/deploy-guide' },
      { title: 'READMEを書く', action_type: :do, time_bucket: :twenty, energy: :mid, status: :done, memo: '完了済み' },
      { title: '古いgemの調査', action_type: :read, time_bucket: :ten, energy: :low, status: :archived },
      { title: 'レガシーコードの解析', action_type: :think, time_bucket: :sixty, energy: :high, status: :archived, memo: '不要になった' },
      { title: 'Webpack設定の動画', action_type: :watch, time_bucket: :forty, energy: :mid, status: :archived, url: 'https://example.com/webpack' }
    ]

    items_data.each do |data|
      user.items.find_or_create_by!(title: data[:title]) do |item|
        item.assign_attributes(data.except(:title))
      end
    end

    now_item = user.items.find_by(title: 'Rubyの基礎を学ぶ')
    user.update!(now_item: now_item)

    puts "Created #{user.items.count} items for #{user.name} (now_item: #{now_item.title})"
  end
end
