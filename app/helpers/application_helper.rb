module ApplicationHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context
  include ActionView::Helpers::TextHelper

  def errors_for(object)
    return unless object.errors.any?
    content_tag :div, class:'error-explanation center-block panel panel-danger' do
      concat(content_tag(:div, class: 'panel-heading') do
        content_tag :h2, class: 'panel-title' do
          title = 'There'
          if object.errors.count == 1
            title << " is #{object.errors.count} error"
          else
            title << " are #{object.errors.count} errors"
          end
          title << ' prohibited this '+ object.model_name.human.downcase + ' from being created'
        end
      end)

      concat(content_tag(:table, class: 'table') do
        object.errors.full_messages.each do |msg|
          concat(raw('<tr><td>' + msg + '</td></tr>'))
        end
      end)
    end
  end

  def green_tag(content, options = {})
    color_tag content, 'green', options
  end

  def yellow_tag(content, options = {})
    color_tag content, 'yellow', options
  end

  def red_tag(content, options = {})
    color_tag content, 'red', options
  end

  def color_tag(content, color, options={})
    if options[:class].nil?
      options[:class] = "#{color.to_s}-tag"
    elsif options[:class].is_a(Array)
      options[:class] << "#{color.to_s}-tag"
    else
      options[:class] = [options[:class],"#{color.to_s}-tag"]
    end
    content_tag(:span, content, options)
  end
end
