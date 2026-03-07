require 'rails_helper'

RSpec.describe 'Items画面', type: :system do
  let(:user) { create(:user) }

  before do
    driven_by :rack_test
    login_as(user)
  end

  describe '一覧' do
    let!(:active_item)   { create(:item, user: user, status: :active) }
    let!(:snoozed_item)  { create(:item, user: user, status: :snoozed) }
    let!(:done_item)     { create(:item, user: user, status: :done) }
    let!(:archived_item) { create(:item, user: user, status: :archived) }

    before { visit items_path }

    context 'デフォルト（status未指定）' do
      it 'activeアイテムのみ表示される' do
        expect(page).to have_content(active_item.title)
        expect(page).not_to have_content(snoozed_item.title)
        expect(page).not_to have_content(done_item.title)
        expect(page).not_to have_content(archived_item.title)
      end

      it '1件表示される' do
        expect(page).to have_css('.bg-white.rounded-xl', count: 1)
      end
    end

    context 'あとでタブ' do
      before { click_link 'あとで' }

      it 'snoozedアイテムのみ表示される' do
        expect(page).to have_content(snoozed_item.title)
        expect(page).not_to have_content(active_item.title)
      end

      it '1件表示される' do
        expect(page).to have_css('.bg-white.rounded-xl', count: 1)
      end
    end

    context '完了タブ' do
      before { click_link '完了' }

      it 'doneアイテムのみ表示される' do
        expect(page).to have_content(done_item.title)
        expect(page).not_to have_content(active_item.title)
      end

      it '1件表示される' do
        expect(page).to have_css('.bg-white.rounded-xl', count: 1)
      end
    end

    context 'アーカイブタブ' do
      before { click_link 'アーカイブ' }

      it 'archivedアイテムのみ表示される' do
        expect(page).to have_content(archived_item.title)
        expect(page).not_to have_content(active_item.title)
      end

      it '1件表示される' do
        expect(page).to have_css('.bg-white.rounded-xl', count: 1)
      end
    end

    context '空のタブ（該当アイテムなし）' do
      let!(:active_item)   { nil }
      let!(:snoozed_item)  { nil }
      let!(:done_item)     { nil }
      let!(:archived_item) { nil }

      it '全タブで空メッセージが表示される' do
        expect(page).to have_content('アイテムがありません')

        click_link 'あとで'
        expect(page).to have_content('アイテムがありません')

        click_link '完了'
        expect(page).to have_content('アイテムがありません')

        click_link 'アーカイブ'
        expect(page).to have_content('アイテムがありません')
      end
    end
  end

  describe '新規作成' do
    before { visit new_item_path }

    context '正常系' do
      it 'アイテムを作成してdeckへ遷移する' do
        fill_in 'Title', with: '新しいアイテム'
        find('label', text: '読む').click
        find('label', text: '5分').click
        find('label', text: '低').click
        click_button 'アイテムを追加'

        expect(page).to have_current_path(deck_path)
        expect(user.items.find_by(title: '新しいアイテム')).to be_present
      end
    end

    context 'タイトル未入力' do
      it 'エラーが表示される' do
        find('label', text: '読む').click
        find('label', text: '5分').click
        find('label', text: '低').click
        click_button 'アイテムを追加'

        expect(page).to have_content('を入力してください')
      end
    end
  end

  describe '編集' do
    let!(:item) { create(:item, user: user, title: '元のタイトル') }

    before do
      driven_by :selenium_chrome_headless
      login_as(user)
      visit items_path
      find("a[href='#{edit_item_path(item)}']").click
    end

    context '正常系' do
      it 'タイトルを変更して保存するとitems画面に戻り更新済みタイトルが表示される' do
        fill_in 'Title', with: '更新後のタイトル'
        click_button '保存'

        expect(page).to have_current_path(items_path)
        expect(page).to have_content('更新後のタイトル')
      end
    end

    context 'タイトルを空にして保存' do
      it 'バリデーションエラーが表示される' do
        fill_in 'Title', with: ''
        click_button '保存'

        expect(page).to have_content('を入力してください')
      end
    end
  end

  describe 'URLペースト → title自動入力' do
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

      sleep 1
      expect(page).to have_field('Title', with: '既存のタイトル')
    end
  end
end
