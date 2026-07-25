module ApplicationHelper
  def mark_icon(name, options = {})
    classes = ["cricket-mark-icon", options[:class]].compact.join(" ")
    content_tag(:svg, class: classes) do
      content_tag(:use, "", href: "#icon-#{name}")
    end
  end

  def round_text_class(round)
    return "" if round.nil? || round.score.nil?

    if round.score >= 100 && round.score <= 150
      "text-danger"
    elsif round.bust
      "text-primary"
    elsif round.score > 150
      "text-warning"
    else
      ""
    end
  end
end
