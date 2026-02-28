require 'rails_helper'

RSpec.describe 'Deck::Pins', type: :request do
  include SessionHelper

  let(:user) { create(:user) }
  let(:item) { create(:item, user: user) }

  before { login_as(user) }

  describe 'POST /deck/pins' do
    subject { post deck_pins_path, params: { item_id: item.id }, as: :turbo_stream }

    it 'now_item にセットされる' do
      subject
      expect(user.reload.now_item).to eq(item)
    end

    it 'turbo_stream を返す' do
      subject
      expect(response.media_type).to eq('text/vnd.turbo-stream.html')
    end

    context '既に now_item がある場合' do
      let(:previous_item) { create(:item, user: user) }

      before do
        user.update!(now_item: previous_item)
        get deck_index_path
      end

      it '前の now_item がデッキに戻る' do
        post deck_pins_path, params: { item_id: item.id }, as: :turbo_stream
        expect(session[:deck_card_ids]).to include(previous_item.id)
      end
    end

    context 'セッションにカードがある場合' do
      let(:other_item) { create(:item, user: user) }

      before do
        get deck_index_path
      end

      it 'セッションから除去される' do
        post deck_pins_path, params: { item_id: item.id }, as: :turbo_stream
        expect(session[:deck_card_ids]).not_to include(item.id)
      end
    end
  end
end
