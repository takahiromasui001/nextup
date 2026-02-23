class Items::SnoozeRestorer
  def initialize(user)
    @user = user
  end

  def restore
    @user.items.snoozed.where('snooze_until <= ?', Time.current)
         .update_all(status: Item.statuses[:active], snooze_until: nil)
  end
end
