require 'rails_helper'

RSpec.describe 'Deck画面', type: :system do
  let(:user) { create(:user) }

  before do
    driven_by :rack_test
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: user.provider,
      uid: user.uid,
      info: { email: user.email, name: user.name }
    )
    visit '/auth/google_oauth2/callback'
  end

  context 'カード1枚表示' do
    before do
      create(:item, user:, title: 'テスト記事', action_type: :read, energy: :low)
      create(:item, user:, title: '動画を見る', action_type: :watch, energy: :high)
      visit deck_index_path
    end

    it 'カードのタイトルが表示される' do
      expect(page).to have_css('h2')
      titles = ['テスト記事', '動画を見る']
      displayed_title = page.find('h2').text
      expect(titles).to include(displayed_title)
    end

    it 'フィルタチップをクリックするとURLにパラメータが付く' do
      click_link '読む'
      expect(current_url).to include('action_type=read')
      expect(page).to have_content('テスト記事')
    end

    it '選択中のチップを再クリックで解除' do
      click_link '読む'
      click_link '読む'
      expect(current_url).not_to include('action_type=')
    end
  end

  context '空状態' do
    it '候補がない場合は空状態UIを表示' do
      visit deck_index_path
      expect(page).to have_content('候補がありません')
    end
  end

  context 'タブバー' do
    it '下部にタブバーが表示される' do
      visit deck_index_path
      expect(page).to have_link('Deck')
      expect(page).to have_link('Add')
      expect(page).to have_link('Items')
    end
  end
end
