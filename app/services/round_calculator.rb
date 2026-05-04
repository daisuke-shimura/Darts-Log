class RoundCalculator
  def hit?(dart)
    segment = dart.segment
    multiplier = dart.multiplier_before_type_cast
    target = dart.target_before_type_cast
    return false if target == 0 || target.nil?
    return true if target == segment
  
    hit_number = multiplier * 100 + segment
    if target == hit_number
      return true
    else
      return false
    end
  end

  def s_bull?(dart)
    if dart.segment == 50 && dart.single?
      return true
    else
      return false
    end
  end

  def d_bull?(dart)
    if dart.segment == 50 && dart.double?
      return true
    else
      return false
    end
  end

  def score(round)
    score = 0
    round.each do |dart|
      score += dart.segment * dart.multiplier_before_type_cast
    end
    return score
  end

  def award(round, score)
    criket_numbers = [15, 16, 17, 18, 19, 20]

    awards = {
      low_ton: false,
      hat_trick: false,
      three_in_a_bed: false,
      high_ton: false,
      ton80: false,
      white_horse: false,
      three_in_the_black: false
    }

    if score >= 100 && score <= 150
      awards[:low_ton] = true
    elsif score > 150 && score < 180
      awards[:high_ton] = true
    elsif score == 180
      awards[:ton80] = true
    end

    return awards if round.size < 3

    first = round[0]
    second = round[1]
    third = round[2]
    if first.segment == 50 && second.segment == 50 && third.segment == 50
      awards[:hat_trick] = true
      awards[:low_ton] = false
      if first.double? && second.double? && third.double?
        awards[:three_in_the_black] = true
      end
    end

    unless first.segment == 50 || first.single?
      if (round.all? { |dart| dart.segment == first.segment }) && (round.all? { |dart| dart.multiplier == first.multiplier })
      awards[:three_in_a_bed] = true
      end
    end

    if [first.segment, second.segment, third.segment].uniq.size == 3 && [first.segment, second.segment, third.segment].all? { |segment| criket_numbers.include?(segment) }
      if first.triple? && second.triple? && third.triple?
        awards[:white_horse] = true
      end
    end

    return awards
  end
end