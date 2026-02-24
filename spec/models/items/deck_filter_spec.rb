require 'rails_helper'

RSpec.describe Items::DeckFilter do
  let(:user) { create(:user) }
  let(:scope) { user.items.active }
  let(:params) { ActionController::Parameters.new(filter_params) }

  subject { described_class.new(scope, params, **options).call }

  let(:options) { {} }

  context 'フィルタなし' do
    let(:filter_params) { {} }

    before do
      create(:item, user: user, action_type: :read)
      create(:item, user: user, action_type: :watch)
    end

    it 'active全件を返す' do
      expect(subject.count).to eq(2)
    end
  end

  context 'action_type指定' do
    let(:filter_params) { { action_type: 'read' } }

    before do
      create(:item, user: user, action_type: :read)
      create(:item, user: user, action_type: :watch)
    end

    it '該当のみ返す' do
      expect(subject.count).to eq(1)
      expect(subject.first.action_type).to eq('read')
    end
  end

  context '複合フィルタ' do
    let(:filter_params) { { action_type: 'read', energy: 'low' } }

    before do
      create(:item, user: user, action_type: :read, energy: :low)
      create(:item, user: user, action_type: :read, energy: :high)
      create(:item, user: user, action_type: :watch, energy: :low)
    end

    it 'AND条件で返す' do
      expect(subject.count).to eq(1)
      expect(subject.first.action_type).to eq('read')
      expect(subject.first.energy).to eq('low')
    end
  end

  context '不正なenum値' do
    let(:filter_params) { { action_type: 'invalid' } }

    before do
      create(:item, user: user, action_type: :read)
    end

    it '無視して全件返す' do
      expect(subject.count).to eq(1)
    end
  end

  context 'exclude_id指定' do
    let(:filter_params) { {} }
    let(:options) { { exclude_id: excluded_item.id } }

    let!(:excluded_item) { create(:item, user: user, action_type: :read) }

    before do
      create(:item, user: user, action_type: :watch)
    end

    it '指定IDを除外する' do
      expect(subject.count).to eq(1)
      expect(subject.pluck(:id)).not_to include(excluded_item.id)
    end
  end

  context 'energyがNULLのアイテム' do
    let(:filter_params) { { energy: 'low' } }

    before do
      create(:item, user: user, action_type: :read, energy: nil)
      create(:item, user: user, action_type: :read, energy: :low)
    end

    it 'energy NULLは除外される' do
      expect(subject.count).to eq(1)
      expect(subject.first.energy).to eq('low')
    end
  end
end
