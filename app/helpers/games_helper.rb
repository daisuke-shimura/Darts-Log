module GamesHelper
  def game_title(kind)
    return if kind == nil
    
    if kind == "zero_one"
      "01 GAMES"
    elsif kind == "cricket"
      "CRICKET"
    elsif kind == "count_up"
      "COUNT-UP"
    elsif kind == "center_count_up"
      "CENTER COUNT-UP"
    elsif kind == "cricket_count_up"
      "CRICKET COUNT-UP"
    elsif kind == "shoot_out"
      "SHOOT OUT"
    end
  end
end
