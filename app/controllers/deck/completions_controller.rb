module Deck
  class CompletionsController < BaseController
    def create
      set_item
      @item.update!(status: :done)
      clear_now_item
      remove_from_card_list(@item.id)
      assign_card_view_data
    end
  end
end
