# frozen_string_literal: true

module UserHelper
  def calculate_discounted_price(user, sortide)
    discount = case user.plan_id.to_s
               when '3'
                 0.80
               when '2'
                 0.40
               when '1'
                 0.20
               else
                 0.00
               end
    sortide.preu * (1 - discount)
  end

  def user_cat
    if user_signed_in?
      case current_user.plan_id
      when 0
        'SIMPATITZANT'
      when 1
        'ESPORÀDIC'
      when 2
        'FREQÜENT'
      when 3
        'HABITUAL'
      end
    else
      'VISITANT'
    end
  end

  def render_user_avatar(user, options = {})
    if user.avatar.attached?
      image_tag(user.avatar, { class: 'inline-block w-8 h-8 rounded-full mx-2' }.merge(options))
    else
      image_tag('avatar50.png', { class: 'w-6 h-6 rounded-full mx-1' }.merge(options)) +
        link_to('Upload Avatar', edit_user_registration_path(user), class: 'btn-sm')
    end
  end
end
