module Deck
  class CardList
    def initialize(card_ids)
      @card_ids = card_ids || []
    end

    def remove(item_id)
      @card_ids.delete(item_id)
    end

    def restore(item_id)
      @card_ids << item_id unless @card_ids.include?(item_id)
    end

    def next_card
      Item.find_by(id: @card_ids.first)
    end

    def size
      @card_ids.size
    end

    def any?
      @card_ids.any?
    end

    def card_ids
      @card_ids
    end
  end
end
