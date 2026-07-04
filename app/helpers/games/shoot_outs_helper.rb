module Games::ShootOutsHelper
  def segemnt_status(segment, status)
    return content_tag(:div) if segment.nil?

    classes = []
    classes << "small" if segment == 50
    classes << "closed-number" if status != 0

    content_tag(
      :div,
      segment == 50 ? "BULL" : segment,
      class: classes.join(" "),
      data: { segment: segment }
    )
  end
end
