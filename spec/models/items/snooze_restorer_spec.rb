require 'rails_helper'

RSpec.describe Items::SnoozeRestorer do
  let(:user) { create(:user) }

  subject { described_class.new(user).restore }

  context 'snooze_untilが過去のアイテム' do
    before do
      create(:item, user: user, status: :snoozed, snooze_until: 1.hour.ago)
    end

    it 'activeに復帰しsnooze_untilがnilになる' do
      subject
      item = user.items.first
      expect(item.status).to eq('active')
      expect(item.snooze_until).to be_nil
    end
  end

  context 'snooze_untilが未来のアイテム' do
    before do
      create(:item, user: user, status: :snoozed, snooze_until: 1.day.from_now)
    end

    it 'snoozedのまま' do
      subject
      item = user.items.first
      expect(item.status).to eq('snoozed')
      expect(item.snooze_until).to be_present
    end
  end
end
