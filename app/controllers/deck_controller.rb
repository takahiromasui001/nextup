class DeckController < ApplicationController
  def index
    items = Items::DeckFilter.new(current_user.items.active, params).call
    session[:deck_card_ids] = items.order('RANDOM()').pluck(:id)
    @card = Item.find_by(id: session[:deck_card_ids].first)
    @position = 0
    @total = session[:deck_card_ids].size
  end

  def show
    card_ids = session[:deck_card_ids] || []
    @position = params[:id].to_i
    @total = card_ids.size
    @card = Item.find_by(id: card_ids[@position])
  end
end
