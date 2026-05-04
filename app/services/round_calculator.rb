class RoundCalculator
  def hit?(segment:, multiplier:, target:)
    return true if target == "bull" && segment == 50
    return false if target == "undefined" || target.nil?
  
    hit_number = multiplier[0] + segment.to_s
    if target == hit_number
      return true
    else
      return false
    end
  end

  def s_bull?(segment:, multiplier:)
    if segment == 50 && multiplier == "single"
      return true
    else
      return false
    end
  end

  def d_bull?(segment:, multiplier:)
    if segment == 50 && multiplier == "double"
      return true
    else
      return false
    end
  end

  def award(round)
    criket_numbers = [15, 16, 17, 18, 19, 20]
    score = 0
    hat_count = 0
    black_count = 0

    awards = {
      low_ton: false,
      hat_trick: false,
      three_in_a_bed: false,
      high_ton: false,
      ton80: false,
      white_horse: false,
      three_in_the_black: false
    }
  
    round.each do |dart|
      score += dart.segment * dart.multiplier
      if dart.target == 50
        if dart.multiplier == "double"
          black_count += 1
        end
        hat_count += 1
      end
    end

    if score >= 100 && score < 150
      awards[:low_ton] = true
    elsif score >= 150 && score < 180
      awards[:high_ton] = true
    elsif score == 180
      awards[:ton80] = true
    end

    if hat_count == 3
      awards[:hat_trick] = true
      if black_count == 3
        awards[:three_in_the_black] = true
      end
    end

    first_segment = round[0].segment
    first_multiplier = round[0].multiplier
    unless first_segment == 50 || first_multiplier == "single"
      if (round.all? { |dart| dart.segment == first_segment }) && (round.all? { |dart| dart.multiplier == first_multiplier })
      awards[:three_in_a_bed] = true
        # if first_multiplier == "triple" && first_segment == 20
        #   ton80 = true
        # end
      end
    end

    second_segment = round[1].segment
    second_multiplier = round[1].multiplier
    third_segment = round[2].segment
    third_multiplier = round[2].multiplier
    if [first_segment, second_segment, third_segment].uniq.size == 3 && [first_segment, second_segment, third_segment].all? { |segment| criket_numbers.include?(segment) }
      if [first_segment, second_segment, third_segment].all? { |s| criket_numbers.include?(s) }
        if first_multiplier == "triple" && second_multiplier == "triple" && third_multiplier == "triple"
          awards[:white_horse] = true
        end
      end
    end

    return awards
  end
end