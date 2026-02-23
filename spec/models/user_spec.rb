require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:items).dependent(:destroy) }
    it { is_expected.to belong_to(:now_item).class_name('Item').optional }
  end

  describe 'validations' do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_presence_of(:uid) }
    it { is_expected.to validate_uniqueness_of(:uid).scoped_to(:provider) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:name) }
  end
end
