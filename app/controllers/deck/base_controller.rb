module Deck
  class BaseController < ApplicationController
    private

    def set_item
      @item = current_user.items.find(params[:item_id])
    end

    def clear_now_item
      current_user.update!(now_item: nil) if current_user.now_item_id == @item.id
    end

    def remove_from_card_list(item_id)
      card_list = CardList.new(session[:deck_card_ids])
      card_list.remove(item_id)
      session[:deck_card_ids] = card_list.card_ids
    end

    def assign_card_view_data
      card_list = CardList.new(session[:deck_card_ids])
      @card = card_list.next_card
      @position = card_list.any? ? 0 : nil
      @total = card_list.size
    end
  end
end
