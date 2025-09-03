# frozen_string_literal: true

module ApplicationHelper
  require 'redcarpet'

  def admin?(current_user)
    current_user&.admin?
  end

  def show_svg(path)
    File.open("app/assets/images/icons/#{path}", 'rb') do |file|
      raw file.read
    end
  end

  def markdown(text)
    return '' if text.nil?

    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, {
                                            autolink: true,
                                            hard_wrap: true,
                                            space_after_headers: true
                                          })
    @markdown.render(text).html_safe
  end

  def link2img(img_path)
    link_to image_tag(img_path), image_path(img_path)
  end

  def sku_inscripcio
    if user_signed_in?
      case current_user.plan_id
      when 1
        'sku_FpJPxDKMWcZhDt'
      when 2
        'sku_FpJRBRQ7I832Vx'
      when 3
        'sku_FpJRq5qJExcjwh'
      end
    else
      'sku_G5tBgB35ozoesF'
    end
  end

  def stripe_publishable_key
    if Rails.env.production?
      Rails.application.credentials.dig(:stripe, :publishable_key)
    else
      Rails.application.credentials.dig(:stripe, :public_test_key)
    end
  end

  def hcaptcha_site_key
    Rails.application.credentials.dig(:hcaptcha, :site_key)
  end

  def inscripcio_pd_id
    if user_signed_in?
      case current_user.plan_id
      when 0
        4
      when 1
        5
      when 2
        6
      when 3
        7
      end
    else
      4
    end
  end

  def nav_link_to(title, path, options = {})
    options[:class] = Array.wrap(options[:class])
    active_class = options.delete(:active_class) || 'active'
    inactive_class = options.delete(:inactive_class) || ''

    active = if (paths = Array.wrap(options[:starts_with]).presence)
               paths.any? { |path| request.path.start_with?(path) }
             else
               request.path == path
             end

    classes = active ? active_class : inactive_class
    options[:class] << classes

    link_to title, path, options
  end

  def disable_with(text)
    "<i class=\"far fa-spinner-third fa-spin\"></i> #{text}".html_safe
  end

  def render_svg(name, styles: 'fill-current text-gray-500', title: nil)
    filename = "#{name}.svg"
    title ||= name.underscore.humanize
    inline_svg(filename, aria: true, nocomment: true, title: title, class: styles)
  end

  def fa_icon(name, options = {})
    weight = options[:weight] || 'far'
    classes = [weight, "fa-#{name}", options[:class]]
    content_tag :i, nil, class: classes
  end

  def badge(text, options = {})
    base = options.delete(:base) || 'rounded-full py-1 px-4 text-xs inline-block font-bold leading-normal uppercase mr-2'
    color = options.delete(:color) || 'bg-gray-400 text-gray-700'

    options[:class] = Array.wrap(options[:class]) + [base, color]

    content_tag :div, text, options
  end

  def formatted_date(date)
    format = date.strftime('%B').in?(%w[April August October]) ? '%A, %d d\'%B del %Y' : '%A, %d de %B del %Y'
    l(date, format: format)
  end

  def flash_class(type)
    case type.to_sym
    when :notice, :success
      'bg-green-100 border-green-400 text-green-700'
    when :error, :alert
      'bg-red-100 border-red-400 text-red-700'
    else
      'bg-blue-100 border-blue-400 text-blue-700'
    end
  end

  def flash_icon(type)
    case type.to_sym
    when :notice, :success
      '<svg class="fill-current h-6 w-6 text-green-500" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"/></svg>'.html_safe
    when :error, :alert
      '<svg class="fill-current h-6 w-6 text-red-500" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"/></svg>'.html_safe
    else
      '<svg class="fill-current h-6 w-6 text-blue-500" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-11a1 1 0 10-2 0v2H7a1 1 0 100 2h2v2a1 1 0 102 0v-2h2a1 1 0 100-2h-2V7z"/></svg>'.html_safe
    end
  end
end
