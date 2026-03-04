require 'rails_helper'

RSpec.describe 'Items画面', type: :system do
  let(:user) { create(:user) }

  before do
    driven_by :rack_test
    login_as(user)
  end

  describe '一覧' do
    let!(:active_item)  { create(:item, user: user, status: :active) }
    let!(:snoozed_item) { create(:item, user: user, status: :snoozed) }

    before { visit items_path }

    context 'デフォルト（status未指定）' do
      it 'activeアイテムが表示される' do
        expect(page).to have_content(active_item.title)
        expect(page).not_to have_content(snoozed_item.title)
      end
    end

    context 'タブ切り替え' do
      it 'あとでタブをクリックするとsnoozedアイテムが表示される' do
        click_link 'あとで'
        expect(page).to have_content(snoozed_item.title)
        expect(page).not_to have_content(active_item.title)
      end
    end

    context '空のタブ' do
      it '完了タブは空メッセージを表示する' do
        click_link '完了'
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
        click_button 'Add Item'

        expect(page).to have_current_path(deck_path)
        expect(user.items.find_by(title: '新しいアイテム')).to be_present
      end
    end

    context 'タイトル未入力' do
      it 'エラーが表示される' do
        find('label', text: '読む').click
        find('label', text: '5分').click
        find('label', text: '低').click
        click_button 'Add Item'

        expect(page).to have_content('を入力してください')
      end
    end
  end
end
