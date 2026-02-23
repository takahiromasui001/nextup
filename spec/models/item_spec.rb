require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:action_type).with_values(read: 0, watch: 1, do: 2, think: 3) }
    it { is_expected.to define_enum_for(:time_bucket).with_values(five: 0, ten: 1, twenty: 2, forty: 3, sixty: 4, sixty_plus: 5) }
    it { is_expected.to define_enum_for(:energy).with_values(low: 0, mid: 1, high: 2) }
    it { is_expected.to define_enum_for(:status).with_values(active: 0, snoozed: 1, done: 2, archived: 3) }
  end
end
