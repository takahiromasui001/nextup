class DeckFilter
  FILTER_KEYS = %i[action_type time_bucket energy].freeze

  def initialize(scope, params)
    @scope = scope
    @params = params
  end

  def call
    FILTER_KEYS.reduce(@scope) do |scope, key|
      value = @params[key]
      known_enum = value.present? && Item.defined_enums[key.to_s]&.key?(value)
      known_enum ? scope.where(key => value) : scope
    end
  end
end
