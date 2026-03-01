class DeckController < ApplicationController
  def show
    items = Items::DeckFilter.new(
      current_user.items.active,
      params,
      exclude_id: current_user.now_item_id
    ).call
    session[:deck_card_ids] = items.order('RANDOM()').pluck(:id)
    @card = Item.find_by(id: session[:deck_card_ids].first)
    @position = 0
    @total = session[:deck_card_ids].size
  end
end
