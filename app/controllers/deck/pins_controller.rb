module Deck
  class PinsController < ApplicationController
    def create
      @item = current_user.items.find(params[:item_id])

      card_list = build_card_list
      current_user.update!(now_item: @item)

      card_list.remove(@item.id)
      session[:deck_card_ids] = card_list.to_a

      set_card_state(card_list)
    end

    private

    def build_card_list
      card_list = CardList.new(session[:deck_card_ids])

      return card_list unless current_user.now_item_id

      card_list.restore(current_user.now_item_id)
      card_list
    end

    def set_card_state(card_list)
      @card = card_list.next_card
      @position = card_list.any? ? 0 : nil
      @total = card_list.size
    end
  end
end
