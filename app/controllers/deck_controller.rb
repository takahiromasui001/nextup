class DeckController < ApplicationController
  def index
    @items = DeckFilter.new(current_user.items.active, params).call
  end
end
