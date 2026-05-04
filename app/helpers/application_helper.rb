module ApplicationHelper
  def mark_icon(name, options = {})
    classes = ["criket-mark-icon", options[:class]].compact.join(" ")
    content_tag(:svg, class: classes) do
      content_tag(:use, "", href: "#icon-#{name}")
    end
  end
end
