module Deck
  class SnoozesController < ApplicationController
    def create
      @item = current_user.items.find(params[:item_id])
      @snooze_until = compute_snooze_until(params[:preset])
      @item.update!(status: :snoozed, snooze_until: @snooze_until)
      clear_now_item

      card_list = CardList.new(session[:deck_card_ids])
      card_list.remove(@item.id)
      session[:deck_card_ids] = card_list.to_a

      set_card_state(card_list)
    end

    private

    def clear_now_item
      current_user.update!(now_item: nil) if current_user.now_item_id == @item.id
    end

    def set_card_state(card_list)
      @card = card_list.next_card
      @position = card_list.any? ? 0 : nil
      @total = card_list.size
    end

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
