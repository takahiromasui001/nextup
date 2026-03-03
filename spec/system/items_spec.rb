require 'rails_helper'

RSpec.describe 'アイテム追加', type: :system do
  let(:user) { create(:user) }

  context 'フォーム送信' do
    before do
      login_as(user)
      visit new_item_path
    end

    it 'titleを入力して送信するとDeckに遷移する' do
      fill_in 'Title', with: '読みたい記事'
      click_button 'Add Item'
      expect(current_path).to eq(deck_path)
    end

    it 'titleが空のまま送信するとバリデーションエラーが表示される' do
      click_button 'Add Item'
      expect(page).to have_content('を入力してください')
    end
  end

  context 'URLペースト → title自動入力' do
    before do
      driven_by :selenium_chrome_headless
      login_as(user)
      visit new_item_path
    end

    it 'URLをペーストするとtitleが自動入力される' do
      allow_any_instance_of(Items::TitleFetcher).to receive(:fetch).and_return('自動取得タイトル')

      page.execute_script(<<~JS, find('[data-url-title-target="url"]'))
        const dt = new DataTransfer();
        dt.setData('text/plain', 'https://example.com');
        arguments[0].dispatchEvent(new ClipboardEvent('paste', { clipboardData: dt, bubbles: true }));
      JS

      expect(page).to have_field('Title', with: '自動取得タイトル')
    end

    it 'titleが入力済みの場合はURLペーストで上書きしない' do
      allow_any_instance_of(Items::TitleFetcher).to receive(:fetch).and_return('自動取得タイトル')

      fill_in 'Title', with: '既存のタイトル'
      page.execute_script(<<~JS, find('[data-url-title-target="url"]'))
        const dt = new DataTransfer();
        dt.setData('text/plain', 'https://example.com');
        arguments[0].dispatchEvent(new ClipboardEvent('paste', { clipboardData: dt, bubbles: true }));
      JS

      # 一定時間待っても上書きされていないことを確認
      sleep 1
      expect(page).to have_field('Title', with: '既存のタイトル')
    end
  end
end
