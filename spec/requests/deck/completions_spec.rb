require 'rails_helper'

RSpec.describe 'Deck::Completions', type: :request do
  include SessionHelper

  let(:user) { create(:user) }
  let(:item) { create(:item, user: user) }

  before { login_as(user) }

  describe 'POST /deck/completions' do
    subject { post deck_completions_path, params: { item_id: item.id }, as: :turbo_stream }

    it 'status が done になる' do
      subject
      expect(item.reload.status).to eq('done')
    end

    it 'turbo_stream を返す' do
      subject
      expect(response.media_type).to eq('text/vnd.turbo-stream.html')
    end

    context 'now_item の場合' do
      before { user.update!(now_item: item) }

      it 'now_item がクリアされる' do
        subject
        expect(user.reload.now_item).to be_nil
      end
    end
  end
end
