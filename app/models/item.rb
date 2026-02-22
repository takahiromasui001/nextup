class Item < ApplicationRecord
  belongs_to :user

  validates :title, presence: true

  enum :action_type, { read: 0, watch: 1, do: 2, think: 3 }
  enum :time_bucket, { five: 0, ten: 1, twenty: 2, forty: 3, sixty: 4, sixty_plus: 5 }
  enum :energy, { low: 0, mid: 1, high: 2 }
  enum :status, { active: 0, snoozed: 1, done: 2, archived: 3 }
end
