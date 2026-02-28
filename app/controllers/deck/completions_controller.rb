module Deck
  class CompletionsController < ApplicationController
    def create
      @item = current_user.items.find(params[:item_id])
      @item.update!(status: :done)
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
  end
end
