module Deck
  class SnoozesController < BaseController
    def create
      set_item
      @snooze_until = compute_snooze_until(params[:preset])
      @item.update!(status: :snoozed, snooze_until: @snooze_until)
      clear_now_item
      remove_from_card_list(@item.id)
      assign_card_view_data
    end

    private

    def compute_snooze_until(preset)
      date = case preset
      when 'tomorrow'
        Date.tomorrow
      when 'weekend'
        today = Date.current
        days_until_saturday = (6 - today.wday) % 7
        days_until_saturday.zero? ? today + 7 : today + days_until_saturday
      when 'next_week'
        Date.current.next_occurring(:monday)
      else
        Date.tomorrow
      end
      date.beginning_of_day
    end
  end
end
