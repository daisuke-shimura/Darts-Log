module Games::ZeroOnesHelper
  def round_text_class(round)
    return "" if round.nil? # データがない（補完分）ときはクラスなし
    
    if round.bust
      "text-primary"
    elsif round.score > 150
      "text-warning"
    elsif round.score >= 100
      "text-danger"
    else
      ""
    end
  end
end
