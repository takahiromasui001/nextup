class Items::DeckFilter
  FILTER_CATEGORIES = %i[action_type time_bucket energy].freeze

  def initialize(scope, params, exclude_id: nil)
    @scope = scope
    @params = params
    @exclude_id = exclude_id
  end

  def call
    FILTER_CATEGORIES
      .reduce(@scope) { |scope, category| filter_by(scope, category, @params[category]) }
      .then { |scope| @exclude_id.present? ? scope.where.not(id: @exclude_id) : scope }
  end

  private

  def filter_by(scope, category, selected)
    if selected.present? && defined_in_category?(category, selected)
      scope.where(category => selected)
    else
      scope
    end
  end

  def defined_in_category?(category, selected)
    Item.defined_enums[category.to_s]&.keys&.include?(selected)
  end
end
