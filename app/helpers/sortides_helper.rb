# frozen_string_literal: true

module SortidesHelper
  def color_for_value(value)
    case value
    when 1
      'rose'
    when 2
      'blue'
    when 3
      'teal'
    when 4
      'orange'
    when 5
      'yellow'
    else
      'gray' # default color
    end
  end

  def can_create_sortide?(user)
    user.id == 1 || user.puntuacio.escalafo >= 3
  end
end
