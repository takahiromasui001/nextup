require 'rails_helper'

RSpec.describe 'Titles', type: :request do
  include SessionHelper

  let(:user) { create(:user) }

  describe 'GET /title' do
    context '未ログイン' do
      it 'login_pathへリダイレクト' do
        get title_path
        expect(response).to redirect_to(login_path)
      end
    end

    context 'ログイン済み' do
      before { login_as(user) }

      context 'タイトル取得成功' do
        before do
          allow(Items::TitleFetcher).to receive(:new).and_return(
            instance_double(Items::TitleFetcher, fetch: 'Example Domain')
          )
        end

        it '{ title: ... } を返す' do
          get title_path, params: { url: 'https://example.com' }
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to eq({ 'title' => 'Example Domain' })
        end
      end

      context 'タイトル取得失敗' do
        before do
          allow(Items::TitleFetcher).to receive(:new).and_return(
            instance_double(Items::TitleFetcher, fetch: nil)
          )
        end

        it '空のJSONを返す' do
          get title_path, params: { url: 'http://127.0.0.1' }
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to eq({})
        end
      end
    end
  end
end
