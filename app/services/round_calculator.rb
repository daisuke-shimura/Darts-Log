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

  def score_and_range(round)
    score = 0
    range_sum = 0
    round.each do |dart|
      if dart.segment == 50
        score += dart.segment
      else
        score += dart.segment * dart.multiplier_before_type_cast
      end
      range_sum += dart.absolute_r
    end
    range = (range_sum.to_f / round.size).round(2)
    return score, range
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

  #(x,y)座標変換
  def coordinateXY(round)
    dartspoints = []
    round.each do |dart|
      r = dart.absolute_r
      theta = dart.absolute_0 * Math::PI / 180
      x = (r * Math.cos(theta)).round(2)
      y = (r * Math.sin(theta)).round(2)
      dartspoints << { id:dart.id, x: x, y: y }
    end
    return dartspoints
  end

  #三点間の距離
  def distance(dartspoints)
    dartspoints.combination(2).map do |a, b|
      x_d = (a[:x] - b[:x])**2
      y_d = (a[:y] - b[:y])**2
      d = Math.sqrt(x_d + y_d).round(2)
      {
        id: "#{a[:id]}, #{b[:id]}",
        distance: d
      }
    end
  end

  #三点間の距離の平均と最大値
  def average_and_max_distance(dartspoints)
    distances = distance(dartspoints)
    average = (distances.sum { |d| d[:distance] } / distances.size).round(2)
    max = distances.max_by { |d| d[:distance] }
    return average, max
  end

  #重心
  def center_of_gravity(dartspoints)
    distances = distance(dartspoints)
    x_avg = (distances.sum { |d| d[:x] } / distances.size).round(2)
    y_avg = (distances.sum { |d| d[:y] } / distances.size).round(2)
    return { x: x_avg, y: y_avg }
  end

  #重心からの距離の平均と最大値
  def average_and_max_distance_from_center(dartspoints)
    center = center_of_gravity(dartspoints)
    d1 = Math.sqrt((dartspoints[0][:x] - center[:x])**2 + (dartspoints[0][:y] - center[:y])**2)
    d2 = Math.sqrt((dartspoints[1][:x] - center[:x])**2 + (dartspoints[1][:y] - center[:y])**2)
    d3 = Math.sqrt((dartspoints[2][:x] - center[:x])**2 + (dartspoints[2][:y] - center[:y])**2)
    average = ((d1 + d2 + d3) / 3).round(2)
    max = [d1, d2, d3].max.round(2)
    return average, max
  end

  #面積
  def area(dartspoints)
    term1 = dartspoints[0][:x] * (dartspoints[1][:y] - dartspoints[2][:y])
    term2 = dartspoints[1][:x] * (dartspoints[2][:y] - dartspoints[0][:y])
    term3 = dartspoints[2][:x] * (dartspoints[0][:y] - dartspoints[1][:y])
    absolute = (term1 + term2 + term3).abs
    area = (absolute / 2).round(2)
    return area
  end

  # 分散
  def variance(dartspoints)
    x_avg = center_of_gravity(dartspoints)[:x]
    y_avg = center_of_gravity(dartspoints)[:y]
    xterm = dartspoints.sum { |d| (d[:x] - x_avg) ** 2 }
    yterm = dartspoints.sum { |d| (d[:y] - y_avg) ** 2 }
    variance = (xterm + yterm) / dartspoints.size
    return variance.round(2)
  end

  #外接円
  def circumscribed_circle(dartspoints)
    a = dartspoints[0]
    b = dartspoints[1]
    c = dartspoints[2]

    d = 2 * (a[:x] * (b[:y] - c[:y]) + b[:x] * (c[:y] - a[:y]) + c[:x] * (a[:y] - b[:y]))
    if d == 0
      return nil
    end

    ux = ((a[:x]**2 + a[:y]**2) * (b[:y] - c[:y]) + (b[:x]**2 + b[:y]**2) * (c[:y] - a[:y]) + (c[:x]**2 + c[:y]**2) * (a[:y] - b[:y])) / d
    uy = ((a[:x]**2 + a[:y]**2) * (c[:x] - b[:x]) + (b[:x]**2 + b[:y]**2) * (a[:x] - c[:x]) + (c[:x]**2 + c[:y]**2) * (b[:x] - a[:x])) / d

    radius = Math.sqrt((ux - a[:x])**2 + (uy - a[:y])**2).round(2)

    return { center: { x: ux.round(2), y: uy.round(2) }, radius: radius }
  end

  #最小外接円
  def min_enclosing_circle(dartspoints)
    distances = distance(dartspoints)
    max = distances.max_by { |d| d[:distance] }
    max_id = max[:id].split(', ').map(&:to_i)
    a = dartspoints.find { |d| d[:id] == max_id[0] }
    b = dartspoints.find { |d| d[:id] == max_id[1] }
    c = dartspoints.find { |d| d[:id] != max_id[0] && d[:id] != max_id[1] }
    center_x = ((a[:x] + b[:x]) / 2)
    center_y = ((a[:y] + b[:y]) / 2)
    radius = (max[:distance] / 2)
    c_distance = Math.sqrt((center_x - c[:x])**2 + (center_y - c[:y])**2)
    if c_distance <= radius
      return { center: { x: center_x.round(2), y: center_y.round(2) }, radius: radius.round(2) }
    else
      return circumscribed_circle(dartspoints)
    end
  end
end