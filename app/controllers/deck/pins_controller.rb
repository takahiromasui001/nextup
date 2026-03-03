module Deck
  class PinsController < BaseController
    def create
      set_item
      update_card_list_for_pin
      current_user.update!(now_item: @item)
      assign_card_view_data
    end

    def destroy
      item_id = current_user.now_item_id
      current_user.update!(now_item_id: nil)
      restore_to_card_list(item_id)
      assign_card_view_data
    end

    private

    def restore_to_card_list(item_id)
      card_list = CardList.new(session[:deck_card_ids])
      card_list.restore(item_id)
      session[:deck_card_ids] = card_list.card_ids
    end

    def update_card_list_for_pin
      card_list = CardList.new(session[:deck_card_ids])
      card_list.restore(current_user.now_item_id) if current_user.now_item_id
      card_list.remove(@item.id)
      session[:deck_card_ids] = card_list.card_ids
    end
  end
end
