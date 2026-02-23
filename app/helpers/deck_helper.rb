module DeckHelper
  def filter_params_toggle(key, value)
    if params[key] == value
      request.query_parameters.except(key)
    else
      request.query_parameters.merge(key => value)
    end
  end

  def filter_chip_class(key, value)
    if params[key] == value
      'bg-indigo-600 text-white border-indigo-600 shadow-sm'
    else
      'bg-gray-50 text-gray-600 border-gray-200 hover:bg-gray-100'
    end
  end
end
