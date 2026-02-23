module ApplicationHelper
  def tab_active?(name)
    controller_name == name
  end
end
