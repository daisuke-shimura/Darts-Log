module Games::ZeroOnesHelper
  def round_text_class(round)
    return "" if round.nil?

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
