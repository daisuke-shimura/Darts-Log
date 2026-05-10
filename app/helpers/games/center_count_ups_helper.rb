module Games::CenterCountUpsHelper
  def round_border_class(r)
    r = r.to_f
    if r <= 16.6
      "border-color-600"
    elsif r <= 40.0
      "border-color-500"
    elsif r <= 54.6
      "border-color-480"
    elsif r <= 65.9
      "border-color-400"
    elsif r <= 84.8
      "border-color-350"
    elsif r <= 109.0
      "border-color-200"
    elsif r <= 130.4
      "border-color-100"
    elsif r <= 150.2
      "border-color-80"
    elsif r <= 173.8
      "border-color-70"
    elsif r <= 196.0
      "border-color-60"
    elsif r <= 392.6
      "border-color-50"
    else
      "border-color-0"
    end
  end
end
