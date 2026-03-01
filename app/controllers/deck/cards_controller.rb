module Deck
  class CardsController < ApplicationController
    def show
      card_ids = session[:deck_card_ids] || []
      @position = params[:position].to_i
      @total = card_ids.size
      @card = Item.find_by(id: card_ids[@position])
    end
  end
end
