require 'rails_helper'

RSpec.describe 'Deck::Snoozes', type: :request do
  include SessionHelper

  let(:user) { create(:user) }
  let(:item) { create(:item, user: user) }

  before { login_as(user) }

  describe 'POST /deck/snoozes' do
    subject { post deck_snoozes_path, params: { item_id: item.id, preset: 'tomorrow' }, as: :turbo_stream }

    it 'status が snoozed になる' do
      subject
      expect(item.reload.status).to eq('snoozed')
    end

    it 'snooze_until が設定される' do
      subject
      expect(item.reload.snooze_until).to eq(Date.tomorrow.beginning_of_day)
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
