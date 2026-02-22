class User < ApplicationRecord
  has_many :items, dependent: :destroy
  belongs_to :now_item, class_name: 'Item', optional: true

  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }
  validates :email, presence: true
  validates :name, presence: true
end
